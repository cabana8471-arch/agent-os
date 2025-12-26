# Output Summary Format

After writing detailed output to file, return ONLY this summary:

```
✅ [WORKFLOW_NAME] complete.
📁 Report: [OUTPUT_PATH]
📊 Summary: [KEY_METRICS]
⏱️ [STATUS/NEXT_STEP]
```

**Examples:**
- Implementation: `📊 Summary: 5 tasks completed, 3 files modified`
- Code Review: `📊 Summary: 2 critical, 3 major, 5 minor issues`
- Verification: `📊 Summary: All tests passing, UI verified`

**Rule:** Summary must be 4 lines or fewer. All detail goes in the file.
