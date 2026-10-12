Read ~/.config/agents/skills/workmux/specs/task-md.md
Implement only the file plan. Spec wins over existing helper/AGENTS.md drift.

TASK_FILE=$(tmux-tasklog path). Append `- [ ] T<n> implement task.md spec` (next free n). Mark `[>]` while working, `[x]` when done. Write Notes only for facts another agent needs.

Do not add features, files, or e2e cases outside the spec. Stop when `--self-check` exits 0 and prefix+t opens a file named task.md.
