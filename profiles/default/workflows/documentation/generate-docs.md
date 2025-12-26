# Documentation Generation Workflow

## Pre-conditions

Before running this workflow:
- [ ] Implementation is complete (or at least partially complete)
- [ ] Spec exists at `[spec-path]/spec.md` with feature description
- [ ] Code changes are committed or at least stable

## Workflow

### Step 1: Analyze Documentation Needs

Determine what documentation is needed:

1. **Check existing docs**: Look for existing README.md, docs/ folder, API documentation
2. **Read the spec**: Load `agent-os/specs/[spec-path]/spec.md` to understand the feature
3. **Identify public APIs**: Find new endpoints, functions, or components that need documentation

```bash
# Check for existing documentation structure
ls -la README.md docs/ 2>/dev/null || echo "No existing docs structure"

# Find API routes/endpoints (adapt pattern to your framework)
grep -r "router\." --include="*.ts" --include="*.js" src/ 2>/dev/null | head -20
```

### Step 2: Generate API Documentation

For each new API endpoint or public function:

**Endpoint Documentation Format:**
```markdown
## [HTTP Method] /api/path

**Description**: Brief description of what this endpoint does

**Authentication**: Required / Optional / None

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| param1 | string | Yes | Description |

**Request Body:**
```json
{
  "field": "value"
}
```

**Response:**
```json
{
  "status": "success",
  "data": {}
}
```

**Error Codes:**
| Code | Description |
|------|-------------|
| 400 | Bad request - invalid parameters |
| 401 | Unauthorized |
| 404 | Resource not found |

**Example:**
```bash
curl -X POST https://api.example.com/path \
  -H "Authorization: Bearer token" \
  -d '{"field": "value"}'
```
```

### Step 3: Update README (if applicable)

If the feature adds significant functionality, update README.md:

**Sections to update:**
- Features list (if new feature)
- Installation (if new dependencies)
- Configuration (if new env variables)
- Usage examples (if new user-facing features)

### Step 4: Generate Changelog Entry

Create or update changelog for this spec:

Write to `agent-os/specs/[spec-path]/implementation/CHANGELOG.md`:

```markdown
# Changelog: [Feature Name]

## [Version/Date] - [Spec Name]

### Added
- [New feature 1]
- [New feature 2]

### Changed
- [Modified behavior 1]

### Fixed
- [Bug fix 1]

### Technical Notes
- [Implementation detail relevant for future maintenance]
- [Dependency changes]
```

### Step 5: Document Configuration

If new configuration options were added:

```markdown
## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| NEW_VAR | Yes | - | Description of what this controls |

### Config File Options

```yaml
# config.yml
new_feature:
  option1: value    # Description
  option2: value    # Description
```
```

### Step 6: Create Documentation Summary

Write summary to `agent-os/specs/[spec-path]/implementation/documentation-summary.md`:

```markdown
# Documentation Summary

## Documentation Created/Updated

### API Documentation
- [ ] `docs/api/[endpoint].md` - [endpoint description]

### README Updates
- [ ] Added feature to features list
- [ ] Added configuration section for [feature]

### Changelog
- [ ] Created changelog entry for [version/spec]

### Code Documentation
- [ ] Added JSDoc to `path/to/file.ts`
- [ ] Added docstrings to `path/to/module.py`

## Documentation Gaps
[Areas that need additional documentation from developers]

- [ ] [Area needing documentation]

## Recommendations
- [Future documentation improvements]
```

### Step 7: Output Summary

> **Follow Output Protocol**: See `{{protocols/output-protocol}}` for context optimization guidelines.

Return ONLY this summary:

```
✅ Documentation generated.
📁 Report: agent-os/specs/[spec-path]/implementation/documentation-summary.md
📊 Summary: [X] API docs | [Y] README updates | Changelog: updated
⏱️ Gaps: [Z] areas need input
```

**Do NOT include** file lists, detailed documentation content, or gap descriptions in the conversation response.

## Important Constraints

- Keep documentation concise and scannable
- Use consistent formatting throughout
- Include working examples where possible
- Don't document internal/private APIs unless specifically requested
- Keep changelogs focused on user-facing changes
- Use the project's existing documentation style if one exists
- Always include practical examples for complex features

## Error Recovery

If you encounter issues during documentation generation:

1. **Missing Spec Files**: Generate minimal docs based on code analysis, note gaps
2. **No Public APIs Found**: Document internal architecture overview instead
3. **Incomplete Implementation**: Document what exists, mark incomplete areas as "TBD"
4. **Existing Doc Conflicts**: Preserve existing structure, add new sections rather than overwriting
