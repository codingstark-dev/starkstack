#!/usr/bin/env python3
"""Crawl a site from a base URL (same origin only) and report broken internal links.

Usage: linkcheck.py <base-url> [--max 500] [--save .starkstack/baseline/links.txt] [--compare old-links.txt]
--save writes the discovered URL list (use before a change); --compare reports URLs that existed before but now fail
(use after a feature or migration to catch lost routes / missing redirects). Exit 1 if anything is broken.
"""
import argparse, sys, urllib.request, urllib.parse, urllib.error
from html.parser import HTMLParser

class Links(HTMLParser):
    def __init__(self):
        super().__init__(); self.found = []
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        for k in ("href", "src"):
            if a.get(k): self.found.append(a[k])

def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "starkstack-linkcheck"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            ctype = r.headers.get("content-type", "")
            body = r.read(2_000_000).decode("utf-8", "replace") if "html" in ctype else ""
            return r.status, body
    except urllib.error.HTTPError as e:
        return e.code, ""
    except Exception as e:
        return f"ERR {type(e).__name__}", ""

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("base"); ap.add_argument("--max", type=int, default=500)
    ap.add_argument("--save"); ap.add_argument("--compare"); a = ap.parse_args()
    base = a.base.rstrip("/") + "/"; origin = urllib.parse.urlsplit(base).netloc
    queue, seen, broken = [base], set(), []
    while queue and len(seen) < a.max:
        url = urllib.parse.urldefrag(queue.pop(0))[0]
        if url in seen: continue
        seen.add(url); status, body = fetch(url)
        if not (isinstance(status, int) and status < 400): broken.append((status, url)); continue
        p = Links(); p.feed(body)
        for h in p.found:
            if h.startswith(("mailto:", "tel:", "javascript:", "data:", "#")): continue
            u = urllib.parse.urljoin(url, h)
            if urllib.parse.urlsplit(u).netloc == origin and u not in seen: queue.append(u)
    if a.compare:
        try:
            for old in open(a.compare).read().split():
                if old not in seen:
                    status, _ = fetch(old)
                    if not (isinstance(status, int) and status < 400): broken.append((status, old + "  (existed before)"))
        except FileNotFoundError: print(f"compare file {a.compare} not found", file=sys.stderr)
    if a.save:
        open(a.save, "w").write("\n".join(sorted(seen)) + "\n")
    print(f"checked {len(seen)} URLs on {origin}")
    for s, u in broken: print(f"BROKEN {s}  {u}")
    print("linkcheck: PASS" if not broken else f"linkcheck: FAIL ({len(broken)} broken)")
    sys.exit(1 if broken else 0)

if __name__ == "__main__": main()
