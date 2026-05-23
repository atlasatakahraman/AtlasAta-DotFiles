#!/usr/bin/env python3
"""
Dream Mode — Signal Gathering Script
Scans Antigravity conversation logs and workspace state to prepare
a consolidation report for the agent's dream cycle.

Usage:
    python3 dream_gather.py [scope]
    
Scopes:
    #       - Current project only (default)
    user    - User-level memory
    all     - Both project and user
"""

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

ANTIGRAVITY_DIR = Path.home() / ".gemini" / "antigravity"
BRAIN_DIR = ANTIGRAVITY_DIR / "brain"
MEMORY_FILES = {
    "project": None,  # Set dynamically based on workspace
    "user": ANTIGRAVITY_DIR / "USER_MEMORY.md",
}


def find_workspace_root():
    """Walk up from cwd to find MEMORY.md"""
    path = Path.cwd()
    while path != path.parent:
        if (path / "MEMORY.md").exists():
            return path
        path = path.parent
    return Path.cwd()


def scan_conversations():
    """Scan all conversation logs and extract signal."""
    conversations = []
    if not BRAIN_DIR.exists():
        return conversations

    for conv_dir in sorted(BRAIN_DIR.iterdir()):
        if not conv_dir.is_dir():
            continue

        conv_id = conv_dir.name
        log_file = conv_dir / ".system_generated" / "logs" / "overview.txt"

        if not log_file.exists():
            continue

        conv_data = {
            "id": conv_id,
            "entries": [],
            "user_corrections": [],
            "key_decisions": [],
            "files_changed": [],
            "timestamp": None,
        }

        try:
            with open(log_file, "r") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        entry = json.loads(line)
                        # Track timestamps
                        if entry.get("created_at") and not conv_data["timestamp"]:
                            conv_data["timestamp"] = entry["created_at"]

                        content = entry.get("content", "")

                        # Detect user corrections
                        if entry.get("source") == "USER_EXPLICIT":
                            correction_signals = [
                                "no,", "wrong", "actually", "not that",
                                "incorrect", "fix", "that's not", "should be",
                                "wait,", "stop", "correction"
                            ]
                            if any(sig in content.lower() for sig in correction_signals):
                                conv_data["user_corrections"].append(
                                    content[:200]
                                )

                        # Detect file operations
                        tool_calls = entry.get("tool_calls", [])
                        if isinstance(tool_calls, list):
                            for tc in tool_calls:
                                if isinstance(tc, dict):
                                    name = tc.get("name", "")
                                    args = tc.get("args", {})
                                    if name in ("write_to_file", "replace_file_content",
                                                "multi_replace_file_content"):
                                        target = args.get("TargetFile", "")
                                        if isinstance(target, str) and target:
                                            # Clean up quoted strings
                                            target = target.strip('"')
                                            conv_data["files_changed"].append(target)

                        conv_data["entries"].append(entry)
                    except json.JSONDecodeError:
                        continue
        except Exception as e:
            conv_data["error"] = str(e)

        conversations.append(conv_data)

    return conversations


def check_staleness(memory_path):
    """Check if a memory file has stale references."""
    stale = []
    if not memory_path or not Path(memory_path).exists():
        return stale

    with open(memory_path, "r") as f:
        content = f.read()

    # Extract file paths mentioned in memory
    import re
    paths = re.findall(r'`([/~][^`]+)`', content)
    for p in paths:
        expanded = os.path.expanduser(p)
        if not os.path.exists(expanded):
            stale.append(p)

    return stale


def check_contradictions(memory_path):
    """Context-aware contradiction detection — looks for duplicate version specs
    while understanding that 'upstream X' vs 'target Y' is not a contradiction."""
    contradictions = []
    if not memory_path or not Path(memory_path).exists():
        return contradictions

    import re
    with open(memory_path, "r") as f:
        lines = f.readlines()

    # Context words that qualify a version as non-authoritative
    context_qualifiers = [
        "upstream", "backport", "from", "source", "original",
        "dev branch", "targets", "→", "forward-port", "reverse"
    ]

    # Track version mentions
    versions = {}
    for i, line in enumerate(lines):
        line_lower = line.lower()
        # Skip lines that contain qualifying context
        is_contextual = any(q in line_lower for q in context_qualifiers)

        # Match patterns like "Sodium 0.5.13" or "version: 1.20.1"
        matches = re.findall(r'(\w+)\s+(\d+\.\d+[\.\d]*[-\w]*)', line)
        for name, ver in matches:
            key = name.lower()
            if is_contextual:
                continue  # Don't track versions in contextual lines
            if key in versions and versions[key]["version"] != ver:
                contradictions.append({
                    "subject": name,
                    "version_a": versions[key]["version"],
                    "line_a": versions[key]["line"],
                    "version_b": ver,
                    "line_b": i + 1,
                })
            else:
                versions[key] = {"version": ver, "line": i + 1}

    return contradictions


def detect_project_type(workspace_root):
    """Detect project types in the workspace by looking for config files."""
    projects = []
    
    # Check for various project indicators
    indicators = {
        "java_gradle": ("build.gradle", "Java/Gradle"),
        "java_gradle_kts": ("build.gradle.kts", "Java/Gradle (Kotlin DSL)"),
        "node": ("package.json", "Node.js"),
        "python_pip": ("requirements.txt", "Python"),
        "python_poetry": ("pyproject.toml", "Python (Poetry)"),
        "rust": ("Cargo.toml", "Rust"),
        "go": ("go.mod", "Go"),
    }
    
    # Search up to 3 levels deep for project directories
    for depth in range(4):
        for config_file, project_type in indicators.values():
            pattern = "/".join(["*"] * depth) + f"/{config_file}" if depth > 0 else config_file
            for match in workspace_root.glob(pattern):
                project_dir = match.parent
                project_name = project_dir.name if project_dir != workspace_root else workspace_root.name
                projects.append({
                    "name": project_name,
                    "path": str(project_dir),
                    "type": project_type,
                    "config": str(match),
                })
    
    # Deduplicate by path
    seen = set()
    unique = []
    for p in projects:
        if p["path"] not in seen:
            seen.add(p["path"])
            unique.append(p)
    
    return unique


def generate_report(scope, workspace_root):
    """Generate the full dream gathering report."""
    print("🌙 Dream Mode — Signal Gathering")
    print(f"   Scope: {scope}")
    print(f"   Workspace: {workspace_root}")
    print(f"   Timestamp: {datetime.now(timezone.utc).isoformat()}")
    print()

    # === Phase 0: Bootstrap Check ===
    memory_path = workspace_root / "MEMORY.md"
    user_memory = ANTIGRAVITY_DIR / "USER_MEMORY.md"
    claude_files = list(workspace_root.rglob("CLAUDE.md"))
    
    missing_files = []
    if not memory_path.exists():
        missing_files.append(("MEMORY.md", str(memory_path), "project memory index"))
    if not user_memory.exists():
        missing_files.append(("USER_MEMORY.md", str(user_memory), "cross-project user preferences"))
    
    # Detect projects that lack CLAUDE.md
    projects = detect_project_type(workspace_root)
    projects_without_claude = []
    for proj in projects:
        proj_path = Path(proj["path"])
        if not (proj_path / "CLAUDE.md").exists():
            projects_without_claude.append(proj)
    
    if missing_files or projects_without_claude:
        print("🆕 BOOTSTRAP REQUIRED — Missing memory files detected:")
        print()
        for name, path, purpose in missing_files:
            print(f"   ❌ {name} — {purpose}")
            print(f"      Path: {path}")
            print(f"      Action: CREATE with template from dream skill Phase 0")
        for proj in projects_without_claude:
            print(f"   ❌ CLAUDE.md missing for project: {proj['name']}")
            print(f"      Path: {proj['path']}/CLAUDE.md")
            print(f"      Type: {proj['type']} (detected via {Path(proj['config']).name})")
            print(f"      Action: CREATE by scanning {proj['config']}")
        print()
        
        # Show detected project structure to help bootstrapping
        print("📂 Detected project structure:")
        for proj in projects:
            has_claude = "✅" if (Path(proj["path"]) / "CLAUDE.md").exists() else "❌"
            print(f"   {has_claude} {proj['name']} ({proj['type']}) — {proj['path']}")
        print()

    # === Phase 1: Orient (existing files) ===
    
    # Scan conversations
    conversations = scan_conversations()
    total_convs = len(conversations)
    total_corrections = sum(len(c["user_corrections"]) for c in conversations)
    total_files = sum(len(c["files_changed"]) for c in conversations)

    print(f"📊 Conversations scanned: {total_convs}")
    print(f"   User corrections found: {total_corrections}")
    print(f"   Files changed across sessions: {total_files}")
    print()

    # Check MEMORY.md
    if memory_path.exists():
        line_count = sum(1 for _ in open(memory_path))
        stale = check_staleness(str(memory_path))
        contradictions = check_contradictions(str(memory_path))

        print(f"📄 MEMORY.md: {line_count}/200 lines ({line_count * 100 // 200}% capacity)")
        print(f"   Stale references: {len(stale)}")
        for s in stale:
            print(f"     ⚠ {s}")
        print(f"   Contradictions: {len(contradictions)}")
        for c in contradictions:
            print(f"     ⚠ {c['subject']}: {c['version_a']} (L{c['line_a']}) vs {c['version_b']} (L{c['line_b']})")
    else:
        print("📄 MEMORY.md: NOT FOUND — will be created during bootstrap")
    print()

    # Check user memory
    if user_memory.exists():
        line_count = sum(1 for _ in open(user_memory))
        print(f"👤 USER_MEMORY.md: {line_count}/50 lines ({line_count * 100 // 50}% capacity)")
    else:
        print("👤 USER_MEMORY.md: NOT FOUND — will be created during bootstrap")
    print()

    # Check CLAUDE.md files
    print(f"📋 CLAUDE.md files found: {len(claude_files)}")
    for cf in claude_files:
        line_count = sum(1 for _ in open(cf))
        print(f"   {cf.relative_to(workspace_root)}: {line_count}/50 lines")
    if not claude_files:
        print("   (none — will be created during bootstrap)")
    print()

    # User corrections detail
    if total_corrections > 0:
        print("🔧 User Corrections (needs consolidation):")
        for conv in conversations:
            for correction in conv["user_corrections"][:3]:
                if "<USER_REQUEST>" in correction:
                    import re
                    match = re.search(r'<USER_REQUEST>\s*(.*?)\s*</USER_REQUEST>',
                                     correction, re.DOTALL)
                    if match:
                        print(f"   → {match.group(1)[:120]}")
                    else:
                        print(f"   → {correction[:120]}")
                else:
                    print(f"   → {correction[:120]}")
        print()

    # Dream recommendation
    needs_dream = False
    reasons = []
    
    # Bootstrap is always a dream trigger
    if missing_files or projects_without_claude:
        needs_dream = True
        missing_names = [f[0] for f in missing_files] + [f"{p['name']}/CLAUDE.md" for p in projects_without_claude]
        reasons.append(f"Missing files: {', '.join(missing_names)}")
    
    if total_corrections > 2:
        needs_dream = True
        reasons.append(f"{total_corrections} user corrections detected")
    if memory_path.exists():
        stale = check_staleness(str(memory_path))
        if len(stale) > 0:
            needs_dream = True
            reasons.append(f"{len(stale)} stale references")
        contradictions = check_contradictions(str(memory_path))
        if len(contradictions) > 0:
            needs_dream = True
            reasons.append(f"{len(contradictions)} contradictions")
        if sum(1 for _ in open(memory_path)) > 160:
            needs_dream = True
            reasons.append("Memory approaching capacity (>80%)")

    print("─" * 50)
    if needs_dream:
        print(f"⚡ DREAM RECOMMENDED: {', '.join(reasons)}")
        if missing_files or projects_without_claude:
            print("   → Run Phase 0 (Bootstrap) first, then consolidate")
    else:
        print("✅ Memory is clean — no dream needed right now")

    return {
        "conversations": total_convs,
        "corrections": total_corrections,
        "files_changed": total_files,
        "needs_dream": needs_dream,
        "needs_bootstrap": bool(missing_files or projects_without_claude),
        "missing_files": [(f[0], f[1]) for f in missing_files],
        "projects_without_claude": projects_without_claude,
        "reasons": reasons,
    }


if __name__ == "__main__":
    scope = sys.argv[1] if len(sys.argv) > 1 else "#"
    workspace = find_workspace_root()
    report = generate_report(scope, workspace)

