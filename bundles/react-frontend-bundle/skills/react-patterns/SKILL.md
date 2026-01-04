---
name: react-patterns
description: Modern React development patterns including hooks, components, state management (Zustand, Redux Toolkit), and performance optimization. Activates when working with React components, JSX, hooks, stores, or React-specific architecture.
---

# React Development Patterns

This skill provides expert guidance on modern React development patterns and best practices.

## When to Apply This Skill

Use these patterns when:
- Creating or refactoring React components
- Implementing state management with hooks
- Optimizing React performance
- Designing component architecture
- Working with React 18+ features

## Core Principles

### 1. Component Design

**Functional Components First**
- Always prefer functional components over class components
- Use hooks for state and side effects
- Keep components focused and single-purpose

**Component Composition**
```jsx
// Good: Composable, reusable
function UserProfile({ user }) {
  return (
    <Card>
      <Avatar src={user.avatar} />
      <UserInfo name={user.name} email={user.email} />
      <UserActions userId={user.id} />
    </Card>
  );
}

// Avoid: Monolithic, hard to test
function UserProfile({ user }) {
  return (
    <div>
      {/* Everything in one component */}
    </div>
  );
}
```

### 2. Hook Patterns

**State Management**
- Use `useState` for simple local state
- Use `useReducer` for complex state logic
- Use `useContext` for shared state (sparingly)

**Effect Patterns**
```jsx
// Good: Proper dependency array
useEffect(() => {
  fetchUser(userId);
}, [userId]);

// Good: Cleanup for subscriptions
useEffect(() => {
  const subscription = api.subscribe(topic);
  return () => subscription.unsubscribe();
}, [topic]);
```

**Custom Hooks for Reusable Logic**
```jsx
function useDebounce(value, delay) {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}
```

### 3. Advanced State Management

When your app grows beyond simple local state, use external state management libraries.

#### Zustand (Recommended for Most Projects)

**Why Zustand:**
- Minimal boilerplate
- No providers needed
- TypeScript-friendly
- Built-in devtools support
- Middleware for persistence, immer, etc.

**Installation:**
```bash
npm install zustand
```

**Basic Store:**
```typescript
// stores/userStore.ts
import { create } from 'zustand';

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserState {
  user: User | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  setUser: (user: User) => void;
  fetchUser: (id: string) => Promise<void>;
  logout: () => void;
}

export const useUserStore = create<UserState>((set) => ({
  user: null,
  isLoading: false,
  error: null,

  setUser: (user) => set({ user }),

  fetchUser: async (id) => {
    set({ isLoading: true, error: null });
    try {
      const response = await fetch(`/api/users/${id}`);
      const user = await response.json();
      set({ user, isLoading: false });
    } catch (error) {
      set({ error: error.message, isLoading: false });
    }
  },

  logout: () => set({ user: null }),
}));
```

**Using the Store:**
```tsx
function UserProfile() {
  // Subscribe to specific state slices
  const user = useUserStore((state) => state.user);
  const fetchUser = useUserStore((state) => state.fetchUser);
  const isLoading = useUserStore((state) => state.isLoading);

  useEffect(() => {
    fetchUser('123');
  }, [fetchUser]);

  if (isLoading) return <Skeleton />;
  return <div>{user?.name}</div>;
}

// Outside components
function logoutEverywhere() {
  useUserStore.getState().logout();
}
```

**Zustand with Immer (for complex state):**
```typescript
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface TodoState {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: string) => void;
}

export const useTodoStore = create<TodoState>()(
  immer((set) => ({
    todos: [],

    addTodo: (text) =>
      set((state) => {
        // Mutate draft directly (Immer handles immutability)
        state.todos.push({
          id: crypto.randomUUID(),
          text,
          completed: false,
        });
      }),

    toggleTodo: (id) =>
      set((state) => {
        const todo = state.todos.find((t) => t.id === id);
        if (todo) todo.completed = !todo.completed;
      }),
  }))
);
```

**Zustand with Persistence:**
```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      theme: 'light',
      language: 'en',
      setTheme: (theme) => set({ theme }),
      setLanguage: (language) => set({ language }),
    }),
    {
      name: 'app-settings', // localStorage key
    }
  )
);
```

**Zustand Slices Pattern (for large stores):**
```typescript
// stores/slices/userSlice.ts
export const createUserSlice = (set) => ({
  user: null,
  setUser: (user) => set({ user }),
});

// stores/slices/settingsSlice.ts
export const createSettingsSlice = (set) => ({
  theme: 'light',
  setTheme: (theme) => set({ theme }),
});

// stores/index.ts
import { create } from 'zustand';

export const useStore = create((set) => ({
  ...createUserSlice(set),
  ...createSettingsSlice(set),
}));
```

#### Redux Toolkit (for Enterprise Apps)

**When to use Redux Toolkit:**
- Large enterprise applications
- Need time-travel debugging
- Complex state logic with multiple reducers
- Team already familiar with Redux

**Installation:**
```bash
npm install @reduxjs/toolkit react-redux
```

**Store Setup:**
```typescript
// store/userSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchUser = createAsyncThunk(
  'user/fetch',
  async (userId: string) => {
    const response = await fetch(`/api/users/${userId}`);
    return response.json();
  }
);

const userSlice = createSlice({
  name: 'user',
  initialState: {
    data: null,
    loading: false,
    error: null,
  },
  reducers: {
    logout: (state) => {
      state.data = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchUser.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchUser.fulfilled, (state, action) => {
        state.loading = false;
        state.data = action.payload;
      })
      .addCase(fetchUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      });
  },
});

export const { logout } = userSlice.actions;
export default userSlice.reducer;

// store/index.ts
import { configureStore } from '@reduxjs/toolkit';
import userReducer from './userSlice';

export const store = configureStore({
  reducer: {
    user: userReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

**Using Redux:**
```tsx
// hooks/redux.ts
import { useDispatch, useSelector } from 'react-redux';
import type { RootState, AppDispatch } from '../store';

export const useAppDispatch = useDispatch.withTypes<AppDispatch>();
export const useAppSelector = useSelector.withTypes<RootState>();

// Component
function UserProfile() {
  const dispatch = useAppDispatch();
  const { data: user, loading } = useAppSelector((state) => state.user);

  useEffect(() => {
    dispatch(fetchUser('123'));
  }, [dispatch]);

  return <div>{user?.name}</div>;
}
```

#### Jotai (Atomic State)

**When to use Jotai:**
- Bottom-up state management approach
- Need derived state
- Want something lighter than Redux but more structured than Zustand

**Installation:**
```bash
npm install jotai
```

**Basic Atoms:**
```typescript
// atoms/user.ts
import { atom } from 'jotai';

export const userAtom = atom<User | null>(null);
export const isLoadingAtom = atom(false);

// Derived atom
export const userNameAtom = atom(
  (get) => get(userAtom)?.name ?? 'Guest'
);

// Async atom
export const userDataAtom = atom(
  async (get) => {
    const response = await fetch('/api/user');
    return response.json();
  }
);
```

**Using Atoms:**
```tsx
import { useAtom, useAtomValue, useSetAtom } from 'jotai';

function UserProfile() {
  const [user, setUser] = useAtom(userAtom);
  const userName = useAtomValue(userNameAtom); // Read-only
  const setLoading = useSetAtom(isLoadingAtom); // Write-only

  return <div>{userName}</div>;
}
```

#### State Management Decision Tree

```
Do you need global state?
├─ No → Use useState/useReducer
└─ Yes
   ├─ Simple global state (settings, user, etc.)
   │  └─ Use Zustand
   ├─ Complex enterprise app with time-travel debugging
   │  └─ Use Redux Toolkit
   └─ Need fine-grained reactivity and derived state
      └─ Use Jotai
```

#### State Management Best Practices

1. **Collocate state** - Keep state as close as possible to where it's used
2. **Server state vs Client state** - Use React Query/TanStack Query for server state
3. **Don't over-globalize** - Not everything needs to be in a store
4. **Use selectors** - Only subscribe to the state you need
5. **Normalize complex data** - Avoid deeply nested state structures

**Example: Combining Zustand with React Query**
```typescript
// Server state with React Query
const { data: todos } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
});

// Client state with Zustand
const filter = useStore((state) => state.filter);
const setFilter = useStore((state) => state.setFilter);

// Combine for derived state
const filteredTodos = useMemo(
  () => todos?.filter(todo =>
    filter === 'all' || (filter === 'completed' && todo.completed)
  ),
  [todos, filter]
);
```

### 4. Performance Optimization

**Memoization Strategy**
- Use `useMemo` for expensive calculations
- Use `useCallback` for function references passed to children
- Use `React.memo` for expensive components that render often

**When to Optimize**
```jsx
// Optimize when rendering is expensive
const ExpensiveList = React.memo(({ items }) => {
  const sortedItems = useMemo(
    () => items.sort((a, b) => a.priority - b.priority),
    [items]
  );

  return sortedItems.map(item => <Item key={item.id} {...item} />);
});
```

### 4. Props and TypeScript

**Prop Design**
- Keep prop interfaces simple and focused
- Use TypeScript for type safety
- Avoid prop drilling (use composition or context)

```typescript
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  onClick: () => void;
  children: React.ReactNode;
  disabled?: boolean;
}

function Button({ variant, size = 'md', onClick, children, disabled }: ButtonProps) {
  // Implementation
}
```

### 5. Project Structure

**Recommended Organization (with Zustand)**
```
src/
├── components/
│   ├── common/          # Reusable UI components
│   ├── features/        # Feature-specific components
│   └── layouts/         # Layout components
├── stores/              # Zustand stores
│   ├── userStore.ts
│   ├── settingsStore.ts
│   └── slices/          # Store slices for large apps
├── hooks/               # Custom hooks
├── contexts/            # Context providers (use sparingly)
├── utils/               # Helper functions
└── types/               # TypeScript types
```

## Common Patterns

### Container/Presentational Pattern
```jsx
// Presentational: Pure UI
function UserCard({ name, email, onEdit }) {
  return (
    <div>
      <h3>{name}</h3>
      <p>{email}</p>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}

// Container: Logic and data
function UserCardContainer({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  const handleEdit = () => {
    // Edit logic
  };

  return user ? <UserCard {...user} onEdit={handleEdit} /> : <Skeleton />;
}
```

### Compound Components Pattern
```jsx
function Select({ children, value, onChange }) {
  return (
    <select value={value} onChange={onChange}>
      {children}
    </select>
  );
}

Select.Option = function Option({ value, children }) {
  return <option value={value}>{children}</option>;
};

// Usage
<Select value={country} onChange={setCountry}>
  <Select.Option value="us">United States</Select.Option>
  <Select.Option value="ca">Canada</Select.Option>
</Select>
```

## Best Practices

1. **Always use keys in lists** - Use stable, unique IDs
2. **Avoid inline object/array literals in props** - Causes unnecessary re-renders
3. **Extract complex JSX into variables** - Improves readability
4. **Use error boundaries** - Catch and handle component errors gracefully
5. **Lazy load routes and heavy components** - Use `React.lazy()` and `Suspense`

## Code Review Checklist

When reviewing React code, check for:
- [ ] Proper use of hooks (no hooks in conditionals/loops)
- [ ] Correct dependency arrays in useEffect/useMemo/useCallback
- [ ] No unnecessary re-renders (use React DevTools Profiler)
- [ ] Proper key props in mapped lists
- [ ] TypeScript types for all props
- [ ] Accessibility (semantic HTML, ARIA attributes)
- [ ] Error handling and loading states

## Anti-Patterns to Avoid

❌ **Mutating state directly**
```jsx
// Wrong
state.items.push(newItem);
setState(state);

// Correct
setState({ ...state, items: [...state.items, newItem] });
```

❌ **Using index as key in dynamic lists**
```jsx
// Wrong
{items.map((item, index) => <Item key={index} {...item} />)}

// Correct
{items.map(item => <Item key={item.id} {...item} />)}
```

❌ **Over-using useEffect**
```jsx
// Wrong: Derived state in effect
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);

// Correct: Calculate during render
const fullName = `${firstName} ${lastName}`;
```

## Resources

- React documentation: https://react.dev
- React TypeScript Cheatsheet: https://react-typescript-cheatsheet.netlify.app
- React Performance: https://react.dev/learn/render-and-commit
