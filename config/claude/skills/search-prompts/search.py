#!/usr/bin/env python3
"""Search Claude Code history for prompts matching keywords."""
import json
import sys
import re
from pathlib import Path
from datetime import datetime
from collections import defaultdict

def search_prompts(keywords: list[str], max_results: int = 20) -> list[dict]:
    """Search conversation history for prompts matching keywords."""
    results = []
    history_base = Path.home() / ".claude/projects"

    if not history_base.exists():
        return []

    # Search all project directories
    for project_dir in history_base.iterdir():
        if not project_dir.is_dir():
            continue

        for jsonl_file in sorted(project_dir.glob("*.jsonl"),
                                  key=lambda x: x.stat().st_mtime,
                                  reverse=True):
            if jsonl_file.stat().st_size < 1000:
                continue

            try:
                with open(jsonl_file, 'r', errors='ignore') as f:
                    for line in f:
                        try:
                            entry = json.loads(line)
                            text = extract_user_text(entry)
                            if not text or len(text) < 50 or len(text) > 2000:
                                continue

                            # Skip system/tool content
                            if should_skip(text):
                                continue

                            # Check for keyword matches
                            text_lower = text.lower()
                            matched = [kw for kw in keywords if kw.lower() in text_lower]

                            if matched:
                                results.append({
                                    "date": extract_date(entry),
                                    "keywords": matched,
                                    "prompt": clean_text(text)[:300],
                                    "score": len(matched)
                                })
                        except json.JSONDecodeError:
                            continue
            except Exception:
                continue

    # Dedupe and sort by score
    seen = set()
    unique = []
    for r in sorted(results, key=lambda x: (x["score"], len(x["prompt"])), reverse=True):
        key = r["prompt"][:80]
        if key not in seen:
            seen.add(key)
            unique.append(r)

    return unique[:max_results]

def extract_user_text(entry: dict) -> str | None:
    """Extract user text from various message formats."""
    msg = entry.get("message", {})

    # Direct string message
    if isinstance(msg, str):
        return msg

    # Content array with role=user
    if isinstance(msg, dict) and msg.get("role") == "user":
        content = msg.get("content", "")
        if isinstance(content, str):
            return content
        elif isinstance(content, list):
            for item in content:
                if isinstance(item, dict) and item.get("type") == "text":
                    return item.get("text", "")

    return None

def should_skip(text: str) -> bool:
    """Check if text should be skipped (system/tool content)."""
    skip_patterns = [
        "tool_result",
        "system-reminder",
        "Base directory for this skill",
        "tool_use_id",
        "<system-reminder>"
    ]
    return any(p in text for p in skip_patterns)

def extract_date(entry: dict) -> str:
    """Extract date from entry timestamp."""
    ts = entry.get("timestamp", "")
    try:
        if isinstance(ts, str) and ts:
            dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
            return dt.strftime("%Y-%m-%d")
        elif isinstance(ts, (int, float)):
            dt = datetime.fromtimestamp(ts / 1000)
            return dt.strftime("%Y-%m-%d")
    except Exception:
        pass
    return "?"

def clean_text(text: str) -> str:
    """Clean and normalize text."""
    return re.sub(r'\s+', ' ', text).strip()

def main():
    if len(sys.argv) < 2:
        print("Usage: /search-prompts <keywords...>")
        print("Example: /search-prompts flywheel compounding cto")
        sys.exit(1)

    keywords = sys.argv[1:]
    results = search_prompts(keywords)

    print(f"=== FOUND {len(results)} MATCHING PROMPTS ===\n")

    for i, r in enumerate(results, 1):
        kws = ", ".join(r["keywords"])
        print(f"{i}. [{r['date']}] Keywords: {kws}")
        print(f"   \"{r['prompt']}...\"")
        print()

if __name__ == "__main__":
    main()
