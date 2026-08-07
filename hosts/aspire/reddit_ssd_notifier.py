#!/usr/bin/env python3
"""Poll r/buildapcsales for new SSD posts and publish them to ntfy.

Example:
    NTFY_URL="https://ntfy.sh/my-private-topic" ./reddit_ssd_notifier.py

NTFY_URL must be the full ntfy topic URL. Set NTFY_TOKEN as well if the
server requires a bearer token.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import tempfile
import time
from http.cookiejar import CookieJar
from html.parser import HTMLParser
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import HTTPCookieProcessor, Request, build_opener, urlopen

REDDIT_URL = "https://www.reddit.com/r/buildapcsales/new/"
APP_USER_AGENT = "buildapcsales-ssd-notifier/1.0"
REDDIT_USER_AGENT = os.environ.get(
    "REDDIT_USER_AGENT",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36",
)
SSD_PATTERN = re.compile(r"\b(?:ssd|nvme|solid[ -]state)\b", re.IGNORECASE)


class RedditPostParser(HTMLParser):
    """Extract posts from Reddit's server-rendered shreddit-post elements."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.posts: list[dict[str, Any]] = []

    def handle_starttag(
        self, tag: str, attributes: list[tuple[str, str | None]]
    ) -> None:
        if tag != "shreddit-post":
            return
        attrs = dict(attributes)
        post_id = attrs.get("id", "")
        title = attrs.get("post-title")
        permalink = attrs.get("permalink")
        if post_id and title and permalink:
            self.posts.append(
                {
                    "id": post_id.removeprefix("t3_"),
                    "title": title,
                    "permalink": permalink,
                }
            )


def fetch_posts() -> list[dict[str, Any]]:
    headers = {
        "Accept": (
            "text/html,application/xhtml+xml,application/xml;q=0.9,"
            "image/avif,image/webp,image/apng,*/*;q=0.8"
        ),
        "Accept-Language": "en-US,en;q=0.9",
        "Cache-Control": "max-age=0",
        "Priority": "u=0, i",
        "Sec-Ch-Ua": (
            '"Not=A?Brand";v="24", "Chromium";v="140", '
            '"Google Chrome";v="140"'
        ),
        "Sec-Ch-Ua-Mobile": "?0",
        "Sec-Ch-Ua-Platform": '"Linux"',
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "none",
        "Sec-Fetch-User": "?1",
        "Upgrade-Insecure-Requests": "1",
        "User-Agent": REDDIT_USER_AGENT,
    }
    opener = build_opener(HTTPCookieProcessor(CookieJar()))

    def get_page(url: str) -> str:
        with opener.open(Request(url, headers=headers), timeout=20) as response:
            return response.read().decode(
                response.headers.get_content_charset() or "utf-8"
            )

    page = get_page(REDDIT_URL)

    # Reddit may return a small JavaScript challenge before the actual page.
    challenge = re.search(r'await\(async e=>e\+e\)\("([^"]+)"\)', page)
    token = re.search(r'name="token" value="([^"]+)"', page)
    if challenge and token:
        params = urlencode(
            {
                "solution": challenge.group(1) * 2,
                "js_challenge": "1",
                "token": token.group(1),
                "jsc_orig_r": "",
            }
        )
        page = get_page(f"{REDDIT_URL}?{params}")

    parser = RedditPostParser()
    parser.feed(page)
    if not parser.posts:
        raise ValueError("Reddit page contained no recognizable posts")
    return parser.posts


def send_notification(ntfy_url: str, token: str | None, post: dict[str, Any]) -> None:
    post_url = "https://www.reddit.com" + post["permalink"]
    message = f'{post["title"]}\n\n{post_url}'.encode("utf-8")
    headers = {
        "Title": "New SSD deal on r/buildapcsales",
        "Tags": "computer",
        "Click": post_url,
        "Content-Type": "text/plain; charset=utf-8",
        "User-Agent": APP_USER_AGENT,
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    request = Request(ntfy_url, data=message, headers=headers, method="POST")
    with urlopen(request, timeout=20) as response:
        if not 200 <= response.status < 300:
            raise RuntimeError(f"ntfy returned HTTP {response.status}")


def load_seen(path: Path) -> set[str] | None:
    """Return None when no state exists, so the first poll can be a baseline."""
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        return set(data.get("seen_ids", []))
    except (OSError, ValueError, TypeError) as error:
        logging.warning("Could not read state file %s: %s", path, error)
        return None


def save_seen(path: Path, seen: set[str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    contents = json.dumps({"seen_ids": sorted(seen)}, indent=2) + "\n"
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", dir=path.parent, delete=False
    ) as temporary:
        temporary.write(contents)
        temporary_path = Path(temporary.name)
    temporary_path.replace(path)


def check_once(
    ntfy_url: str, token: str | None, state_path: Path, notify_existing: bool
) -> None:
    posts = fetch_posts()
    seen = load_seen(state_path)

    if seen is None and not notify_existing:
        save_seen(state_path, {post["id"] for post in posts})
        logging.info("Initialized with %d existing posts; waiting for new ones", len(posts))
        return

    seen = seen or set()
    current_ids = {post["id"] for post in posts}
    # Only IDs in Reddit's current listing are needed to detect the next batch.
    seen.intersection_update(current_ids)
    new_posts = [post for post in posts if post["id"] not in seen]

    # Reddit returns newest first; notify oldest first when several appeared.
    for post in reversed(new_posts):
        if SSD_PATTERN.search(post.get("title", "")):
            send_notification(ntfy_url, token, post)
            logging.info("Sent notification: %s", post["title"])
        seen.add(post["id"])
        save_seen(state_path, seen)

    if not new_posts:
        logging.info("No new posts")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Send new r/buildapcsales SSD posts to an ntfy topic."
    )
    parser.add_argument(
        "--ntfy-url",
        default=os.environ.get("NTFY_URL"),
        help="full topic URL (or set NTFY_URL), e.g. https://ntfy.sh/my-topic",
    )
    parser.add_argument(
        "--token",
        default=os.environ.get("NTFY_TOKEN"),
        help="optional ntfy bearer token (or set NTFY_TOKEN)",
    )
    parser.add_argument(
        "--interval",
        type=float,
        default=60,
        help="polling interval in seconds (default: 60)",
    )
    parser.add_argument(
        "--state-file",
        type=Path,
        default=Path(".reddit_ssd_notifier_state.json"),
        help="path used to remember seen posts",
    )
    parser.add_argument(
        "--notify-existing",
        action="store_true",
        help="notify for matching posts already present on the first poll",
    )
    args = parser.parse_args()

    if not args.ntfy_url:
        parser.error("--ntfy-url or the NTFY_URL environment variable is required")
    if args.interval <= 0:
        parser.error("--interval must be greater than zero")
    return args


def main() -> None:
    args = parse_args()
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )

    logging.info("Watching r/buildapcsales every %g seconds", args.interval)
    try:
        while True:
            started = time.monotonic()
            try:
                check_once(
                    args.ntfy_url,
                    args.token,
                    args.state_file,
                    args.notify_existing,
                )
            except (
                HTTPError,
                URLError,
                TimeoutError,
                KeyError,
                ValueError,
                OSError,
                RuntimeError,
            ) as error:
                logging.error("Poll failed: %s", error)
            elapsed = time.monotonic() - started
            time.sleep(max(0, args.interval - elapsed))
    except KeyboardInterrupt:
        logging.info("Stopped")


if __name__ == "__main__":
    main()
