// brain-graph.mjs - rebuild the served vault graph: graphify + wikilink bridge + repo merge. Runtime: bun --bun.
// Use this, not a bare `graphify update .`, which drops every cross-folder [[wikilink]] and leaves
// merged-graph.json (what .mcp.json serves) stale. `--force` passes through to graphify.
import { rebuildGraph } from "./brain-lib.mjs";

rebuildGraph({ force: process.argv.includes("--force") });
