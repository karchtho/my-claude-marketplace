# Sessions Workflow Bundle

Token-efficient session management for Claude Code - load project context at the start of your session and automatically document your work at the end.

## 🎯 What It Does

This bundle provides three essential commands for managing focused development sessions:

- **`/session-start`** - Load project context with brief summaries (standard mode) in ~3200-3500 tokens
- **`/session-start-teach`** - Load context with educational explanations (teacher mode) in ~4200-4500 tokens
- **`/session-end`** - Create session summary, commit changes, and detect commit style in ~2000-2500 tokens

Plus a flexible **session-manager** skill for non-command workflows.

## ⚡ Quick Start

### Installation

```bash
# From your Claude Code session
/plugin install sessions-workflow-bundle@my-claude-marketplace
```

### Basic Workflow

**Standard Mode (brief, efficient):**
```bash
# Start your session - loads all context automatically
/session-start

# ... work on your code ...

# End your session - creates summary and commits
/session-end
```

**Teacher Mode (educational, verbose):**
```bash
# Start with educational context - perfect for learning
/session-start-teach

# ... work on your code with deeper understanding ...

# End your session - creates summary and commits
/session-end
```

### 🎓 Two Session Start Modes

**Standard Mode** (`/session-start`):
- Brief, efficient context loading
- ~300 word summaries
- Focus on actionable information
- **Best for:** Daily work, experienced developers, token efficiency

**Teacher Mode** (`/session-start-teach`):
- Educational explanations and learning context
- ~500-700 word responses with insights
- Step-by-step narration of what's happening
- Discussion questions and alternative approaches
- **Best for:** Learning new codebases, onboarding, understanding patterns

## 📚 Features

### 1. Token-Efficient Context Loading (`/session-start`)

Loads project context in minimal tokens:

```
📚 Loading context...

✓ Latest session: 2026-01-04_bundle-maker.md
  - Implemented dev-toolkit-bundle automation
  - Next: Test bundle creation workflow

✓ CLAUDE.md loaded - No placeholders policy, documentation patterns
✓ README.md loaded - Skills marketplace with 2 production bundles
✓ Project: Claude Code plugins
✓ Git: main branch, ready to commit
✓ Skills: React patterns, UI/UX design, Bundle maker

Ready to work! What would you like to focus on?
```

**What gets loaded:**
- Latest session summary (if exists) - key points only
- Project guidelines from CLAUDE.md (first 50 lines)
- Project overview from README.md (first 100 lines)
- Git status and branch info
- Available plugins/skills
- Project type detection (React, Python, etc.)

### 2. Automatic Session Summaries (`/session-end`)

Creates comprehensive session summaries automatically:

```markdown
# Session Summary - January 5, 2026

## Session Objectives
Implement the sessions workflow bundle for token-efficient project context loading.

## Work Completed
- Created sessions-workflow-bundle structure
- Implemented /session-start with context loading
- Implemented /session-end with automatic commits

## Files Modified
- bundles/sessions-workflow-bundle/.claude-plugin/plugin.json
- bundles/sessions-workflow-bundle/commands/session-start.md
- bundles/sessions-workflow-bundle/commands/session-end.md

## Key Decisions
- Use haiku model for token efficiency
- Dynamic context injection for git commands
- Selective file reading (first N lines only)

## Next Steps
1. Create helper scripts for automation
2. Add comprehensive documentation
3. Test with edge cases
```

### 3. Environment Awareness

Automatically detects:
- **Git state** - Current branch, uncommitted changes, commit history
- **Commit style** - Conventional commits or informal style (matches repo)
- **Project type** - React, Node.js, Python, Angular, etc.
- **Available skills** - Installed plugins and expertise domains
- **Architecture** - From CLAUDE.md project guidelines

### 4. Conventional Commit Support

Analyzes your repository's commit style and:
- Uses conventional commits if detected (feat:, fix:, docs:, etc.)
- Falls back to informal style if that's what's in use
- Ensures consistency with existing commits

### 5. Flexible Session Manager Skill

For non-command workflows:

```
"Create a session summary for what we just worked on"
# → Creates docs/sessions/YYYY-MM-DD_topic.md

"What did we work on in the last session?"
# → Shows latest session summary and next steps

"Load the context from our last session"
# → Reads and explains previous work
```

## 🚀 Usage Patterns

### Pattern 1: Full Automation (Recommended)

**Standard Mode:**
```bash
/session-start          # Load context
# ... 1-2 hours of work ...
/session-end            # Summary + commit
```

**Teacher Mode:**
```bash
/session-start-teach    # Load context with education
# ... 1-2 hours of work ...
/session-end            # Summary + commit
```

**Advantages:**
- Fully automatic
- Optimal token usage (~4500-5000 standard, ~5500-6000 teacher)
- Ensures commits happen
- Consistent documentation
- Teacher mode provides learning context

**Best for:**
- Standard: Regular development sessions, focused work, team projects
- Teacher: Learning new codebases, onboarding, understanding patterns

### Pattern 2: Interactive Workflow

```
"Load the context from last session"
# ... work, get feedback from Claude ...
"Create a session summary of what we did"
"Commit with conventional commits"
```

**Advantages:**
- More interactive and educational
- Can review before committing
- Flexible timing

**Best for:** Learning, exploratory work, complex decisions

### Pattern 3: Hybrid (Complex Work)

**Standard Mode:**
```bash
/session-start                    # Load context
# ... work on complex feature ...
"Take a checkpoint - create a mid-session summary"
# ... continue working ...
/session-end                      # Final commit
```

**Teacher Mode (for learning):**
```bash
/session-start-teach              # Load educational context
# ... work on complex feature with explanations ...
"Take a checkpoint - create a mid-session summary"
# ... continue working ...
/session-end                      # Final commit
```

**Advantages:**
- Automatic structure
- Manual checkpoints for complex work
- Document progress without committing
- Teacher mode helps understand decisions

**Best for:** Long sessions, multi-part features, refactoring, learning complex patterns

## 📊 Token Budget

This bundle is designed for minimal token usage:

| Operation | Tokens | Details |
|-----------|--------|---------|
| `/session-start` | 3200-3500 | Standard mode: brief context |
| `/session-start-teach` | 4200-4500 | Teacher mode: educational context |
| `/session-end` | 2000-2500 | Create summary + commit |
| **Total per session (standard)** | **4500-5000** | Efficient for daily work |
| **Total per session (teacher)** | **5500-6000** | Educational, great for learning |

### Optimization Techniques

- **Selective file reading**: First N lines only (not full files)
- **Compact git output**: `--short`, `--oneline`, `--name-status` flags
- **Dynamic context**: Uses `` !`command` `` pattern (server-side execution)
- **File lists instead of diffs**: Don't load full diffs into context
- **Latest session only**: Read most recent summary, not all history
- **Haiku model**: Most efficient Claude model for structured tasks

## 🔧 How It Works

### `/session-start` Flow

1. **Git detection** - Check if in git repo, get current branch
2. **Context loading** - Read CLAUDE.md, README.md, latest session (first N lines)
3. **Environment detection** - Detect project type, available skills, git state
4. **Summary** - Report loaded context in ~300 words
5. **Ready** - Ask what you want to work on

### `/session-end` Flow

1. **Collect context** - Git diff, git log, todos (minimal output)
2. **Create summary** - Generate `docs/sessions/YYYY-MM-DD_topic.md`
3. **Detect style** - Analyze commit style (conventional vs informal)
4. **Create commit** - Stage changes, commit with appropriate message
5. **Report** - Show summary location and commit hash

## 📁 File Structure

```
sessions-workflow-bundle/
├── commands/
│   ├── session-start.md        # Load project context (standard mode)
│   ├── session-start-teach.md  # Load context with education (teacher mode)
│   └── session-end.md          # Create summary and commit
├── skills/
│   └── session-manager/        # Flexible session workflows
│       ├── SKILL.md
│       ├── scripts/
│       │   ├── detect-commit-style.sh
│       │   ├── detect-project-type.sh
│       │   └── create-session-summary-template.sh
│       └── references/
│           └── session-workflow-guide.md
└── examples/
    └── session-summary-template.md
```

## 🎓 Examples

### Example 1: React Development Session

```bash
/session-start

📚 Loading context...
✓ Latest session: 2026-01-04_component-refactor.md
  - Converted class components to hooks
  - Next: Add Zustand state management

✓ CLAUDE.md: React with Zustand, TypeScript strict mode
✓ README.md: E-commerce frontend application
✓ Project: React, Next.js
✓ Git: feature/zustand-state branch, 12 files modified
✓ Skills: React patterns (hooks, state), UI/UX design

What would you like to work on today?

# ... work on Zustand state management ...

/session-end

✅ Session summary created: docs/sessions/2026-01-05_zustand-state.md
✅ Commit: feat(state): implement Zustand store for product state
```

### Example 2: Bug Fix Session

```bash
/session-start

📚 Loading context...
✓ Latest session: 2026-01-04_feature-auth.md
✓ Project: Node.js backend API
✓ Git: main branch, ready to work

# ... investigate and fix authentication bug ...

/session-end

✅ Session summary: docs/sessions/2026-01-05_auth-bug-fix.md
✅ Commit: fix(auth): resolve token expiration handling in refresh endpoint
```

### Example 3: Documentation Session

```bash
/session-start
# ... update README, add API docs, create guides ...
/session-end

✅ Session summary: docs/sessions/2026-01-05_documentation.md
✅ Commit: docs: improve API documentation and setup guides
```

## ⚙️ Configuration

### Customizing Session Summaries

The bundle uses a standard template in `docs/sessions/YYYY-MM-DD_topic.md`:

```markdown
# Session Summary - [Date]

## Session Objectives
[What you were doing]

## Work Completed
- [Key accomplishment 1]
- [Key accomplishment 2]
- [Key accomplishment 3]

## Files Modified
[Files changed]

## Key Decisions
[If applicable]

## Issues Encountered
[If applicable]

## Next Steps
[Specific next actions]
```

You can customize this by editing the `/session-end` command.

### Adjusting Token Budget

By default, the commands target ~4500-5000 tokens per full session (standard) or ~5500-6000 (teacher).

To **reduce tokens further**:
- Use `/session-start` (standard mode) instead of `/session-start-teach`
- Edit commands to skip reading CLAUDE.md or README.md
- Use `/session-end` without creating detailed summaries
- Reduce git history analysis (currently checks 5 commits)

To **load more context**:
- Use `/session-start-teach` for educational content
- Increase file size limits (currently first N lines)
- Load more documentation files
- Include more git history

## 🤝 Integration with Other Bundles

This bundle works seamlessly with all other bundles:

- **React bundle**: Load React context at start, document React work at end
- **Bundle-maker**: Track bundle creation sessions
- **Any project**: Works with CLAUDE.md and README.md from any domain

Sessions become project memory that persists across contexts.

## 🐛 Troubleshooting

### "Not in git repo" - Is this a problem?

No! The commands handle this gracefully:
- Session start works without git
- Session end creates summary but doesn't commit
- You can manually commit later

### Session summary not created?

Check:
1. Is `docs/sessions/` directory writable?
2. Are you running `/session-end` from project root?
3. Does git have your name configured? (`git config user.name`)

### Commit style not detected correctly?

The bundle analyzes last 5 commits:
- If 50%+ use conventional commits → uses that style
- Otherwise → uses informal style (matches repo)

You can manually specify style by editing `/session-end` command.

## 📚 Learn More

- **Full guide**: See `skills/session-manager/references/session-workflow-guide.md`
- **Examples**: See `examples/session-summary-template.md`
- **Project context**: Check CLAUDE.md in this repository

## 🎯 Best Practices

✅ **DO:**
- Use `/session-start` first to load context
- Document decisions and blockers during work
- End with `/session-end` to create summary and commit
- Reference previous sessions when relevant
- Keep summaries concise (200-500 words)

❌ **DON'T:**
- Write exhaustive summaries
- Create summaries for tiny changes
- Skip `/session-start` (you miss important context)
- Commit without summary (hard to understand later)
- Mix unrelated work in one session

## 🚀 Next Steps

1. **Install the bundle**
   ```bash
   /plugin install sessions-workflow-bundle@my-claude-marketplace
   ```

2. **Start a session**
   ```bash
   /session-start
   ```

3. **Work on your project**
   - Make changes, solve problems, learn things

4. **End your session**
   ```bash
   /session-end
   ```

5. **Review your session summary**
   ```bash
   cat docs/sessions/YYYY-MM-DD_*.md
   ```

## 📄 License

MIT - Same as the parent marketplace

## 🤝 Contributing

Found a bug or want to improve this bundle? Contributions welcome!

Use the bundle-maker skill to extend:
- Add support for more git services (GitHub, GitLab workflows)
- Create specialized skills for specific domains
- Add metrics and analytics

## Questions?

See the session-manager skill documentation or review examples in the marketplace README.

---

**Happy sessions!** 🎯

Build great things with focused, well-documented work sessions.
