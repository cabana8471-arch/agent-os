# Output Protocol

> Version: 1.0.0
> Purpose: Context window optimization through file-based output

This protocol defines how agents should return results to preserve context window space.

---

## Core Principle

**Write comprehensive output to files. Return only a summary to the conversation.**

This approach:
- Preserves context for multi-step workflows
- Enables detailed reports without conversation bloat
- Allows easy review of agent output in dedicated files

---

## Output Format

### Step 1: Write Full Output to File

Use the Write tool to save your complete output to the designated path:

```
agent-os/specs/[spec-path]/[output-type].md
```

Common output paths:
- Implementation summary: `agent-os/specs/[spec-path]/implementation/summary.md`
- Code review: `agent-os/specs/[spec-path]/implementation/code-review.md`
- Verification report: `agent-os/specs/[spec-path]/verification/report.md`
- Task list: `agent-os/specs/[spec-path]/tasks.md`

### Step 2: Return Summary to Conversation

After writing the file, return ONLY this format:

```
✅ [WORKFLOW_NAME] complete.
📁 Report: [OUTPUT_PATH]
📊 Summary: [KEY_METRICS]
⏱️ [ADDITIONAL_CONTEXT]
```

### Examples by Workflow Type

**Implementation:**
```
✅ Implementation complete.
📁 Report: agent-os/specs/user-auth/implementation/summary.md
📊 Summary: 5 tasks completed, 3 files modified
⏱️ Ready for code review
```

**Code Review:**
```
✅ Code review complete.
📁 Report: agent-os/specs/user-auth/implementation/code-review.md
📊 Summary: 2 critical, 3 major, 5 minor issues
⏱️ Status: Changes Required
```

**Verification:**
```
✅ Verification complete.
📁 Report: agent-os/specs/user-auth/verification/report.md
📊 Summary: All tests passing, UI verified
⏱️ Status: Ready for merge
```

**Planning:**
```
✅ Product mission created.
📁 Report: agent-os/product/mission.md
📊 Summary: Vision, target users, and success metrics defined
⏱️ Ready for roadmap planning
```

---

## What NOT to Include in Summary

- Full file contents
- Complete code snippets
- Detailed issue descriptions
- Long lists of changes
- Explanations or reasoning

All detailed content goes in the written file.

---

## Conversation Context Guidelines

### Lazy Loading Previous Reports

When you need to reference previous agent output:

| Situation | Action |
|-----------|--------|
| Check if issue exists | Grep for ID in previous report |
| Compare changes | Read only specific section needed |
| Verify status | Search for markers in output file |
| Full context needed | Read entire file only when necessary |

### Memory Management

1. **Write immediately** - Don't accumulate findings in context
2. **Reference by path** - Use `file.ts:42` instead of quoting code
3. **Summarize patterns** - Group similar items into categories
4. **Clear after writing** - Move to next task after saving output

---

## Implementation Checklist

Before returning your summary:

- [ ] Full output written to designated file path
- [ ] Summary is 4 lines or fewer
- [ ] No detailed content in conversation
- [ ] Path to report is accurate
- [ ] Key metrics are included

---

## Error Handling

If you cannot write to the designated path:

1. Note the issue in your summary
2. Provide a brief inline summary (max 10 lines)
3. Suggest alternative output location
4. Request guidance from orchestrator

```
⚠️ [WORKFLOW_NAME] complete with output issue.
📁 Could not write to: [INTENDED_PATH]
📊 Summary: [KEY_METRICS]
💡 Alternative: Output available inline below (truncated)
```
