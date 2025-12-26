## Code commenting best practices

- **Self-Documenting Code**: Write code that explains itself through clear structure, meaningful names, and logical organization
- **Comment "Why", Not "What"**: Explain reasoning, business rules, trade-offs, and non-obvious decisions; the code shows "what"
- **Document Public APIs**: Add JSDoc/docstrings for public functions, classes, and modules with parameters, return types, and usage examples
- **TODO Format**: Use trackable format: `TODO(owner): description` or link to issue tracker
- **FIXME and HACK**: Mark technical debt clearly: `FIXME: description` for bugs, `HACK: description` for workarounds
- **Avoid Commented-Out Code**: Delete unused code; use version control to recover if needed
- **Keep Comments Current**: Update or remove comments when code changes; stale comments are worse than no comments
- **Complex Algorithm Documentation**: Document non-trivial algorithms with explanation and references to sources
- **Evergreen Comments**: Write comments that remain relevant over time; avoid references to temporary fixes or recent changes

## Related Standards
- `global/coding-style.md` - Code readability practices
