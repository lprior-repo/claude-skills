# Skill Design Examples

## Good: Focused Description

- "Generate a PR summary from `gh` output. Use when asked to summarize branch changes for reviewers."

Why it works: clear behavior + clear trigger conditions.

## Bad: Vague Description

- "Helps with GitHub stuff."

Why it fails: weak trigger language, ambiguous behavior.

## Good: Progressive Disclosure

- `SKILL.md`: frontmatter + JSONL policy + links
- `reference.md`: detailed guidance
- `templates.md`: reusable skeletons

Why it works: fast load path for common calls, deep docs available when needed.

## Bad: Monolithic SKILL.md

- One file with hundreds of lines of mixed policy, templates, examples, and scripts.

Why it fails: high token cost, low scanability, brittle updates.
