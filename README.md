# My Claude Skills Marketplace

Your personal skill marketplace for context-based development. Switch between React, Angular, Unity, and other development contexts by activating the right skill bundles.

## 📦 Available Bundles

### React Frontend Bundle
**Status:** ✅ Ready
**Contains:**
- React patterns skill (hooks, components, Zustand, Redux Toolkit, Jotai)
- UI/UX design skill (design systems, accessibility, responsive design)

**Future Bundles:**
- Angular Frontend Bundle (coming soon)
- Unity Game Dev Bundle (coming soon)
- Backend Stack Bundle (coming soon)
- Core Workflow Bundle (coming soon)

## 🚀 Quick Start

### 1. Add This Marketplace to Claude

```bash
# From anywhere in your terminal
/plugin marketplace add ~/projects/my-claude-skills
```

### 2. Install Your First Bundle

```bash
# Install the React bundle
/plugin install react-frontend-bundle@my-claude-skills
```

### 3. Verify It's Working

Start a conversation about React:
```
User: "I need to create a user profile component with Zustand state management"
```

Claude should automatically apply the React patterns and UI/UX skills!

### 4. Check Active Plugins

```bash
# See what's currently installed
/plugin list
```

## 🔄 Context Switching

### Working on React Project
```bash
/plugin install react-frontend-bundle@my-claude-skills
```

### Switching to Angular (when available)
```bash
/plugin uninstall react-frontend-bundle
/plugin install angular-frontend-bundle@my-claude-skills
```

### Switching to Unity (when available)
```bash
/plugin uninstall react-frontend-bundle
/plugin install unity-gamedev-bundle@my-claude-skills
```

## 📁 Structure

```
my-claude-skills/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace configuration
├── bundles/
│   └── react-frontend-bundle/    # React + UI/UX skills
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           ├── react-patterns/
│           │   └── SKILL.md
│           └── ui-ux-design/
│               └── SKILL.md
└── README.md                      # This file
```

## ➕ Adding More Bundles

### Option 1: Create Local Bundle

```bash
# Create bundle structure
mkdir -p ~/projects/my-claude-skills/bundles/my-new-bundle/{.claude-plugin,skills/my-skill}

# Create plugin.json
cat > ~/projects/my-claude-skills/bundles/my-new-bundle/.claude-plugin/plugin.json <<EOF
{
  "name": "my-new-bundle",
  "version": "1.0.0",
  "description": "Description of your bundle",
  "author": "Your Name",
  "components": {
    "skills": ["skills/my-skill"]
  }
}
EOF

# Create skill
cat > ~/projects/my-claude-skills/bundles/my-new-bundle/skills/my-skill/SKILL.md <<EOF
---
name: my-skill
description: When this skill should activate
---

# My Skill

Instructions for Claude...
EOF

# Add to marketplace.json
# Edit .claude-plugin/marketplace.json and add your bundle to the "plugins" array
```

### Option 2: Reference External Bundle

Edit `.claude-plugin/marketplace.json`:

```json
{
  "plugins": [
    // ... existing bundles ...
    {
      "name": "external-bundle",
      "source": "https://github.com/someone/cool-bundle",
      "description": "Someone else's bundle"
    }
  ]
}
```

## 🎯 Best Practices

1. **Keep Bundles Focused** - One context per bundle (React, Angular, etc.)
2. **Share Common Skills** - UI/UX skill is duplicated for now, but could be extracted
3. **Use Descriptive Names** - Skill names should clearly indicate their purpose
4. **Trigger Words Matter** - Use specific terms in descriptions that match how you'll ask questions
5. **Version Control** - Commit this marketplace to Git to back it up

## 🔧 Troubleshooting

### Skills Not Activating?

1. **Check installation:**
   ```bash
   /plugin list
   ```

2. **Reload Claude:**
   - Restart Claude Code to ensure skills are loaded

3. **Check skill descriptions:**
   - The description in `SKILL.md` frontmatter determines when skills activate
   - Use specific trigger words that match your queries

### Want to See What's Inside a Bundle?

```bash
cat ~/projects/my-claude-skills/bundles/react-frontend-bundle/.claude-plugin/plugin.json
```

## 📚 Learning Resources

- **Claude Code Documentation:** Run `/help` in Claude
- **Plugin System:** Check official Claude Code docs
- **Skill Writing:** See existing skills in `bundles/` for examples

## 🎨 Customization

### Update Your Info

Edit `.claude-plugin/marketplace.json`:
```json
{
  "name": "my-claude-skills",
  "owner": {
    "name": "Your Actual Name",      // ← Update this
    "email": "your.email@example.com" // ← Update this
  }
}
```

### Customize React Skill

Edit the skills directly:
```bash
code ~/projects/my-claude-skills/bundles/react-frontend-bundle/skills/react-patterns/SKILL.md
```

Add your preferred patterns, remove what you don't use, adjust to your team's standards.

## 🚀 Next Steps

1. ✅ Marketplace created
2. ✅ React bundle ready
3. ⏳ Add Angular bundle (optional)
4. ⏳ Add Unity bundle (optional)
5. ⏳ Add Backend bundle (optional)
6. ⏳ Add Core Workflow bundle (Git, code review, etc.)

---

**Happy coding!** Your marketplace is ready to use. Start with `/plugin install react-frontend-bundle@my-claude-skills` and begin building! 🎉
