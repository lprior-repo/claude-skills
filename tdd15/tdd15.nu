#!/usr/bin/env nu

# tdd15 — Deterministic backbone for 15-phase TDD workflow
# All state lives in YAML blackboard. Claude is the creative executor; nu is the state machine.

def data-dir [] {
  $env.HOME | path join ".local" "share" "tdd15"
}

const PHASES = [
  { id: 0,  name: "TRIAGE",          rewind_to: null, escalation_target: null }
  { id: 1,  name: "RESEARCH",        rewind_to: 0,    escalation_target: null }
  { id: 2,  name: "PLAN",            rewind_to: 1,    escalation_target: 0 }
  { id: 3,  name: "VERIFY",          rewind_to: 2,    escalation_target: 1 }
  { id: 4,  name: "RED",             rewind_to: 2,    escalation_target: 1 }
  { id: 5,  name: "GREEN",           rewind_to: 4,    escalation_target: 2 }
  { id: 6,  name: "REFACTOR",        rewind_to: 5,    escalation_target: 4 }
  { id: 7,  name: "MF#1",            rewind_to: 6,    escalation_target: 4 }
  { id: 8,  name: "IMPLEMENT",       rewind_to: 7,    escalation_target: 6 }
  { id: 9,  name: "VERIFY-CRITERIA", rewind_to: 8,    escalation_target: 5 }
  { id: 10, name: "FP-GATES",        rewind_to: 8,    escalation_target: 6 }
  { id: 11, name: "QA",              rewind_to: 8,    escalation_target: 5 }
  { id: 12, name: "MF#2",            rewind_to: 8,    escalation_target: 6 }
  { id: 13, name: "CONSISTENCY",     rewind_to: 12,   escalation_target: 8 }
  { id: 14, name: "LIABILITY",       rewind_to: 13,   escalation_target: 8 }
  { id: 15, name: "LANDING",         rewind_to: 14,   escalation_target: null }
]

const ROUTES = {
  simple:  [0, 4, 5, 6, 14, 15],
  medium:  [0, 1, 2, 4, 5, 6, 7, 9, 11, 15],
  complex: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
}

const BASE_MODELS = {
  "0": null, "1": "haiku", "2": "sonnet", "3": "sonnet",
  "4": "haiku", "5": "sonnet", "6": "haiku", "7": "sonnet",
  "8": "sonnet", "9": "haiku", "10": "haiku", "11": "haiku",
  "12": "opus", "13": "haiku", "14": null, "15": null
}

const BASE_THRESHOLDS = {
  "0": 1.0, "1": 1.0, "2": 1.0, "3": 1.0,
  "4": 1.0, "5": 1.0, "6": 1.0, "7": 1.0,
  "8": 1.0, "9": 1.0, "10": 1.0, "11": 1.0,
  "12": 1.0, "13": 1.0, "14": 1.0, "15": 1.0
}

const BASE_THINKING = {
  "0": null, "1": null, "2": "think step by step", "3": "think hard",
  "4": null, "5": "think about edge cases", "6": null, "7": "think hard, be rigorous",
  "8": null, "9": null, "10": null, "11": null,
  "12": "ultrathink", "13": null, "14": null, "15": null
}

# ── Blackboard persistence ─────────────────────────────────────────

def session-dir [id: string] {
  (data-dir) | path join $id
}

def blackboard-path [id: string] {
  session-dir $id | path join "blackboard.yml"
}

def load-blackboard [id: string] {
  let path = (blackboard-path $id)
  if not ($path | path exists) {
    print $"Error: session '($id)' not found at ($path)"
    exit 1
  }
  open $path
}

def save-blackboard [id: string, bb: record] {
  let path = (blackboard-path $id)
  $bb | to yaml | save -f $path
}

# ── Deterministic gates ─────────────────────────────────────────────

def assert-session-exists [id: string] {
  let path = (blackboard-path $id)
  if not ($path | path exists) {
    print $"Error: session '($id)' does not exist"
    exit 1
  }
}

def assert-not-halted [bb: record] {
  if $bb.status == "halted" {
    print "Error: session is HALTED — manual intervention required"
    exit 1
  }
}

def assert-on-route [bb: record, phase: int] {
  if not ($phase in $bb.route) {
    print $"Error: phase ($phase) is not on route ($bb.route)"
    exit 1
  }
}

def phase-name [phase: int] {
  let p = ($PHASES | where id == $phase | first)
  $p.name
}

# ── Threshold / model / thinking computation ────────────────────────

def compute-model [phase: int, attempt: int] {
  let base = ($BASE_MODELS | get ($phase | into string))
  if $base == null { return null }
  if $attempt <= 1 { return $base }
  if $attempt == 2 {
    match $base {
      "haiku" => "sonnet",
      "sonnet" => "opus",
      "opus" => "opus",
      _ => $base
    }
  } else {
    "opus"
  }
}

def compute-threshold [phase: int, attempt: int] {
  let base = ($BASE_THRESHOLDS | get ($phase | into string))
  match $attempt {
    1 => $base,
    2 => ([$base 0.8] | math max),
    3 => 0.6,
    _ => 0.5
  }
}

def compute-thinking [phase: int, attempt: int] {
  let base = ($BASE_THINKING | get ($phase | into string))
  match $attempt {
    1 => $base,
    2 => (if $base == null { "think hard" } else { "think hard" }),
    _ => "ultrathink"
  }
}

# ── Rewind logic ────────────────────────────────────────────────────

def compute-rewind-target [phase: int, attempt: int] {
  let p = ($PHASES | where id == $phase | first)
  if $attempt <= 1 {
    null  # Retry in-place
  } else if $attempt == 2 {
    $p.rewind_to  # Rewind to dependency
  } else {
    $p.escalation_target  # Deep rewind
  }
}

def do-rewind [id: string, bb: record, from_phase: int, target: int] {
  mut bb = $bb
  # Reset all phases between target and from_phase (exclusive of target, inclusive of from_phase)
  let route = $bb.route
  for p in $route {
    if $p > $target and $p <= $from_phase {
      let key = ($p | into string)
      let phase_data = ($bb.phases | get $key)
      $bb = ($bb | update phases ($bb.phases | upsert $key {
        status: "pending",
        gate_passed: false,
        attempts: $phase_data.attempts,
        threshold_used: null,
        model_used: null,
        started_at: null,
        completed_at: null,
        gate_result: {}
      }))
    }
  }
  $bb = ($bb | update current_phase $target)
  let entry = {
    from: $from_phase,
    to: $target,
    timestamp: (date now | format date "%Y-%m-%dT%H:%M:%S"),
    reason: $"gate-check failed at phase ($from_phase)"
  }
  $bb = ($bb | update rewind_log ($bb.rewind_log | append $entry))
  $bb
}

# ── Phase result evaluation ─────────────────────────────────────────

def evaluate-gate [phase: int, result: record] {
  # Phase 0 (TRIAGE): expects {passed: bool, complexity: string, route: list}
  if $phase == 0 {
    return ($result | get passed? | default false)
  }
  # Scored phases (MF#1=7, MF#2=12): expects {score: int, questions: record}
  if $phase == 7 or $phase == 12 {
    let score = ($result | get score? | default 0)
    let threshold = if $phase == 7 { 8 } else { 13 }
    return ($score >= $threshold)
  }
  # Parallel phase (FP-GATES=10): expects {checks: record, critical_count: int}
  if $phase == 10 {
    let crit = ($result | get critical_count? | default 1)
    return ($crit == 0)
  }
  # Boolean phases: expects {passed: bool}
  $result | get passed? | default false
}

# ══════════════════════════════════════════════════════════════════════
# COMMANDS
# ══════════════════════════════════════════════════════════════════════

# Initialize a new tdd15 session
def "main init" [
  id: string,           # Session identifier
  --language: string = "gleam",  # Programming language
  --complexity: string = ""      # Pre-set complexity (otherwise determined in Phase 0)
] {
  let dir = (session-dir $id)
  if ($dir | path exists) {
    print $"Error: session '($id)' already exists"
    exit 1
  }
  mkdir $dir

  let route = if $complexity != "" {
    $ROUTES | get $complexity
  } else {
    $ROUTES | get "complex"
  }

  mut phases = {}
  for p in $PHASES {
    let key = ($p.id | into string)
    $phases = ($phases | upsert $key {
      status: "pending",
      gate_passed: false,
      attempts: 0,
      threshold_used: null,
      model_used: null,
      started_at: null,
      completed_at: null,
      gate_result: {}
    })
  }

  let bb = {
    session_id: $id,
    created_at: (date now | format date "%Y-%m-%dT%H:%M:%S"),
    language: $language,
    complexity: (if $complexity != "" { $complexity } else { "pending" }),
    route: $route,
    zjj_session: $"tdd15-($id)",
    current_phase: 0,
    status: "active",
    phases: $phases,
    rewind_log: []
  }

  save-blackboard $id $bb

  # Try to create zjj workspace (non-fatal if zjj unavailable)
  let zjj_path = ($env.HOME | path join ".local" "bin" "zjj")
  if ($zjj_path | path exists) {
    try {
      ^$zjj_path add $"tdd15-($id)" --no-open
      print $"zjj workspace 'tdd15-($id)' created"
    } catch {
      print "Warning: zjj workspace creation failed (non-fatal)"
    }
  }

  print $"Session '($id)' initialized"
  print $"  Language: ($language)"
  print $"  Complexity: ($bb.complexity)"
  print $"  Route: ($route)"
  print $"  Blackboard: (blackboard-path $id)"
}

# Show session state
def "main show" [id: string] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  print ($bb | to yaml)
}

# Start a phase
def "main phase-start" [id: string, phase: int] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  assert-not-halted $bb
  assert-on-route $bb $phase

  if $bb.current_phase != $phase {
    print $"Error: current phase is ($bb.current_phase), not ($phase)"
    exit 1
  }

  let key = ($phase | into string)
  let phase_data = ($bb.phases | get $key)
  let attempt = $phase_data.attempts + 1
  let model = (compute-model $phase $attempt)
  let threshold = (compute-threshold $phase $attempt)
  let thinking = (compute-thinking $phase $attempt)

  let updated = ($bb | update phases ($bb.phases | upsert $key {
    status: "in_progress",
    gate_passed: $phase_data.gate_passed,
    attempts: $attempt,
    threshold_used: $threshold,
    model_used: $model,
    started_at: (date now | format date "%Y-%m-%dT%H:%M:%S"),
    completed_at: $phase_data.completed_at,
    gate_result: $phase_data.gate_result
  }))

  save-blackboard $id $updated

  print $"Phase ($phase) [(phase-name $phase)] started — attempt ($attempt)"
  print $"  Model: ($model)"
  print $"  Threshold: ($threshold)"
  print $"  Thinking: ($thinking)"
}

# Check gate result — exit 0=pass, 1=retry/rewind, 2=HALT
def "main gate-check" [id: string, phase: int, result_json: string] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  assert-not-halted $bb

  let result = ($result_json | from json)
  let passed = (evaluate-gate $phase $result)
  let key = ($phase | into string)
  let phase_data = ($bb.phases | get $key)
  let attempt = $phase_data.attempts

  if $passed {
    # Update phase as completed
    let updated = ($bb | update phases ($bb.phases | upsert $key {
      status: "completed",
      gate_passed: true,
      attempts: $attempt,
      threshold_used: $phase_data.threshold_used,
      model_used: $phase_data.model_used,
      started_at: $phase_data.started_at,
      completed_at: (date now | format date "%Y-%m-%dT%H:%M:%S"),
      gate_result: $result
    }))

    # Phase 0 special: update complexity and route from result
    let updated = if $phase == 0 and ($result | get complexity? | default "" | str length) > 0 {
      let complexity = ($result | get complexity)
      let route = if ($result | get route? | default [] | length) > 0 {
        $result | get route
      } else {
        $ROUTES | get $complexity
      }
      $updated | update complexity $complexity | update route $route
    } else {
      $updated
    }

    save-blackboard $id $updated
    print $"PASS: Phase ($phase) [(phase-name $phase)] gate passed"
    exit 0
  }

  # Failed — decide action based on current attempt
  # Attempt 1 fails → retry in-place (attempt 2 with base params)
  # Attempt 2 fails → rewind to rewind_to (attempt 3 with upgraded params)
  # Attempt 3 fails → rewind to escalation_target (but that would be attempt 4 → HALT)
  # Attempt 3+ fails → HALT
  if $attempt >= 3 {
    # HALT
    let updated = ($bb | update status "halted" | update phases ($bb.phases | upsert $key {
      status: "failed",
      gate_passed: false,
      attempts: $attempt,
      threshold_used: $phase_data.threshold_used,
      model_used: $phase_data.model_used,
      started_at: $phase_data.started_at,
      completed_at: (date now | format date "%Y-%m-%dT%H:%M:%S"),
      gate_result: $result
    }))
    save-blackboard $id $updated
    print $"HALT: Phase ($phase) [(phase-name $phase)] failed after ($attempt) attempts"
    print "Manual intervention required."
    exit 2
  }

  # Compute rewind target based on current attempt
  let rewind_target = (compute-rewind-target $phase $attempt)
  let next_attempt = $attempt + 1
  if $rewind_target == null {
    # Retry in place
    let updated = ($bb | update phases ($bb.phases | upsert $key {
      status: "pending",
      gate_passed: false,
      attempts: $attempt,
      threshold_used: $phase_data.threshold_used,
      model_used: $phase_data.model_used,
      started_at: $phase_data.started_at,
      completed_at: null,
      gate_result: $result
    }))
    save-blackboard $id $updated
    let model = (compute-model $phase $next_attempt)
    let threshold = (compute-threshold $phase $next_attempt)
    let thinking = (compute-thinking $phase $next_attempt)
    print $"RETRY: Phase ($phase) [(phase-name $phase)] — attempt ($next_attempt)"
    print $"  Model: ($model)"
    print $"  Threshold: ($threshold)"
    print $"  Thinking: ($thinking)"
    exit 1
  }

  # Rewind
  let rewound = (do-rewind $id $bb $phase $rewind_target)
  save-blackboard $id $rewound
  let model = (compute-model $rewind_target $next_attempt)
  let threshold = (compute-threshold $rewind_target $next_attempt)
  let thinking = (compute-thinking $rewind_target $next_attempt)
  print $"REWIND: Phase ($phase) [(phase-name $phase)] → Phase ($rewind_target) [(phase-name $rewind_target)]"
  print $"  Next attempt: ($next_attempt)"
  print $"  Model: ($model)"
  print $"  Threshold: ($threshold)"
  print $"  Thinking: ($thinking)"
  exit 1
}

# Advance to next phase in route
def "main advance" [id: string] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  assert-not-halted $bb

  let current = $bb.current_phase
  let route = $bb.route
  let idx = ($route | enumerate | where item == $current | first | get index)
  let next_idx = $idx + 1

  if $next_idx >= ($route | length) {
    # Workflow complete
    let updated = ($bb | update status "completed")
    save-blackboard $id $updated
    print "COMPLETE: All phases finished"
    exit 0
  }

  let next_phase = ($route | get $next_idx)
  let updated = ($bb | update current_phase $next_phase)
  save-blackboard $id $updated
  print $"Advanced: Phase ($current) [(phase-name $current)] → Phase ($next_phase) [(phase-name $next_phase)]"
}

# Rewind to a specific phase
def "main rewind" [id: string, target: int] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  assert-not-halted $bb
  assert-on-route $bb $target

  let from = $bb.current_phase
  if $target >= $from {
    print $"Error: target ($target) must be before current phase ($from)"
    exit 1
  }

  let rewound = (do-rewind $id $bb $from $target)
  save-blackboard $id $rewound
  print $"Rewound: Phase ($from) [(phase-name $from)] → Phase ($target) [(phase-name $target)]"
}

# Print computed threshold for current attempt
def "main threshold" [id: string, phase: int] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  let key = ($phase | into string)
  let attempt = (($bb.phases | get $key).attempts | default 0) + 1
  print (compute-threshold $phase $attempt)
}

# Print computed model for current attempt
def "main model" [id: string, phase: int] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  let key = ($phase | into string)
  let attempt = (($bb.phases | get $key).attempts | default 0) + 1
  print (compute-model $phase $attempt)
}

# Full status with ASCII DAG
def "main status" [id: string] {
  assert-session-exists $id
  let bb = (load-blackboard $id)

  print $"Session: ($bb.session_id)"
  print $"Status: ($bb.status)"
  print $"Language: ($bb.language)"
  print $"Complexity: ($bb.complexity)"
  print $"Current Phase: ($bb.current_phase) [(phase-name $bb.current_phase)]"
  print ""
  print "Route:"

  for p in $bb.route {
    let key = ($p | into string)
    let pd = ($bb.phases | get $key)
    let name = (phase-name $p)
    let marker = match $pd.status {
      "completed" => "✓",
      "in_progress" => "►",
      "failed" => "✗",
      _ => "○"
    }
    let suffix = if $p == $bb.current_phase { " ◄── current" } else { "" }
    print $"  ($marker) Phase ($p): ($name) [attempts: ($pd.attempts)]($suffix)"
  }

  if ($bb.rewind_log | length) > 0 {
    print ""
    print "Rewind Log:"
    for entry in $bb.rewind_log {
      print $"  ($entry.timestamp): Phase ($entry.from) → Phase ($entry.to) — ($entry.reason)"
    }
  }
}

# Re-validate all completed gates (ratchet check)
def "main validate" [id: string] {
  assert-session-exists $id
  let bb = (load-blackboard $id)
  mut all_ok = true

  for p in $bb.route {
    let key = ($p | into string)
    let pd = ($bb.phases | get $key)
    if $pd.status == "completed" and not $pd.gate_passed {
      print $"INVALID: Phase ($p) [(phase-name $p)] marked completed but gate not passed"
      $all_ok = false
    }
  }

  if $all_ok {
    print "All completed phases have valid gates ✓"
    exit 0
  } else {
    exit 1
  }
}

# Land session: zjj done + cleanup
def "main land" [id: string] {
  assert-session-exists $id
  let bb = (load-blackboard $id)

  if $bb.status != "completed" and $bb.status != "active" {
    print $"Error: session status is '($bb.status)', expected 'completed' or 'active'"
    exit 1
  }

  # Try zjj done
  let zjj_path = ($env.HOME | path join ".local" "bin" "zjj")
  if ($zjj_path | path exists) {
    try {
      ^$zjj_path done $bb.zjj_session
      print $"zjj workspace '($bb.zjj_session)' completed"
    } catch {
      print "Warning: zjj done failed (non-fatal)"
    }
  }

  let updated = ($bb | update status "completed")
  save-blackboard $id $updated
  print $"Session '($id)' landed"
}

# Destructive reset
def "main reset" [id: string] {
  let dir = (session-dir $id)
  if ($dir | path exists) {
    rm -rf $dir
    print $"Session '($id)' reset — all data removed"
  } else {
    print $"Session '($id)' not found"
  }
}

# Print full DAG with rewind arrows
def "main dag" [] {
  print "tdd15 Phase DAG"
  print "═══════════════"
  print ""
  for p in $PHASES {
    let rw = if $p.rewind_to != null {
      let rw_name = (phase-name $p.rewind_to)
      $" ──rewind→ ($p.rewind_to):($rw_name)"
    } else { "" }
    let esc = if $p.escalation_target != null {
      let esc_name = (phase-name $p.escalation_target)
      $" ──escalate→ ($p.escalation_target):($esc_name)"
    } else { "" }
    print $"  ($p.id | fill -a right -w 2): ($p.name | fill -a left -w 16)($rw)($esc)"
  }
  print ""
  print "Escalation: attempt 2 → rewind_to, attempt 3 → escalation_target, attempt 4+ → HALT"
}

# Print route for a complexity level
def "main route" [complexity: string] {
  if not ($complexity in ["simple", "medium", "complex"]) {
    print "Error: complexity must be simple, medium, or complex"
    exit 1
  }
  let route = ($ROUTES | get $complexity)
  let names = ($route | each {|p| $"($p):(phase-name $p)" })
  print $"Route \(($complexity)\): ($names | str join ' → ')"
}

# Help text
def main [] {
  print "tdd15 — Deterministic TDD backbone"
  print ""
  print "Commands:"
  print "  tdd15 init <id> [--language <lang>] [--complexity <level>]"
  print "  tdd15 show <id>"
  print "  tdd15 phase-start <id> <phase>"
  print "  tdd15 gate-check <id> <phase> '<result-json>'"
  print "  tdd15 advance <id>"
  print "  tdd15 rewind <id> <target>"
  print "  tdd15 threshold <id> <phase>"
  print "  tdd15 model <id> <phase>"
  print "  tdd15 status <id>"
  print "  tdd15 validate <id>"
  print "  tdd15 land <id>"
  print "  tdd15 reset <id>"
  print "  tdd15 dag"
  print "  tdd15 route <complexity>"
  print ""
  print "State: ~/.local/share/tdd15/<session>/blackboard.yml"
}
