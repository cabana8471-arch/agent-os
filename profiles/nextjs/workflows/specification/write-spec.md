# Next.js Specification Writing Workflow

When writing specifications for Next.js features, ensure they include framework-specific considerations.

## Specification Template

```markdown
# Feature Name

## Overview
Brief description of feature.

## User Stories
- As a [role], I want [action] so that [benefit]
- (Multiple stories)

## Technical Approach

### Architecture Decision
- **Routing**: Which routes involved?
- **Components**: Server or Client components?
- **Data Fetching**: Server fetch or client-side?
- **State Management**: How is state managed?
- **Database**: Any schema changes?

### Key Decisions
1. [Decision 1] - Why chosen over alternatives
2. [Decision 2] - Tradeoffs considered

## Implementation Details

### Routes & Navigation
- List all affected routes
- Document URL structure
- Describe navigation flow

### Components
List components involved:
- Server Components (data fetching)
- Client Components (interactivity)
- UI components used

### Server Actions / API
- Which Server Actions needed?
- Which API routes (if any)?
- Request/response structure

### Database Schema
```prisma
model Example {
  id Int @id @default(autoincrement())
  // fields...
}
```

### State Management
- What state is needed?
- How is it stored/fetched?
- Revalidation strategy?

## Examples & Scenarios

### Happy Path
Step-by-step walkthrough of successful flow.

### Error Scenarios
- What can go wrong?
- How are errors handled?
- User feedback strategy?

## Performance Considerations
- Image optimization needs?
- Data fetching optimization?
- Caching strategy?
- Code splitting opportunities?

## Accessibility Requirements
- ARIA labels needed?
- Keyboard navigation?
- Focus management?
- Form validation patterns?

## Testing Strategy
- What to unit test?
- E2E test scenarios?
- Coverage targets?

## Success Criteria
- Performance metrics (LCP, CLS, etc.)
- Accessibility standards (WCAG 2.1)
- User satisfaction metrics
- Code quality metrics
```

## Finding Existing Next.js Patterns

### 1. Review Your Codebase

Check if similar features exist:
```bash
# Search for Server Component patterns
grep -r "export default async function" app/

# Find Client Components
grep -r "'use client'" app/

# Locate Server Actions
grep -r "'use server'" app/
```

### 2. Identify Patterns to Follow

Look for existing:
- **Route structure**: `/dashboard`, `/admin`, etc.
- **Component organization**: Feature-based vs type-based
- **Data fetching patterns**: Where data is fetched
- **Error handling**: How errors are surfaced
- **Form patterns**: Server Actions, validation, error display
- **Authentication checks**: Where auth is verified

### 3. Document Pattern Decisions

When writing spec, note:

**Example:**
```markdown
## Implementation Pattern

Following existing patterns from [Feature X]:
- Uses Server Components for data fetching (not Client fetch)
- Validates with Zod schema before mutation
- Uses Server Actions for form submission
- Implements Suspense boundaries for loading states
- Uses revalidatePath for cache invalidation
```

## Framework-Specific Checks

### App Router Specifics

- [ ] Route segments and groups properly planned?
- [ ] Dynamic routes with generateStaticParams?
- [ ] Nested layouts leverage UI sharing?
- [ ] Loading states with loading.tsx or Suspense?
- [ ] Error handling with error.tsx or try-catch?
- [ ] Not-found scenarios with notFound()?

### Server Components

- [ ] Data fetching in right location (Server Component)?
- [ ] No useState/useEffect in Server Components?
- [ ] Database queries optimized (no N+1)?
- [ ] Async data transformations in Server?
- [ ] Client interactivity properly isolated?

### Forms & Validation

- [ ] Using Server Actions for mutations?
- [ ] Zod schema defined for validation?
- [ ] Progressive enhancement considered?
- [ ] Error messages user-friendly?
- [ ] Loading states during submission?

### Performance

- [ ] Images optimized with next/image?
- [ ] Fonts loaded with next/font?
- [ ] Dynamic components lazy-loaded?
- [ ] Data fetching parallelized?
- [ ] Caching strategy defined (ISR, revalidate, etc.)?
- [ ] Bundle size impact assessed?

### Security

- [ ] User authentication verified?
- [ ] Authorization checks in place?
- [ ] Input validation (Zod)?
- [ ] SQL injection prevented (via ORM)?
- [ ] CSRF protection for forms?
- [ ] Secrets not exposed client-side?

### Accessibility

- [ ] Proper heading hierarchy?
- [ ] ARIA labels for interactive elements?
- [ ] Keyboard navigation tested?
- [ ] Color contrast sufficient?
- [ ] Form labels associated with inputs?
- [ ] Error messages linked to fields?

## Example Specification: Blog Post Creation

```markdown
# Blog Post Creation Feature

## Overview
Allow authenticated users to create and publish blog posts with rich content, metadata, and scheduling.

## User Stories
- As a logged-in user, I want to create a blog post so that I can publish my thoughts
- As an author, I want to edit my draft posts so that I can improve them
- As a publisher, I want to schedule posts so that they publish automatically
- As a user, I want to see validation errors so that I can fix issues

## Technical Approach

### Architecture Decision
- **Routing**: `/blog/new` (creation), `/blog/[slug]/edit` (editing)
- **Components**: Mixed Server + Client (data in Server, form in Client)
- **Data Fetching**: Server Components for initial load
- **Forms**: Server Actions with Zod validation
- **Database**: New `Post` and `Content` models in Prisma

### Key Decisions
1. **Server Actions over API Routes** - Better DX, type safety, no CORS
2. **Zod for validation** - Type-safe, clear error messages
3. **Suspense for loading** - Progressive rendering
4. **ISR caching** - Posts revalidated on update, not on every request

## Implementation Details

### Routes
- `GET /blog/new` - Creation form
- `POST /blog` - Create post (Server Action)
- `GET /blog/[slug]/edit` - Edit form
- `PATCH /blog/[slug]` - Update post (Server Action)
- `DELETE /blog/[slug]` - Delete post (Server Action)

### Components
- `NewPostPage` (Server) - Fetches user data
- `PostForm` (Client) - Form UI, submission
- `EditorInput` (Client) - Rich text editor
- `PostPreview` (Server) - Server-rendered preview

### Server Actions
```typescript
export async function createPost(formData: FormData)
export async function updatePost(id: string, formData: FormData)
export async function deletePost(id: string)
```

### Database Schema
```prisma
model Post {
  id String @id @default(cuid())
  title String
  slug String @unique
  content String
  excerpt String?
  published Boolean @default(false)
  scheduledAt DateTime?
  author User @relation(fields: [authorId], references: [id])
  authorId String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

### Validation
```typescript
const postSchema = z.object({
  title: z.string().min(5).max(200),
  excerpt: z.string().max(500).optional(),
  content: z.string().min(10),
  published: z.boolean().optional(),
  scheduledAt: z.date().optional(),
})
```

## Success Criteria
- Form submits within 500ms with feedback
- Validation errors shown inline
- Scheduled posts publish automatically
- LCP < 2.5s on form page
- 95%+ accessibility score
- 80%+ test coverage
```

## Related Workflow Steps

1. **Define Requirements** - What problem does this solve?
2. **Choose Tech** - App Router, Server Actions, Zod?
3. **Plan Database** - What data needs to persist?
4. **Sketch UI** - Wireframes for layout
5. **Define Validation** - Zod schema
6. **Plan Testing** - Unit tests, E2E tests
7. **Document Spec** - Clear for implementation team

## Specification Review Checklist

- [ ] All routes documented?
- [ ] Component architecture clear?
- [ ] Database schema defined?
- [ ] Validation rules specified?
- [ ] Error handling described?
- [ ] Performance considerations noted?
- [ ] Accessibility requirements listed?
- [ ] Testing strategy outlined?
- [ ] Security concerns addressed?
- [ ] Examples provided for clarity?

## Next Steps

After specification is written and reviewed:
1. Break down into implementation tasks
2. Estimate complexity
3. Assign to developers
4. Create test plan
5. Begin implementation following {{standards/*}}
