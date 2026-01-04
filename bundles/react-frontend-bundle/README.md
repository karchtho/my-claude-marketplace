# React Frontend Bundle

Complete React development toolkit with modern patterns, state management, and UI/UX design principles.

## 📦 What's Included

### Skills

#### 1. React Patterns (`skills/react-patterns/`)
**Activates when:** Working with React components, JSX, hooks, stores, or React architecture

**Covers:**
- ✅ Component design patterns (functional components, composition)
- ✅ Hook patterns (useState, useEffect, useReducer, custom hooks)
- ✅ **Advanced State Management**
  - **Zustand** (recommended) - Lightweight, TypeScript-friendly stores
  - **Redux Toolkit** - Enterprise-scale state management
  - **Jotai** - Atomic state management
- ✅ Performance optimization (useMemo, useCallback, React.memo)
- ✅ Props and TypeScript patterns
- ✅ Project structure recommendations
- ✅ Common patterns (container/presentational, compound components)
- ✅ Best practices and anti-patterns

**State Management Highlights:**
- Complete Zustand examples (basic stores, Immer, persistence, slices)
- Redux Toolkit with async thunks and TypeScript
- Jotai atomic state patterns
- Decision tree for choosing the right state solution
- Combining client state (Zustand) with server state (React Query)

#### 2. UI/UX Design (`skills/ui-ux-design/`)
**Activates when:** Discussing layouts, styling, design decisions, user flows, or visual design

**Covers:**
- ✅ Visual hierarchy and information architecture
- ✅ Consistency and design systems (CSS variables, tokens)
- ✅ Responsive design (mobile-first, fluid typography)
- ✅ **Accessibility (WCAG 2.1 AA)**
  - Color contrast requirements
  - Semantic HTML
  - ARIA attributes
  - Keyboard navigation
- ✅ User feedback patterns (loading, error, success states)
- ✅ Interaction design (button states, microinteractions)
- ✅ Form design best practices
- ✅ Color theory and dark mode support
- ✅ Typography scales
- ✅ Design patterns (cards, modals)

## 🚀 Installation

```bash
/plugin install react-frontend-bundle@my-claude-skills
```

## 💡 Usage Examples

### Example 1: Zustand Store Creation

```
User: "Create a user authentication store with Zustand"
```

Claude will:
- Use the React patterns skill
- Create a TypeScript Zustand store with login/logout actions
- Include proper error handling and loading states
- Follow the patterns documented in the skill

### Example 2: Accessible Component

```
User: "Build a modal component with proper accessibility"
```

Claude will:
- Apply both React patterns and UI/UX design skills
- Create a modal with ARIA attributes
- Include focus management
- Add keyboard navigation (ESC to close)
- Ensure color contrast and semantic HTML

### Example 3: State Management Decision

```
User: "Should I use Zustand or Redux for my todo app?"
```

Claude will:
- Reference the state management decision tree
- Recommend Zustand for a simple todo app
- Explain the trade-offs
- Provide implementation examples

## 🎯 When This Bundle Is Active

The skills in this bundle automatically activate when you:
- Ask about React components, hooks, or patterns
- Discuss state management (Zustand, Redux, Jotai)
- Ask about UI/UX design decisions
- Request accessible component implementations
- Talk about responsive design or design systems
- Need form validation or error handling patterns

## 🔧 Customization

### Add Your Team's Patterns

Edit `skills/react-patterns/SKILL.md` to include:
- Your company's component naming conventions
- Preferred folder structure
- Team-specific hooks or utilities
- Code review standards

### Add Your Design System

Edit `skills/ui-ux-design/SKILL.md` to include:
- Your brand colors and tokens
- Typography scale
- Spacing system
- Component library patterns

Example:
```css
:root {
  /* Your brand colors */
  --primary: #yourcolor;
  --secondary: #yourcolor;

  /* Your spacing scale */
  --space-1: 4px;
  --space-2: 8px;
  /* ... */
}
```

## 📁 Structure

```
react-frontend-bundle/
├── .claude-plugin/
│   └── plugin.json                 # Bundle metadata
├── skills/
│   ├── react-patterns/
│   │   └── SKILL.md                # 500+ lines of React expertise
│   └── ui-ux-design/
│       └── SKILL.md                # 400+ lines of design guidance
└── README.md                        # This file
```

## 🔄 Deactivation

When switching to a different frontend framework:

```bash
# Deactivate React bundle
/plugin uninstall react-frontend-bundle

# Activate Angular bundle (when available)
/plugin install angular-frontend-bundle@my-claude-skills
```

## 📊 Skill Details

### React Patterns Skill
- **Lines:** ~700
- **Sections:** 9 major sections
- **Code Examples:** 30+ practical examples
- **Covers:** Zustand, Redux Toolkit, Jotai, hooks, performance, TypeScript

### UI/UX Design Skill
- **Lines:** ~600
- **Sections:** 9 major principles
- **Code Examples:** 25+ design patterns
- **Focus:** Accessibility, responsive design, design systems

## 🎓 Learning Path

1. **Start with basics:** Component patterns, hooks
2. **Add state management:** Begin with Zustand for simplicity
3. **Apply UI/UX principles:** Accessibility, responsive design
4. **Optimize:** Performance patterns, memoization
5. **Scale:** Zustand slices, design systems

## 🆘 Troubleshooting

### Skill Not Triggering?

Make sure you're using trigger words from the skill descriptions:
- "React component"
- "hooks"
- "Zustand store"
- "design system"
- "accessibility"
- "responsive design"

### Want to See Skill Content?

```bash
cat ~/projects/my-claude-skills/bundles/react-frontend-bundle/skills/react-patterns/SKILL.md
```

## 🚀 Next Steps

- [ ] Customize skills with your team's standards
- [ ] Add your design system tokens
- [ ] Create project-specific variations
- [ ] Share with your team via Git

---

**Ready to build amazing React apps!** 🎉
