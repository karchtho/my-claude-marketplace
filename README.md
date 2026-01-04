# Claude Code Skills Marketplace

> 🎯 **Context-aware development expertise for Claude Code**

A curated collection of specialized **plugin bundles** that give Claude deep expertise in specific tech stacks. Switch seamlessly between React, Angular, Unity, and other development contexts by activating the right skills when you need them.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude-Code-purple)](https://www.anthropic.com/claude/code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## ✨ Why This Marketplace?

- 🎯 **Focused Expertise** - Each bundle provides deep, specialized knowledge for a specific context
- 🔄 **Easy Switching** - Change contexts instantly with simple commands
- 🛠️ **Automated Tools** - Create your own bundles with built-in automation
- ✅ **Production Ready** - Battle-tested bundles with comprehensive skills
- 🤝 **Open Source** - Fork, customize, and contribute your own bundles

Perfect for developers who work across multiple tech stacks and want Claude to have the right expertise at the right time.

## 📦 Available Bundles

### React Frontend Bundle
**Status:** ✅ Production Ready

Complete React development expertise:
- **React Patterns** - Hooks, components, state management (Zustand, Redux Toolkit, Jotai), performance optimization
- **UI/UX Design** - Design systems, accessibility (WCAG 2.1 AA), responsive design, interaction patterns

Activates automatically when working with React components, JSX, hooks, or state management.

### Dev Toolkit Bundle
**Status:** ✅ Production Ready

Automated bundle creation tools:
- **bundle-maker skill** - Interactive bundle creation workflow (no placeholders!)
- **Utility scripts** - Automated creation, validation, and management
- **Working examples** - Minimal and complete bundle templates
- **Comprehensive guide** - Skill creation methodology combining Anthropic and Claude Code best practices

Perfect for creating your own custom bundles or contributing to this marketplace.

### Coming Soon
- Angular Frontend Bundle
- Unity Game Dev Bundle
- Backend Stack Bundle
- Core Workflow Bundle

## 🚀 Quick Start

### 1. Clone This Marketplace

```bash
# Clone to your preferred location
git clone https://github.com/YOUR_USERNAME/claude-skills-marketplace.git
cd claude-skills-marketplace
```

### 2. Add Marketplace to Claude

```bash
# Add this marketplace to Claude Code
/plugin marketplace add .
```

### 3. Install a Bundle

```bash
# Install the React bundle for React development
/plugin install react-frontend-bundle

# Or install dev toolkit to create your own bundles
/plugin install dev-toolkit-bundle
```

### 4. Verify It's Working

Start a conversation in your context:

**For React bundle:**
```
"I need to create a user profile component with Zustand state management"
```

**For dev toolkit:**
```
"Create a new bundle for Angular development"
```

Claude will automatically apply the appropriate skills!

### 5. Check Active Plugins

```bash
/plugin list
```

## 🔄 Context Switching

One of the key benefits of this marketplace is switching between development contexts:

### Working on React Project
```bash
/plugin install react-frontend-bundle
```

### Switching to Angular (when available)
```bash
/plugin uninstall react-frontend-bundle
/plugin install angular-frontend-bundle
```

### Switching to Unity (when available)
```bash
/plugin uninstall react-frontend-bundle
/plugin install unity-gamedev-bundle
```

**Why switch?** Each bundle provides deep, specialized knowledge for its context. Having all bundles active simultaneously would create noise and slower activation. Switching ensures Claude has exactly the expertise you need, when you need it.

## 📁 Repository Structure

```
claude-skills-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace configuration
├── bundles/
│   ├── react-frontend-bundle/    # React development bundle
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       ├── react-patterns/
│   │       │   └── SKILL.md      # ~600 lines
│   │       └── ui-ux-design/
│   │           └── SKILL.md      # ~470 lines
│   │
│   └── dev-toolkit-bundle/       # Bundle creation automation
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
│           └── bundle-maker/
│               ├── SKILL.md
│               ├── references/
│               │   └── skill-creation-guide.md
│               ├── scripts/
│               │   ├── create-bundle.sh
│               │   ├── add-skill-to-bundle.sh
│               │   ├── validate-bundle.sh
│               │   └── README.md
│               └── examples/
│                   ├── minimal-bundle/
│                   └── complete-bundle/
├── docs/
│   ├── INDEX.md                  # Documentation index
│   └── NEXT_STEPS.md             # Roadmap for future bundles
├── README.md                      # This file
└── QUICK_START.md                 # 3-step installation guide
```

## ➕ Creating Your Own Bundles

### Option 1: Use Bundle Maker Skill (Recommended)

```bash
# Install the dev toolkit
/plugin install dev-toolkit-bundle

# Then ask Claude to create a bundle
"Create a new bundle for Angular development"
# or
"Create a bundle for Unity game development"
```

The bundle-maker skill will:
- ✓ Ask for all required information upfront (no placeholders!)
- ✓ Create proper directory structure
- ✓ Generate plugin.json with your info
- ✓ Create skill templates ready to fill in
- ✓ Validate the bundle structure
- ✓ Register in marketplace.json

### Option 2: Use Utility Scripts Directly

```bash
# Navigate to scripts directory
cd bundles/dev-toolkit-bundle/skills/bundle-maker/scripts

# Create bundle structure
./create-bundle.sh my-new-bundle

# Add skills to the bundle
./add-skill-to-bundle.sh ../../my-new-bundle my-skill

# Validate before registering
./validate-bundle.sh ../../my-new-bundle
```

See `bundles/dev-toolkit-bundle/skills/bundle-maker/scripts/README.md` for complete script documentation.

### Option 3: Manual Creation

Follow the structure in `bundles/dev-toolkit-bundle/skills/bundle-maker/examples/minimal-bundle/` as a template.

## 🤝 Contributing

Want to add your bundle to this marketplace?

1. Fork this repository
2. Create your bundle using the bundle-maker skill
3. Test it thoroughly
4. Submit a pull request with:
   - Your bundle in `bundles/your-bundle-name/`
   - Updated marketplace.json
   - Bundle documentation

We welcome contributions for:
- New tech stack bundles (Vue, Svelte, etc.)
- Domain-specific skills (DevOps, data science, etc.)
- Improvements to existing bundles

### External Bundles

You can also reference external bundles without forking:

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
# From the marketplace root directory
cat bundles/react-frontend-bundle/.claude-plugin/plugin.json

# Or explore the bundle structure
ls -la bundles/react-frontend-bundle/
```

## 📚 Learning Resources

- **Claude Code Documentation:** Run `/help` in Claude
- **Plugin System:** Check official Claude Code docs
- **Skill Writing:** See existing skills in `bundles/` for examples

## 🎨 Customization

### Fork and Personalize

1. **Fork this repository** to your GitHub account
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-skills-marketplace.git
   ```
3. **Update marketplace info** in `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "your-marketplace-name",
     "owner": {
       "name": "Your Name",
       "email": "your.email@example.com"
     }
   }
   ```
4. **Customize skills** to match your team's standards:
   ```bash
   # Edit any skill file
   code bundles/react-frontend-bundle/skills/react-patterns/SKILL.md
   ```
5. **Commit and use:**
   ```bash
   git add .
   git commit -m "Personalized marketplace"
   git push
   ```

Now your team can clone your fork and use your customized marketplace!

## 🗺️ Roadmap

### Current Status
- ✅ React Frontend Bundle (production ready)
- ✅ Dev Toolkit Bundle (production ready)
- ✅ Bundle creation automation
- ✅ Validation utilities

### Coming Soon
- ⏳ Angular Frontend Bundle
- ⏳ Unity Game Dev Bundle
- ⏳ Backend Stack Bundle
- ⏳ Core Workflow Bundle (Git, code review, CI/CD)

### Contribute
Have expertise in a tech stack? Create a bundle and submit a PR!

## 📄 License

MIT License - feel free to fork, customize, and share!

## 🙏 Acknowledgments

Built using:
- [Claude Code](https://www.anthropic.com/claude/code) - AI-powered development environment
- Claude Code Plugin System - Modular skill architecture
- Anthropic's skill-creator methodology

---

## ⚡ Quick Commands Reference

```bash
# Installation
git clone https://github.com/YOUR_USERNAME/claude-skills-marketplace.git
/plugin marketplace add .
/plugin install react-frontend-bundle

# Development
/plugin install dev-toolkit-bundle
"Create a new bundle for [your context]"

# Context Switching
/plugin uninstall current-bundle
/plugin install new-bundle

# Check Status
/plugin list
```

**Happy coding!** 🚀

Have questions? Open an issue or check the [docs](docs/INDEX.md) for detailed guides.
