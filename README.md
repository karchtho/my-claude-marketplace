# My Claude Skills Marketplace

Your personal skill marketplace for context-based development. Switch between React, Angular, Unity, and other development contexts by activating the right skill bundles.

## 📦 Available Bundles

### React Frontend Bundle
**Status:** ✅ Ready
**Contains:**
- React patterns skill (hooks, components, Zustand, Redux Toolkit, Jotai)
- UI/UX design skill (design systems, accessibility, responsive design)

### Dev Toolkit Bundle ⭐ **NEW**
**Status:** ✅ Ready
**Contains:**
- **bundle-maker skill** - Automates bundle creation with no placeholders
- **Utility scripts:** create-bundle.sh, add-skill-to-bundle.sh, validate-bundle.sh
- **Example bundles:** Working templates for minimal and complete bundles
- **Comprehensive guide:** Detailed skill creation methodology

**Install:** `/plugin install dev-toolkit-bundle@my-claude-marketplace`

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
│   ├── react-frontend-bundle/    # React + UI/UX skills
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── react-patterns/
│   │       │   └── SKILL.md
│   │       └── ui-ux-design/
│   │           └── SKILL.md
│   └── dev-toolkit-bundle/       # Bundle creation tools
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── bundle-maker/
│               ├── SKILL.md
│               ├── references/   # Skill creation guide
│               ├── scripts/      # Automation scripts
│               └── examples/     # Working templates
└── README.md                      # This file
```

## ➕ Adding More Bundles

### Option 1: Use Bundle Maker Skill (Recommended)

```bash
# Install the dev toolkit
/plugin install dev-toolkit-bundle@my-claude-marketplace

# Then ask Claude to create a bundle
"Create a new bundle for Angular development"
# or
"Create a bundle for Unity game development"
```

The bundle-maker skill will:
- ✓ Ask for all required information upfront (no placeholders!)
- ✓ Create proper directory structure
- ✓ Generate plugin.json with your actual info
- ✓ Create skill templates ready to fill in
- ✓ Validate the bundle structure
- ✓ Add to marketplace.json

### Option 2: Use Utility Scripts

```bash
# Navigate to dev-toolkit-bundle scripts
cd bundles/dev-toolkit-bundle/skills/bundle-maker/scripts

# Create bundle structure
./create-bundle.sh my-new-bundle

# Add skills to the bundle
./add-skill-to-bundle.sh ../../my-new-bundle my-skill

# Validate before registering
./validate-bundle.sh ../../my-new-bundle
```

See `bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/README.md` for full documentation.

### Option 3: Reference External Bundle

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
3. ✅ Dev toolkit bundle ready ⭐ **NEW**
4. ⏳ Test bundle creation (use bundle-maker skill)
5. ⏳ Add Angular bundle (optional)
6. ⏳ Add Unity bundle (optional)
7. ⏳ Add Backend bundle (optional)
8. ⏳ Add Core Workflow bundle (Git, code review, etc.)

---

**Happy coding!** Your marketplace is ready to use.

**Quick Start:**
- `/plugin install react-frontend-bundle@my-claude-marketplace` - For React development
- `/plugin install dev-toolkit-bundle@my-claude-marketplace` - To create more bundles

Then ask: "Create a new bundle for [your context]" 🎉
