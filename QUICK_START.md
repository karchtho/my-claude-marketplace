# Quick Start Guide

Get your marketplace up and running in 3 commands!

## ⚡ Immediate Next Steps

### 1. Add the marketplace to Claude

```bash
/plugin marketplace add ~/projects/my-claude-skills
```

**What this does:** Registers your personal marketplace so Claude knows where to find your skill bundles.

### 2. Install the React bundle

```bash
/plugin install react-frontend-bundle@my-claude-skills
```

**What this does:** Activates the React patterns and UI/UX design skills. Claude will now automatically use these skills when you work on React projects.

### 3. Verify it's working

Try asking Claude:

```
Create a user profile component with Zustand state management and proper TypeScript types
```

Claude should:
- Apply React patterns from the skill
- Use Zustand patterns from the state management section
- Include TypeScript types
- Follow UI/UX best practices

## ✅ Success Indicators

You'll know it's working when:
- `/plugin list` shows `react-frontend-bundle` as installed
- Claude automatically mentions React best practices
- Code examples use Zustand stores when appropriate
- Components follow the patterns from your skills

## 🎯 Try These Examples

### Test Zustand Integration
```
User: "Create a shopping cart store with Zustand that persists to localStorage"
```

**Expected:** Claude creates a Zustand store with persistence middleware, following the patterns in the skill.

### Test UI/UX Skill
```
User: "Build an accessible modal dialog component"
```

**Expected:** Claude includes ARIA attributes, focus management, keyboard navigation, and follows WCAG guidelines.

### Test Combined Skills
```
User: "Create a user settings page with dark mode toggle using Zustand"
```

**Expected:** Claude combines React patterns (components, hooks), Zustand (state management), and UI/UX (design tokens, dark mode).

## 📋 Checklist

- [ ] Run `/plugin marketplace add ~/projects/my-claude-skills`
- [ ] Run `/plugin install react-frontend-bundle@my-claude-skills`
- [ ] Run `/plugin list` to verify installation
- [ ] Ask Claude to create a Zustand store
- [ ] Verify Claude uses patterns from the skills
- [ ] Bookmark this marketplace directory for future updates

## 🔄 Daily Workflow

### Starting a React Session
```bash
/plugin install react-frontend-bundle@my-claude-skills
```

### Switching Contexts (future)
```bash
# Moving from React to Angular
/plugin uninstall react-frontend-bundle
/plugin install angular-frontend-bundle@my-claude-skills

# Back to React
/plugin uninstall angular-frontend-bundle
/plugin install react-frontend-bundle@my-claude-skills
```

## 🎨 Optional: Customize Now

Before you start, consider customizing the skills:

**Add your design tokens:**
```bash
code ~/projects/my-claude-skills/bundles/react-frontend-bundle/skills/ui-ux-design/SKILL.md
```

Find the CSS variables section and add your brand colors.

**Add your team's patterns:**
```bash
code ~/projects/my-claude-skills/bundles/react-frontend-bundle/skills/react-patterns/SKILL.md
```

Add any team-specific conventions or patterns.

## 🆘 Something Not Working?

### Marketplace Not Found
```bash
# Check the path is correct
ls ~/projects/my-claude-skills/.claude-plugin/marketplace.json

# If file exists but command fails, try absolute path
/plugin marketplace add /home/admin/projects/my-claude-skills
```

### Bundle Not Installing
```bash
# List available marketplaces
/plugin marketplace list

# Reinstall marketplace
/plugin marketplace remove my-claude-skills
/plugin marketplace add ~/projects/my-claude-skills
/plugin install react-frontend-bundle@my-claude-skills
```

### Skills Not Activating
1. Restart Claude Code
2. Try using specific trigger words: "React component", "Zustand store", "design system"
3. Check `/plugin list` shows the bundle as active

## 📚 Next Actions

Once you've verified everything works:

1. **Customize the skills** with your preferences
2. **Share with your team** - commit to Git, others can clone
3. **Add more bundles** - Angular, Unity, Backend, etc.
4. **Create shell aliases** for quick context switching

### Example Shell Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Claude marketplace shortcuts
alias claude-react='claude --after-plugin-install react-frontend-bundle@my-claude-skills'
alias claude-list='claude --run "/plugin list"'
alias claude-uninstall-all='claude --run "/plugin uninstall --all"'
```

---

## 🚀 You're All Set!

Your marketplace is ready. Run the 3 commands above and start building with Claude's full React + UI/UX expertise! 🎉

**Next:** Check out [README.md](./README.md) for the full guide.
