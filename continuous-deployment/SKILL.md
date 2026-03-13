---
name: continuous-deployment
description: "rust, lean, one-piece-flow, small-batch, vertical-slice, shift-left, continuous-integration, continuous-deployment, velocity, bitter-truth, boring-code, yagni, moon, moonrepo, validation, tests, fmt, clippy, lint, tdd15, jj, zjj, planner"
allowed-tools: ["bash"]
version: 1.0.0
---

```jsonl
{"kind":"meta","skill":"continuous-deployment","version":"1.0.0","format":"markdown-with-embedded-jsonl","scope":"rust-agent-behavior","core_truths":["velocity_is_king","validation_over_trust"]}
{"kind":"claude_best_practice","id":"velocity_is_king","text":"VELOCITY IS KING (MANDATORY): one-piece flow by default. Small slice -> moon run :ci -> next slice. If time-to-green slows, slice is too big."}
{"kind":"claude_best_practice","id":"validation_over_trust","text":"VALIDATION OVER TRUST: only green moon gates count as truth. No green, no claims."}
{"kind":"claude_best_practice","id":"inventory_is_waste","text":"Inventory is waste: unvalidated jj diff is liability. Keep edit->green close to zero."}

{"kind":"rule","id":"slice_then_gate","level":"warn","text":"After every slice, run moon run :ci before expanding scope.","bans":["batching multiple slices before gates","continuing while gates are red"],"preferred":["moon run :ci"],"notes":["Transaction cost is validation. Drive it toward zero by keeping slices tiny."]}
{"kind":"rule","id":"small_batch_caps","level":"warn","text":"Soft cap: avoid >100 LOC OR >15 minutes of work without a green moon run :ci.","bans":["200+ LOC without gates","30+ minutes without gates"],"preferred":["validate at least every 15 minutes","keep jj diff tiny"],"notes":["Continuous flow ratio drifts above 1 when you batch. Shrink the slice."]}
{"kind":"rule","id":"moon_fallback","level":"warn","text":"If moon run :ci fails due to unrelated tasks, validate your changed crate with targeted moon or cargo.","bans":["give up on validation"],"preferred":["moon run :<crate>:test","moon run :<crate>:lint","cargo test -p <crate>","cargo clippy -p <crate> -- -D warnings","cargo fmt --check"],"notes":["Validate what you changed; then track the unrelated breakage."]}
{"kind":"rule","id":"check_my_changes_only","level":"warn","text":"Do not expand lint work. Distinguish NEW clippy warnings from pre-existing ones.","bans":["introduce new warnings"],"preferred":["compare vs main baseline","fix only what you introduced"],"notes":["If clippy already fails on main, do not add more debt."]}
{"kind":"rule","id":"jj_only","level":"warn","text":"Use jj only for VCS porcelain.","bans":["git status","git diff","git log","git commit"],"preferred":["jj status","jj diff","jj log -n 10","jj describe -m '...'","jj commit -m '...'"],"notes":["Your repos may contain .git, but workflow is jj."]}
{"kind":"rule","id":"zjj_context","level":"warn","text":"When using zjj workspaces, validate and diff inside the workspace and sync early/often.","bans":["running gates from wrong directory","late sync"],"preferred":["zjj whereami","zjj sync","zjj diff main","moon run :ci"],"notes":["Workspace isolation supports velocity by keeping slices clean."]}
{"kind":"rule","id":"hooks_are_gates","level":"warn","text":"Treat hooks as gates (gitleaks, etc). Fix/allowlist, do not bypass.","bans":["--no-verify (unless user asked)","disabling hooks"],"preferred":["run hook locally","add allowlist/baseline"],"notes":["If blocked, shrink slice and remove secret-like fixtures."]}
{"kind":"rule","id":"tdd15_new_behavior","level":"warn","text":"For NEW behavior, prefer /tdd15 (Rust) for RED->GREEN->REFACTOR with tiny steps.","bans":["new behavior without a failing test"],"preferred":["/tdd15 <session-id>"]}

{"kind":"pattern","id":"tight_loop","text":"Tight loop (velocity defaults)","example":"jj diff\nmoon run :ci\n# if :ci fails unrelated\nmoon run :<crate>:test || cargo test -p <crate>\nmoon run :<crate>:lint || cargo clippy -p <crate> -- -D warnings\nmoon run :<crate>:fmt || cargo fmt --check\n","notes":["Keep jj diff small; validate; then take the next slice."]}
{"kind":"pattern","id":"zjj_flow","text":"zjj flow (isolate then ship slices)","example":"zjj add feature-name\nzjj whereami\nzjj sync\njj diff\nmoon run :ci\nzjj diff main\nzjj done -m 'slice: <what changed>'\n","notes":["Do all jj/moon work inside the zjj workspace."]}
{"kind":"gate","id":"default_gate","commands":["moon run :ci"],"notes":["Soft gate. Green is the only signal."]}
```
