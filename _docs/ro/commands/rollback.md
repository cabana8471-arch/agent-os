# Comandă: /agent-os:rollback

## 📋 Ce Face

Emergency revert. Rollback to previous git commit (code rollback), previous spec, or previous database state.

Output: Rollback executed, state restored, incident report

---

## ✅ Când să Folosești

- Deploy went wrong
- Critical bug discovered post-release
- Urgent: need to restore last known good state

---

## ❌ Când SĂ NU Folosești

- Planning only ("what if we rollback?")
- Preventive (use git branches instead)

---

## 📤 Output Generat

- Git history restored (HEAD at previous commit)
- Database migrations reversed (if applicable)
- Rollback incident report (what was rolled back, why)

---

## 💡 Exemplu

```bash
/agent-os:rollback --target "commit_abc123" --type code
```

**Output**:
```
✅ Rollback complete
🔄 Code reverted from: commit_xyz789 → commit_abc123
📝 Incident report: agent-os/agent-os:rollback/incident-2024-01-15.md
🔍 Next steps: debug and re-deploy
```

---

## ⚙️ Flags

```bash
/agent-os:rollback --commit abc123      # Specific commit
/agent-os:rollback --last-stable        # Last known good (tag)
/agent-os:rollback --type code          # Code only
/agent-os:rollback --type spec          # Spec only
/agent-os:rollback --type database      # DB migrations only
```

---

## 🔗 Comenzi Legate

**Independent** - emergency use only

---

## 💭 Best Practices

- ✅ Use git branches (prevent rollback needs)
- ✅ Tag releases (easy to rollback to)
- ✅ Test before deploy (catch issues early)
- ✅ Monitor after deploy (detect issues quickly)
- ❌ Frequent rollbacks = process broken

---

**Gata? Fix root cause și re-deploy!** 🚀
