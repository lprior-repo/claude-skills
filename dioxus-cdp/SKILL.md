---
name: dioxus-cdp
description: Auto-debugging tool for Dioxus applications using pure-Rust fantoccini (WebDriver). Use when debugging Dioxus UI, replicating bugs, or interacting with the DOM.
argument-hint: ""
allowed-tools: [bash, read, edit, write, glob, grep]
model: gemini-3-flash-preview
---

# Skill: dioxus-cdp

```jsonl
{"k":"meta","s":"dioxus-cdp","v":"2.0.0","f":"jsonl-min"}
{"k":"mission","g":"Empower the AI agent to debug and interact with Dioxus web/desktop apps via pure-Rust WebDriver automation."}
{"k":"rule","id":"pre-requisite-1","t":"Start the Dioxus app: `dx serve --platform web > /tmp/dx-serve.log 2>&1 &`. Wait for port 8080."}
{"k":"rule","id":"pre-requisite-2","t":"Start ChromeDriver: `~/.local/bin/chromedriver --port=4444 > /tmp/chromedriver.log 2>&1 &`."}
{"k":"tool","name":"dioxus-agent-rs","path":"~/.local/src/dioxus-agent-rs/target/release/dioxus-agent-rs","desc":"Pure-Rust WebDriver CLI for Dioxus automation using fantoccini."}
{"k":"workflow","id":"debug-cycle","steps":["Run `dx serve` in background","Start chromedriver on port 4444","Use `dioxus-agent-rs dom` to read the UI state","Use `dioxus-agent-rs screenshot <path>` for visual inspection","Use `dioxus-agent-rs click <selector>` or `text <selector> <value>` to interact"]}
{"k":"command","cmd":"dioxus-agent-rs dom","desc":"Returns the full HTML of the currently running Dioxus application window."}
{"k":"command","cmd":"dioxus-agent-rs eval \"<js>\"","desc":"Evaluates arbitrary JavaScript in the context of the Dioxus app and returns the JSON result."}
{"k":"command","cmd":"dioxus-agent-rs click \"<css-selector>\"","desc":"Simulates a click on an element using CSS selector."}
{"k":"command","cmd":"dioxus-agent-rs text \"<css-selector>\" \"<value>\"","desc":"Sets text on an input field using CSS selector."}
{"k":"command","cmd":"dioxus-agent-rs screenshot \"<path>\"","desc":"Takes a full-page screenshot and saves to the specified path."}
{"k":"command","cmd":"dioxus-agent-rs repl","desc":"Starts an interactive REPL session allowing rapid-fire commands without spinning up a new ChromeDriver session each time. Extremely useful for visual debugging."}
```
