#!/usr/bin/env nu

# Super Velocity Throughput (SVT) - Batch Orchestrator
# Usage: nu svt-runner.nu [batch_size] [target_dir]

def get_open_port [start_port: int] {
    mut port = $start_port
    loop {
        let p = $port
        let ss_output = (try { ^ss -tuln | lines } catch { [] })
        let is_used = ($ss_output | any {|line| $line =~ $":($p) "})
        if not $is_used {
            return $port
        }
        $port = $port + 1
    }
    return $port
}

def check_deps [] {
    let deps = ["jq", "curl", "ss", "opencode", "bd", "bash"]
    for dep in $deps {
        if (which $dep | is-empty) {
            print -e $"Error: Required dependency '($dep)' is not installed."
            exit 1
        }
    }
}

def main [
    batch_size: int = 30,
    target_dir: string = ".",
] {
    let base_port = (random int 4500..5500)
    let password = "svt_secret_password"
    let provider = ($env.SVT_PROVIDER? | default "minimax-coding-plan")
    let model = ($env.SVT_MODEL? | default "MiniMax-M2.5-highspeed")

    print $"SVT: Initializing Super Velocity Throughput in ($target_dir)..."
    cd $target_dir
    check_deps

    print $"SVT: Finding up to ($batch_size) ready beads..."
    let beads_str = (try { ^bd ready --json } catch { "[]" })
    let beads_json = (if ($beads_str | is-empty) { [] } else { try { $beads_str | from json } catch { [] } })
    
    if ($beads_json | is-empty) {
        print "SVT: No ready beads found via 'bd ready'. Exiting gracefully."
        exit 0
    }

    let bead_ids = ($beads_json | take $batch_size | get id)
    let actual_batch = ($bead_ids | length)
    print $"SVT: Claimed ($actual_batch) beads for processing."

    mut servers = []

    print $"SVT: Spinning up ($actual_batch) opencode serve instances, starting around port ($base_port)..."
    mut current_port = $base_port

    for bead_id in $bead_ids {
        let port = (get_open_port $current_port)
        $current_port = $port + 1

        print $"SVT: Starting server for ($bead_id) on port ($port)..."
        
        let log_file = $"/tmp/opencode_svt_($port).log"
        let start_cmd = $"OPENCODE_SERVER_PASSWORD=($password) opencode serve --port ($port) >($log_file) 2>&1 & echo $!"
        
        let pid_str = (^bash -c $start_cmd | str trim)
        let pid = ($pid_str | into int)

        $servers = ($servers | append {
            bead_id: $bead_id,
            port: $port,
            pid: $pid,
            session: null,
            status: "starting"
        })
    }

    print "SVT: Waiting for servers to initialize..."
    sleep 5sec

    # Dispatch
    mut active_servers = []
    for srv in $servers {
        let port = $srv.port
        let bead_id = $srv.bead_id
        
        let sid = (try {
            let resp = (http post --user opencode --password $password --content-type application/json --allow-errors $"http://localhost:($port)/session" {title: $"svt-bead-($bead_id)"})
            $resp.id
        } catch { null })

        if ($sid == null) {
            print $"SVT: Failed to create session on port ($port) for bead ($bead_id)"
            $active_servers = ($active_servers | append ($srv | update status "failed_to_start"))
            continue
        }
        
        let payload = {
            model: { providerID: $provider, modelID: $model },
            agent: "build",
            parts: [{ type: "text", text: $"Load the `go-skill` and execute states 0 to 8 for Bead ID: ($bead_id). Do not stop until State 8 'Landing' is reached or a hard failure occurs. Enforce strict design-by-contract." }]
        }

        # Fix mutating variable capture inside catch block
        let dispatch_success = (try {
            let _ = (http post --user opencode --password $password --content-type application/json --allow-errors $"http://localhost:($port)/session/($sid)/prompt_async" $payload)
            true
        } catch { false })

        if $dispatch_success {
            print $"SVT: Dispatched Bead ($bead_id) -> Session ($sid) on Port ($port)"
            $active_servers = ($active_servers | append ($srv | update session $sid | update status "running"))
        } else {
            print $"SVT: Failed to dispatch prompt to port ($port) for bead ($bead_id)"
            $active_servers = ($active_servers | append ($srv | update session $sid | update status "failed_to_dispatch"))
        }
    }
    $servers = $active_servers

    # Polling
    print "SVT: Entering polling loop..."
    mut pending = ($servers | where status == "running" | length)
    
    while $pending > 0 {
        sleep 10sec
        print -n "."

        mut updated_servers = []
        for srv in $servers {
            if $srv.status != "running" {
                $updated_servers = ($updated_servers | append $srv)
                continue
            }

            let port = $srv.port
            let sid = $srv.session

            let status_resp = (try { http get --user opencode --password $password --allow-errors $"http://localhost:($port)/session/status" } catch { {} })
            
            let is_busy = (if ($status_resp | is-empty) { false } else { try { ($status_resp | get $sid) != null } catch { false } })

            if not $is_busy {
                let latest = (try { http get --user opencode --password $password --allow-errors $"http://localhost:($port)/session/($sid)/message?limit=1" } catch { [] })
                
                let completed_time = (if ($latest | is-empty) { null } else { try { $latest | get 0.info.time.completed } catch { null } })

                if $completed_time != null {
                    print $"\n[✔] Bead ($srv.bead_id) completed its execution cycle."
                    $updated_servers = ($updated_servers | append ($srv | update status "completed"))
                } else {
                    print $"\n[!] Bead ($srv.bead_id) session ($sid) is idle but missing completion time. Marking as failed."
                    $updated_servers = ($updated_servers | append ($srv | update status "failed"))
                }
                $pending = $pending - 1
            } else {
                $updated_servers = ($updated_servers | append $srv)
            }
        }
        $servers = $updated_servers
    }

    # Generate Report
    print "\n=========================================="
    print "      SVT EXECUTION MATRIX REPORT         "
    print "=========================================="
    
    mut report = {}
    for srv in $servers {
        let port = $srv.port
        let sid = $srv.session
        let bead_id = $srv.bead_id
        
        mut final_text = "N/A"
        mut tools_used = "None"

        if $sid != null {
            let latest = (try { http get --user opencode --password $password --allow-errors $"http://localhost:($port)/session/($sid)/message?limit=1" } catch { [] })
            
            let maybe_text = (if ($latest | is-empty) { null } else { try { $latest | get 0.parts.0.text } catch { null } })
            
            if $maybe_text != null {
                $final_text = ($maybe_text | str replace -a "\n" " " | str substring 0..150)
            } else {
                $final_text = "Error retrieving output"
            }
            
            let history = (try { http get --user opencode --password $password --allow-errors $"http://localhost:($port)/session/($sid)/message" } catch { [] })
            if ($history | is-not-empty) {
                try { $history | to json | save -f $"/tmp/svt_trace_($bead_id).json" }
                
                let tools = (try {
                    $history | get parts | flatten | where type == "tool-call" | get name | uniq | str join ", "
                } catch { "None" })
                
                if ($tools | is-empty) == false {
                    $tools_used = $tools
                }
            }
        }

        $report = ($report | insert $bead_id {
            session: $sid,
            port: $port,
            status: $srv.status,
            sub_agents_used: $tools_used,
            final_output_snippet: $"($final_text)..."
        })
    }
    
    let summary = {
        summary: $"Processed ($actual_batch) beads using ($model)"
    }
    let full_report = ($report | merge $summary)
    print ($full_report | to json)
    print "=========================================="
    print "SVT run complete."

    # Cleanup
    print "SVT: Tearing down opencode server pool..."
    for srv in $servers {
        if $srv.pid != null and $srv.pid != 0 {
            try { ^kill -9 $srv.pid } catch { }
        }
    }
}
