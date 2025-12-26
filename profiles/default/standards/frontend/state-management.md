## State Management Best Practices

### State Location

- **Local State First**: Keep state as local as possible; only lift state when truly needed by multiple components
- **Colocation**: Store state near where it's used to improve code organization and reduce prop drilling
- **Derived State**: Compute derived values on-the-fly rather than storing redundant state
- **Single Source of Truth**: Each piece of state should have exactly one authoritative source

### State Types

- **UI State**: Component-level state for UI interactions (modals, dropdowns, form inputs)
- **Server State**: Data fetched from external sources; consider dedicated tools for caching/syncing
- **URL State**: State encoded in URLs (routing, query params, hash)
- **Form State**: Input values, validation errors, submission status
- **Session State**: User authentication, preferences persisted across sessions

### State Updates

- **Immutability**: Always create new state objects rather than mutating existing ones
- **Atomic Updates**: Group related state changes into single updates to avoid inconsistent intermediate states
- **Optimistic Updates**: Update UI immediately for better UX, then reconcile with server response
- **Batching**: Batch multiple state updates when possible to reduce re-renders

### State Patterns

- **Controlled Components**: Parent owns and controls state via props and callbacks
- **Uncontrolled Components**: Component manages own state internally; use refs to read values
- **Container/Presentational**: Separate state management logic from presentation concerns
- **State Machines**: Use finite state machines for complex state transitions with clear invariants

### Performance Considerations

- **Selective Updates**: Structure state to minimize components affected by changes
- **Memoization**: Cache expensive computations and prevent unnecessary recalculations
- **Lazy Initialization**: Initialize expensive state only when component mounts
- **State Normalization**: Flatten nested data to simplify updates and prevent inconsistencies

### Anti-Patterns to Avoid

- **Prop Drilling**: Passing props through many layers; use context or composition instead
- **Derived State in State**: Storing values that can be computed from other state
- **Stale Closures**: Referencing outdated state values in callbacks
- **Excessive Global State**: Putting everything in global store when local state suffices
