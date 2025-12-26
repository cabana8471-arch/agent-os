# Concept: Best Practices

Lessons learned from using Agent OS. Patterns that work, anti-patterns that don't.

---

## 📋 Development Workflow Best Practices

### ✅ DO

- ✅ **Start with Planning**: `/agent-os:plan-product` first, always
- ✅ **Write Specs**: Spec before code, every time
- ✅ **Iterative Implementation**: Per feature, not whole app
- ✅ **Review Code**: Even automated reviews are valuable
- ✅ **Test Early**: Unit tests, not just E2E
- ✅ **Commit Frequently**: Logical chunks, not big blobs
- ✅ **Document as You Go**: README, API docs, comments
- ✅ **Refactor Incrementally**: Small improvements, not rewrites

### ❌ DON'T

- ❌ **Skip Planning**: "Let's just code!" = chaos
- ❌ **Feature Without Spec**: Rework, wasted effort
- ❌ **Big Bang Implementations**: 50 tasks in 1 go = slow + risky
- ❌ **Ignore Code Review**: These are real issues
- ❌ **Test Last**: Should test during dev
- ❌ **Giant Commits**: Hard to review + revert
- ❌ **No Documentation**: Next dev suffers
- ❌ **Big Rewrites**: High risk, high cost

---

## 🔄 Commit Strategy

### Good Commit Pattern

```
1 feature = 1-3 commits

Example: Task CRUD API
- Commit 1: Database schema + models
- Commit 2: API endpoints
- Commit 3: Tests + documentation
```

**Benefits**:
- Easy to review (per commit)
- Easy to revert (if needed)
- Clear history

---

### Bad Commit Pattern

```
1 feature = 1 giant commit (500+ lines changed)
```

**Problems**:
- Hard to review
- Hard to revert
- Lost context

---

## 🚀 Phasing Strategy

### MVP First

```
Phase 1: Core features only (2-3 features)
  └─ Deploy, validate with users

Phase 2: Growth features (2-3 more)
  └─ Deploy, expand user base

Phase 3: Scale features (automation, perf)
  └─ Deploy, scale infrastructure
```

**Benefits**: Get to market fast, learn from users

---

### NOT All-At-Once

```
❌ Launch with 10 features at once
   Risk: Bugs in everything, no focus
```

---

## 🔍 Testing Strategy

### Test Pyramid

```
         E2E Tests (10%)
       /              \
      Integration     Tests (30%)
     /                    \
   Unit Tests (60%)
```

**Recommended Ratio**:
- 60% Unit tests (fast, isolated)
- 30% Integration tests (real dependencies)
- 10% E2E tests (user workflows)

---

### When to Test

- ✅ **During dev**: Unit test as you code
- ✅ **Before merging**: Integration + E2E
- ✅ **Before deploy**: Full test suite
- ❌ **After deploy**: Too late for testing

---

## 🔧 Error Handling Best Practices

### ✅ Good Error Handling

```
try {
  await createTask(data)
} catch (error) {
  if (error.code === 'VALIDATION_ERROR') {
    showUserMessage('Title required')
  } else if (error.code === 'AUTH_ERROR') {
    redirectToLogin()
  } else {
    logError(error)  // Log unexpected
    showGenericError('Something went wrong')
  }
}
```

**Benefits**: User-friendly, actionable

---

### ❌ Bad Error Handling

```
// Silent failure
try {
  await createTask(data)
} catch (error) {
  // Do nothing
}

// Generic message
catch (error) {
  showMessage('Error')  // Unhelpful
}
```

---

## 📊 Code Review Best Practices

### When Reviewing Code

- ✅ **Read thoroughly**: Don't skim
- ✅ **Run tests**: Don't assume they pass
- ✅ **Test manually**: Try edge cases
- ✅ **Check security**: SQL injection? XSS? Auth?
- ✅ **Ask questions**: "Why this approach?"
- ✅ **Suggest improvements**: Not demands
- ✅ **Approve when satisfied**: Don't block unnecessarily

### Code Review Checklist

```
Code Review Checklist:

Functionality
□ Feature works as spec
□ Edge cases handled
□ Error handling complete

Quality
□ Code readable (good names)
□ No duplicates (DRY)
□ Performance OK

Security
□ Input validated
□ No SQL injection risk
□ No XSS risk
□ Secrets not exposed

Standards
□ Follows conventions
□ Consistent style
□ Tests included
```

---

## 🚨 When to Refactor

### Good Refactoring Moments

- ✅ **After feature done**: While fresh in mind
- ✅ **Code duplication**: Extract to function
- ✅ **Complex function**: Split into smaller
- ✅ **Poor naming**: Rename for clarity
- ✅ **Technical debt**: Scheduled maintenance

### Bad Refactoring Moments

- ❌ **During feature dev**: Gets sidetracked
- ❌ **Before deploy**: Risky, untested
- ❌ **"While I'm at it"**: Scope creep
- ❌ **For style**: Minor nitpicks

---

## 🤝 Team Coordination (Multi-Agent)

### When Using Multi-Agent

- ✅ **Clear task boundaries**: Agents don't step on each other
- ✅ **Defined APIs**: Between components
- ✅ **Regular syncs**: Check progress daily
- ✅ **Merge strategy**: Plan how to integrate

### Potential Issues

- ⚠️ **Merge conflicts**: If same file edited
- ⚠️ **Coordination overhead**: Need communication
- ⚠️ **Integration issues**: Features not compatible

### Prevention

```
Before multi-agent:
1. Define clear task boundaries
2. Design interfaces/APIs between tasks
3. Plan merge points
4. Setup merge conflict resolution

During multi-agent:
1. Daily standup (sync progress)
2. Flag blockers early
3. Coordinate shared components
```

---

## 📈 Performance Optimization

### When to Optimize

- ✅ **After profile**: Know where slow is
- ✅ **User-facing**: UI responsiveness matters
- ✅ **Data-heavy**: Large lists, big datasets
- ✅ **Production**: Monitor real usage

### NOT

- ❌ **Premature optimization**: "It might be slow"
- ❌ **Guessing**: Profile first, then fix
- ❌ **Sacrificing readability**: Unreadable fast code is bad

---

## 🎓 Documentation Best Practices

### Document What

- ✅ **APIs**: Every endpoint documented
- ✅ **Architecture**: How components work together
- ✅ **Setup**: How to dev locally
- ✅ **Why**: Decisions, trade-offs, constraints
- ✅ **Examples**: Usage examples in README

### Not

- ❌ **Code comments**: "Good code is self-documenting"
- ❌ **Obvious stuff**: Variable name says what it is
- ❌ **Outdated docs**: Stale documentation = worse than none

---

## ⏰ Timeline Estimation

### Realistic Estimates

```
Feature estimate = implementation + review + testing + docs

Task CRUD API (12 tasks, 50 SP):
- Estimate per task: 1 day
- Buffer (unknowns): +20% = 1.2 days/task
- TOTAL: 12 × 1.2 = 14.4 days

Conservative: Add 1-2 more days buffer
Aggressive: Remove buffer (risky)
```

### NOT

```
"We can do this in 2 days"  (when it's really 2 weeks)
"Just small tweaks" (takes 3x longer)
```

---

## 🔄 Iteration Strategy

### Iterate On

- ✅ **Spec**: If ambiguous or wrong
- ✅ **Implementation**: If taking too long
- ✅ **Architecture**: If design wrong
- ✅ **Process**: If workflow slow

### How

```
1. Assess: Is this taking too long? Why?
2. Pivot: Change spec, redesign, or approach
3. Try again: Re-implement with new approach
4. Learn: Document what worked better
```

---

## 📝 Checklist: Before You Deploy

```
□ All tests passing
□ Code review approved
□ No CRITICAL/HIGH issues in code review
□ Spec met (verify spec)
□ Documentation updated
□ Performance acceptable
□ Security audit passed
□ User testing OK (if external)
□ Monitoring setup
□ Rollback plan ready
□ Team aligned
```

---

## 💡 Final Tips

1. **Start small**: MVP with 3 features, not 10
2. **Get feedback early**: Users know best
3. **Test often**: Catch issues fast
4. **Refactor gradually**: Pay off technical debt
5. **Document wisely**: Essential docs, not everything
6. **Optimize after**: Profile first, then optimize
7. **Communicate**: Team alignment prevents rework
8. **Iterate**: Perfect is enemy of shipped

---

**Remember: Done is better than perfect, but done well is best!** 🚀
