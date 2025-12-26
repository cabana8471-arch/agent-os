# React Specification Writing

## Searching for Existing Code Patterns

Before writing component spec, search for existing implementations:

### Find Similar Components

```bash
# List all components
find src/components -name "*.tsx"

# Search for component pattern
grep -r "export function.*Form" src/

# Find hooks
find src/hooks -name "use*.ts"

# Search for state management pattern
grep -r "useQuery" src/ | head -10
```

### Reuse Opportunities

- Existing button/input components → extend rather than recreate
- Similar form patterns → use same validation approach
- Common hooks → extract into shared lib
- API calls → add to existing API module

### Example Search Flow

```bash
# 1. Search for similar feature
grep -r "UserForm" src/

# 2. Find the component
src/features/users/components/UserForm.tsx

# 3. Check if it can be reused/extended
# 4. Look at its props and validation
# 5. Determine if new variant needed or modification

# Result: Either extend UserForm with new props or create UserRegistrationForm
```

## Component Spec Template

```markdown
# Component: UserProfileCard

## Purpose
Display user profile information in a card format with optional edit button.

## Props
- `user: User` - User object with id, name, email, avatar
- `onEdit?: (userId: string) => void` - Callback when edit button clicked
- `isEditable?: boolean` - Show edit button (default: false)

## State
- None (stateless component)

## Hooks Used
- None

## External Dependencies
- `@/components/ui/Card` - Card component
- `@/components/ui/Button` - Button component

## Example Usage
```jsx
<UserProfileCard
  user={user}
  isEditable={true}
  onEdit={handleEdit}
/>
```

## Related Components
- `UserForm` - Form to edit user
- `UserAvatar` - Avatar display component

## Testing
- Render with user data
- Click edit button triggers callback
- Non-editable variant shows no button
```

## Searching for API Patterns

```bash
# Find API client setup
grep -r "axios\|fetch" src/lib/

# Find query hooks
grep -r "useQuery" src/

# Find mutations
grep -r "useMutation" src/

# Check existing API structure
cat src/lib/api.ts
```

## Form Implementation Search

```bash
# Find existing forms
find src -name "*Form.tsx" | head -10

# Check validation patterns
grep -r "zodResolver\|yupResolver" src/

# Find schema definitions
find src -name "*schema.ts"

# Understand form state management
grep -r "useForm\|useFormContext" src/
```

## Hook Reuse Search

```bash
# Find custom hooks
find src/hooks -name "use*.ts"

# Check if useAuth exists
grep -r "export function useAuth" src/

# Check if useAsync exists
grep -r "useAsync" src/

# Understand hook dependencies
cat src/hooks/useCustomHook.ts
```

## Specification Requirements

For React specs, include:

1. **Component Purpose**: Clear one-liner
2. **Props Interface**: Types and descriptions
3. **State Management**: useState, useContext, Zustand
4. **Side Effects**: useEffect hooks and their purpose
5. **External Data**: API calls, hooks used
6. **UI/UX Behavior**: User interactions
7. **Error States**: Loading, error, empty states
8. **Accessibility**: ARIA labels, keyboard nav
9. **Responsive Behavior**: Mobile/tablet/desktop
10. **Testing Strategy**: What to test

## Code Search Examples

```bash
# Find all useEffect patterns
grep -B2 "useEffect" src/features/users/components/*.tsx

# Find all useState patterns
grep -B1 "useState" src/features/auth/hooks/*.ts

# Find form patterns
grep -r "useForm\|zodResolver" src/features/*/

# Find custom hooks that manage async
grep -r "useAsync\|useQuery" src/hooks/
```

## Documentation Search

```bash
# Check existing standards
cat profiles/react/standards/frontend/components.md

# Check form patterns
cat profiles/react/standards/frontend/forms.md

# Check API patterns
cat profiles/react/standards/backend/api.md

# Check hooks patterns
cat profiles/react/standards/frontend/hooks.md
```

## Related Standards

- {{standards/frontend/components}} - Component patterns
- {{standards/frontend/hooks}} - Hook patterns
- {{standards/frontend/forms}} - Form patterns
- {{standards/backend/api}} - API patterns
