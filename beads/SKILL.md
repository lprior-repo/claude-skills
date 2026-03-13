---
name: bd
description: Autonomous Execution Doctrine for `beads`.
argument-hint: "[command] [args]"
allowed-tools: [bash, read, edit, write, glob, grep]
model: gemini-3-flash-preview
---

# Skill: bd

```jsonl
{"k":"meta","s":"bd","v":"1.0.1","f":"jsonl-min"}
{"k":"input","arg":"$CMD","rule":"Default: `bd ready`"}
{"k":"mission","g":"Externalize executive function via beads graph."}
{"k":"rule","id":"doctrine","t":"No TODO.md. Sync start/exit. Claim before work. Use discovered-from."}
{"k":"workflow","id":"loop","s":["sync","ready/insights","claim","show","finalize","sync+push"],"ref":"workflow.md"}
{"k":"prioritize","opts":["Foundation:PageRank","Risk:Betweenness","Value:Hubs"],"ref":"ontology.md"}
{"k":"anti","id":"amnesia","p":"Exit w/o sync+push","f":"Force 'write-before-exit'"}
{"k":"ref","f":"workflow.md","u":"Ops loop"}
{"k":"ref","f":"ontology.md","u":"Graph semantics"}
```
