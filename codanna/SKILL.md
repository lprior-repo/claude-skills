---
name: codanna
description: "Code intelligence expert for semantic search, symbol lookups, and MCP integration. Use when exploring codebases, finding implementations, tracing call graphs, or searching by concept. Covers per-repo setup, CLI commands, MCP tools, and multi-repo workflows."
argument-hint: [query, command, or workflow question]
version: 1.1.0
---

```jsonl
{"kind":"meta","skill":"codanna","version":"1.1.0","updated":"2026-02","format":"markdown-with-embedded-jsonl"}
{"kind":"concept","id":"symbol_lookups","text":"Sub-10ms symbol lookups with memory-mapped caches"}
{"kind":"concept","id":"semantic_search","text":"Search by concept (\"where's the retry logic?\")"}
{"kind":"concept","id":"relationships","text":"Relationship tracking (call graphs, dependencies)"}
{"kind":"concept","id":"mcp","text":"MCP protocol for AI assistant integration"}
{"kind":"rule","id":"repo_scope","text":"ALWAYS run codanna with --config .codanna/settings.toml from the target repo. Never rely on a shared/global config when working across multiple repos."}
{"kind":"workflow","name":"setup","steps":["codanna init","codanna --config .codanna/settings.toml add-dir src","codanna --config .codanna/settings.toml add-dir tests","codanna --config .codanna/settings.toml index","codanna --config .codanna/settings.toml serve --watch"]}
{"kind":"cmd","group":"core","commands":{"init":"Set up .codanna directory","--config .codanna/settings.toml":"Force repo-scoped config for all commands","index [PATH]":"Build searchable index","serve --watch":"Start MCP server with hot-reload"}}
{"kind":"cmd","group":"retrieve","commands":{"symbol <name>":"Find symbol by exact name","calls <name>":"What this function calls","callers <name>":"What calls this function","search <query>":"Full-text search","describe <name>":"Symbol information"}}
{"kind":"cmd","group":"mcp_cli","commands":{"find_symbol <name>":"Exact name lookup","search_symbols query:<text>":"Fuzzy text search","get_calls <name>":"Call graph outbound","find_callers <name>":"Call graph inbound","analyze_impact <name>":"Full dependency graph","semantic_search_docs query:<text>":"Semantic search","semantic_search_with_context query:<text>":"Search with relationships"}}
{"kind":"tool","name":"find_symbol","params":"<name>","purpose":"Exact symbol lookup"}
{"kind":"tool","name":"search_symbols","params":"query, kind, limit","purpose":"Fuzzy text search"}
{"kind":"tool","name":"get_calls","params":"<name> or symbol_id:N","purpose":"What this calls"}
{"kind":"tool","name":"find_callers","params":"<name> or symbol_id:N","purpose":"What calls this"}
{"kind":"tool","name":"analyze_impact","params":"<name> or symbol_id:N","purpose":"Full dependency analysis"}
{"kind":"tool","name":"semantic_search_docs","params":"query, limit","purpose":"Natural language search"}
{"kind":"tool","name":"semantic_search_with_context","params":"query","purpose":"Search with full context"}
{"kind":"tool","name":"search_documents","params":"query","purpose":"Search indexed docs"}
{"kind":"tool","name":"get_index_info","params":"none","purpose":"Index statistics"}
{"kind":"note","topic":"multirepo","items":["Each repo has its own .codanna/ directory","Each repo has its own .codannaignore file","Prefix commands with --config .codanna/settings.toml","Keep global ~/.codanna only for shared model cache, not project indexing state","MCP config per environment (Claude Code, OpenCode) must point to repo-local config"]}
{"kind":"cmd","group":"documents","commands":{"add-collection <NAME> <PATH>":"Add doc collection","index":"Index all collections","search <query>":"Search indexed docs"}}
{"kind":"config","files":{".codanna/settings.toml":"Main configuration",".codannaignore":"Exclude patterns (gitignore syntax)"}}
{"kind":"best_practice","id":"explore","text":"Start with semantic_search_with_context for exploration"}
{"kind":"best_practice","id":"exact","text":"Use find_symbol/search_symbols for exact lookups"}
{"kind":"best_practice","id":"hints","text":"Treat get_calls/find_callers/analyze_impact as hints (may be incomplete)"}
{"kind":"best_practice","id":"watch","text":"Use --watch for continuous MCP server during development"}
{"kind":"best_practice","id":"repo_config","text":"In multi-repo workflows, include --config .codanna/settings.toml on every codanna command."}
{"kind":"best_practice","id":"mcp_command","text":"Configure MCP command as: codanna --config .codanna/settings.toml serve --watch"}
{"kind":"troubleshoot","issue":"Index not found","fix":"Run codanna --config .codanna/settings.toml index"}
{"kind":"troubleshoot","issue":"MCP not connecting","fix":"Check codanna --config .codanna/settings.toml serve --watch is running"}
{"kind":"troubleshoot","issue":"Missing symbols","fix":"Check .codannaignore patterns"}
```
