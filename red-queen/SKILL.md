---
name: red-queen
description: "Adversarial evolutionary QA using the Digital Red Queen algorithm. Deterministic state machine (liza-advanced.nu) drives selection, regression, and gates. AI generates test commands only. Code and tests coevolve — each generation must defeat ALL previous generations. Use when you need aggressive QA, adversarial code review, CLI validation, regression hunting, or when the user says 'red queen', 'combative review', 'adversarial QA', 'stress test', or 'defend the throne'."
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
  - mcp__codanna__*
model: sonnet
user-invocable: true
argument-hint: [target path, CLI binary, or scope]
---

```jsonl
{"kind":"meta","skill":"red-queen","version":"8.0.0","updated":"2026-02","format":"jsonl-progressive"}
{"kind":"liza","path":"~/.claude/skills/red-queen/liza-advanced.nu","usage":"L=\"$HOME/.claude/skills/red-queen/liza-advanced.nu\"; nu $L <cmd>"}
{"kind":"principle","id":"deterministic_over_ai","text":"If it can be computed, compute it. AI generates test commands only.","ai_does":["Generate test commands","Fix code","Read docs","Discover promises"],"code_does":["Execute tests","Select survivors","Lock regressions","Gate transitions","Score landscape","Validate lineage"]}
{"kind":"principle","id":"exit_codes_truth","text":"Exit codes are ground truth, not AI interpretation of output.","survivor_check":"exit_code != expect_exit","no_ai_judgment":"AI never decides if something passed - shell exit code decides"}
{"kind":"principle","id":"done_when_lineage","text":"Every survivor is a permanent shell command with expected exit code.","storage":"done_when in blackboard YAML","ratchet":"validate runs ALL done_when, deterministic pass/fail"}
{"kind":"principle","id":"file_beads_immediately","text":"bd create happens same moment as task-add-check. Never defer.","timing":"File bead at survivor selection, not at session end"}
{"kind":"state_machine","id":"transitions","flow":"UNCLAIMED → claim → IN_PROGRESS → coder-submit → READY_FOR_REVIEW → validate → APPROVED → merge → MERGED"}
{"kind":"gate","id":"assert_can_submit","check":"Status is IN_PROGRESS, agent_id set","code":"liza lines 132-139"}
{"kind":"gate","id":"assert_can_review","check":"Status is READY_FOR_REVIEW, commit SHA present, validation results exist","code":"liza lines 142-156"}
{"kind":"gate","id":"assert_can_merge","check":"Status is APPROVED, review decision is APPROVED","code":"liza lines 159-167"}
{"kind":"gate","id":"assert_no_test_weakening","check":"Changed files don't touch tests/ unless explicitly allowed","code":"liza lines 170-177"}
{"kind":"cmd","id":"init","usage":"nu $L init","desc":"Initialize state machine"}
{"kind":"cmd","id":"task_add","usage":"nu $L task-add <name> --spec_ref README.md","desc":"Create task with spec reference"}
{"kind":"cmd","id":"task_add_check","usage":"nu $L task-add-check <task> \"<cmd>\" --expect_exit=0","desc":"Register done_when check"}
{"kind":"cmd","id":"claim","usage":"nu $L claim <task> red-queen","desc":"Claim the session"}
{"kind":"cmd","id":"gen_start","usage":"nu $L gen-start <task>","desc":"Start generation N"}
{"kind":"cmd","id":"gen_survivor","usage":"nu $L gen-survivor <task> \"<dim>\" \"<cmd>\" --severity <SEV>","desc":"Record survivor + file bead + update landscape"}
{"kind":"cmd","id":"gen_discard","usage":"nu $L gen-discard <task> \"<dim>\"","desc":"Record discard (no bug)"}
{"kind":"cmd","id":"landscape","usage":"nu $L landscape <task>","desc":"Compute fitness from blackboard"}
{"kind":"cmd","id":"coder_submit","usage":"nu $L coder-submit <task> red-queen","desc":"Transition to READY_FOR_REVIEW"}
{"kind":"cmd","id":"validate","usage":"nu $L validate <task>","desc":"Run ALL done_when checks"}
{"kind":"cmd","id":"lineage_replay","usage":"nu $L lineage-replay <task>","desc":"Verify current code defeats entire lineage"}
{"kind":"cmd","id":"carnage","usage":"nu $L carnage <task>","desc":"Track kill rate and lethality"}
{"kind":"cmd","id":"escalate","usage":"nu $L escalate <task>","desc":"Auto-promote severity for bleeding dimensions"}
{"kind":"cmd","id":"show","usage":"nu $L show --task=<task>","desc":"Display blackboard state"}
{"kind":"cmd","id":"mutate","usage":"nu $L mutate <task> <dir> --file <f> --function <fn>","desc":"Run cargo-mutants, missed → survivors","ref":"references/automated-weapons.md"}
{"kind":"cmd","id":"spec_mine","usage":"nu $L spec-mine <task> <dir> --bin <bin>","desc":"Extract promises from README/CLI/doctests","ref":"references/automated-weapons.md"}
{"kind":"cmd","id":"quality_gate","usage":"nu $L quality-gate <task> <dir>","desc":"Run FP/DRY/coverage checks","ref":"references/automated-weapons.md"}
{"kind":"cmd","id":"fowler_review","usage":"nu $L fowler-review <task> <dir> --complexity-threshold 15","desc":"AST analysis + test smells + security","ref":"references/automated-weapons.md"}
{"kind":"fitness","id":"landscape_scoring","formula":"survivors / tests_run per dimension","example":"error-handling: 5/8 = 0.625 (high fitness - keep probing)"}
{"kind":"allocation","fitness":">0.7","challengers":"6+","status":"HEMORRHAGING"}
{"kind":"allocation","fitness":">0.5","challengers":"5","status":"HIGH PRESSURE"}
{"kind":"allocation","fitness":">0.3","challengers":"4","status":"CONTESTED"}
{"kind":"allocation","fitness":">0.1","challengers":"3","status":"PROBING"}
{"kind":"allocation","fitness":"0","challengers":"2","status":"COOLING (double-tap, never single)"}
{"kind":"allocation","fitness":"exhausted 3+ gens","challengers":"0","status":"DORMANT (reawaken every 5 gens)"}
{"kind":"allocation","multiplier":"1.0x + 0.5x per 2 generations","status":"Escalating pressure"}
{"kind":"equilibrium","criteria":"3 consecutive zero-survivor generations","note":"The Queen never truly rests - dormant dims reawaken every 5 gens"}
{"kind":"severity","id":"CRITICAL","criteria":"Core workflow command returns wrong exit code","landscape":"dimension.fitness = 1.0 (maximum pressure)","examples":"0 on error, non-0 on success"}
{"kind":"severity","id":"MAJOR","criteria":"Documented command fails or produces wrong output","landscape":"dimension.fitness += 0.3","examples":"Verified by grep/diff, not AI"}
{"kind":"severity","id":"MINOR","criteria":"Output doesn't match documented format","landscape":"dimension.fitness += 0.1","examples":"Verified by pattern match, not AI"}
{"kind":"severity","id":"OBSERVATION","criteria":"AI-only judgment (no deterministic check)","landscape":"Not added to done_when","note":"Only severity that relies on AI"}
{"kind":"rule","id":"defeat_all_predecessors","text":"New code must beat entire lineage. Use lineage-replay to verify.","enforcement":"Every done_when from every generation must pass"}
{"kind":"rule","id":"anti_stagnation","text":"Dormant dimensions reawaken every 5 generations. The Queen never truly rests."}
{"kind":"rule","id":"severity_escalation","text":"3+ consecutive survivors in a dimension auto-promote severity. Persistent wounds become critical."}
{"kind":"rule","id":"double_tap","text":"Never send just 1 challenger to a cooling dimension. Always 2+. Confirm the kill."}
{"kind":"rule","id":"carnage_tracking","text":"Monitor kill rate and lethality per dimension. The codebase must constantly defend itself."}
{"kind":"anti_pattern","id":"ai_decides_test","problem":"Nondeterministic, unreproducible","fix":"Exit code comparison only"}
{"kind":"anti_pattern","id":"ai_scores_landscape","problem":"Subjective, varies between runs","fix":"survivors / tests_run ratio"}
{"kind":"anti_pattern","id":"ai_decides_stop","problem":"No convergence guarantee","fix":"Equilibrium: 0 survivors for 3 consecutive gens"}
{"kind":"anti_pattern","id":"ai_gates_transitions","problem":"Bypassable, inconsistent","fix":"assert-can-* functions in liza"}
{"kind":"anti_pattern","id":"tests_not_persisted","problem":"Lost between sessions","fix":"done_when in blackboard YAML"}
{"kind":"anti_pattern","id":"ai_judges_regression","problem":"Flaky, depends on prompt","fix":"validate runs all checks, exit code comparison"}
{"kind":"verdict","id":"crown_defended","criteria":"ALL done_when pass","output":"CROWN DEFENDED"}
{"kind":"verdict","id":"crown_contested","criteria":"MAJOR/MINOR survivors exist, all done_when pass","output":"CROWN CONTESTED"}
{"kind":"verdict","id":"crown_forfeit","criteria":"CRITICAL survivors exist","output":"CROWN FORFEIT"}
{"kind":"phase","id":"probe","step":0,"ai":["Read README, --help, source code. Discover promises."],"code":["Register each promise as done_when via task-add-check"]}
{"kind":"phase","id":"evolve","step":"N","ai":["Generate 3-10 test commands based on landscape"],"code":["gen-start, execute commands, gen-survivor or gen-discard"]}
{"kind":"phase","id":"regress","step":"N+1","ai":[],"code":["coder-submit, validate, lineage-replay, carnage"]}
{"kind":"phase","id":"automate","step":"parallel","ai":[],"code":["spec-mine, quality-gate, fowler-review, mutate"]}
{"kind":"ref","file":"references/protocol.md","use":"Full execution protocol with examples"}
{"kind":"ref","file":"references/automated-weapons.md","use":"mutate, spec-mine, quality-gate, fowler-review details"}
```

## Quick Start

```bash
L="$HOME/.claude/skills/red-queen/liza-advanced.nu"
nu $L init
nu $L task-add drq-session --spec_ref README.md
nu $L task-add-check drq-session "myapp --help" --expect_exit=0
nu $L claim drq-session red-queen
```

## Generation Loop

```bash
nu $L gen-start drq-session
# AI generates test commands...
# Execute each, exit code decides survivor vs discard
if [ $? -eq 0 ]; then  # BUG: should have failed
  nu $L gen-survivor drq-session "dim" "cmd" --severity CRITICAL
  bd create --title "[Red Queen] CRITICAL: <finding>" --type=bug
else
  nu $L gen-discard drq-session "dim"
fi
nu $L landscape drq-session
nu $L coder-submit drq-session red-queen
nu $L validate drq-session
```

**Version**: 8.0.0 | **Model**: Deterministic Adversarial Evolution
