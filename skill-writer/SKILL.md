---
name: skill-writer
description: Meta skill for authoring Claude skills using contract-first design, JSONL-first prompts, and progressive disclosure docs. Use when creating or improving SKILL.md files.
argument-hint: [skill to create, refactor, or review]
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
model: sonnet
user-invocable: true
version: 1.1.0
---

```jsonl
{"kind":"meta","skill":"skill-writer","version":"1.1.0","format":"jsonl-progressive","mode":"contract-first","token_strategy":"top_block_plus_jsonl"}
{"kind":"input","arguments":"$ARGUMENTS","rule":"If no explicit arguments are provided, infer target from current request context and repository skill conventions."}
{"kind":"mission","goal":"Design and write high-quality Claude skills with clear activation behavior, least-privilege tools, and predictable outputs."}
{"kind":"rule","id":"proper_top_block","text":"Always produce valid YAML frontmatter first, then keep the operational payload JSONL-oriented for token efficiency."}
{"kind":"rule","id":"progressive_disclosure","text":"Keep SKILL.md compact. Move long guidance to support docs and link them clearly.","refs":["reference.md","templates.md","checklist.md","examples.md"]}
{"kind":"rule","id":"least_privilege","text":"Set allowed-tools to the minimum toolset required for the skill's actual job."}
{"kind":"rule","id":"invocation_control","text":"Choose invocation flags by risk: side effects => disable-model-invocation true; background context => user-invocable false."}
{"kind":"decision","id":"invocation_mode_matrix","options":[{"mode":"default","when":"advisory or low-risk skills","frontmatter":{}},{"mode":"manual_only","when":"deploy, commit, billing, destructive operations","frontmatter":{"disable-model-invocation":true}},{"mode":"model_only","when":"background knowledge overlays","frontmatter":{"user-invocable":false}}]}
{"kind":"workflow","id":"author_or_refactor_skill","steps":["Define skill contract (goal, trigger language, invocation mode)","Select frontmatter fields intentionally","Draft concise SKILL.md behavior block","Push heavy detail into support docs","Link support docs from SKILL.md","Run checklist validation before finalizing"]}
{"kind":"frontmatter_fields","fields":["name","description","argument-hint","allowed-tools","model","disable-model-invocation","user-invocable","context","agent","hooks"]}
{"kind":"output_contract","for":"meta_skill_response","sections":["1) Proposed skill contract","2) Final frontmatter block","3) SKILL.md body","4) Support files to add/update","5) Rationale for key decisions"]}
{"kind":"anti_pattern","id":"bloated_skill_md","problem":"Long monolithic SKILL.md with mixed reference and execution details","fix":"Use progressive disclosure docs and link by purpose"}
{"kind":"anti_pattern","id":"ambiguous_description","problem":"Description too vague to trigger reliably","fix":"Include what + when + natural trigger wording"}
{"kind":"anti_pattern","id":"tool_over_permissioning","problem":"Granting broad tools by default","fix":"Constrain allowed-tools to actual needs"}
{"kind":"ref","file":"reference.md","use":"Frontmatter guidance, invocation decisions, and execution patterns"}
{"kind":"ref","file":"templates.md","use":"Copy/paste templates for common skill archetypes"}
{"kind":"ref","file":"checklist.md","use":"Preflight and acceptance checks before shipping a skill"}
{"kind":"ref","file":"examples.md","use":"High-signal examples of good and bad skill designs"}
```

Additional resources for progressive disclosure:
- [reference.md](reference.md)
- [templates.md](templates.md)
- [checklist.md](checklist.md)
- [examples.md](examples.md)
