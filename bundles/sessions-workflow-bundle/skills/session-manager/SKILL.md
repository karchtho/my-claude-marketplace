---
name: session-manager
description: Activates when the user asks to "create session summary", "summarize this session", "end the session", "start a session", "load context", "what did we work on", "session notes", "document this session", or wants to track, document, and manage work sessions.
version: 1.0.0
---

# Session Manager Skill

Provides flexible session management and documentation for projects using session workflows, including context loading, summary creation, and work tracking.

## What is Session Management?

**Sessions** are focused work periods where you:
1. Load project context at start
2. Work on specific tasks
3. Document accomplishments at end
4. Commit changes with clear messages

This skill helps with all four phases, especially when not using the slash commands.

## Core Concepts

### Session Lifecycle

```
Start Session
  ↓ Load project context
  ↓ Understand constraints and previous work
  ↓
Do Work
  ↓ Make code changes
  ↓ Write documentation
  ↓ Track decisions
  ↓
End Session
  ↓ Document accomplishments
  ↓ Commit to git
  ↓ Create summary for next session
```

### Session Context

Every session should track:
- **What you're working on** - Clear objective
- **How it fits** - Understand previous work and constraints
- **What changed** - What files were modified
- **Why it changed** - Decisions and reasoning
- **What's next** - Specific next steps

### Session Workflow

**Pattern**: `SessionStart → Work → SessionEnd → Summary`

The best part: You can use `/session-start` and `/session-end` for automatic workflow, or ask this skill for help doing it manually.

## Use Cases

### Use Case 1: Document Previous Work

**Scenario**: You've been working for 2 hours and want to summarize what you did.

**Ask this skill**: "Create a session summary for what we just worked on"

**What happens**:
1. Analyze changed files (from git diff)
2. Infer work area and accomplishments
3. Generate session summary template
4. Create session document in docs/sessions/
5. Show you the summary for review

### Use Case 2: Understand Current State

**Scenario**: You're returning to a project after a week away and want to know what's been done.

**Ask this skill**: "What did we work on in the last session?"

**What happens**:
1. Find latest session summary
2. Extract key accomplishments and next steps
3. Show you what was completed
4. Report what still needs to be done

### Use Case 3: Continue Previous Work

**Scenario**: You want to pick up where the last session left off.

**Ask this skill**: "Load the context from our last session and tell me the next steps"

**What happens**:
1. Find latest session summary
2. Extract: completed work, next steps, any blockers
3. Check git history for recent changes
4. Show you exactly where to continue

### Use Case 4: Track Session Progress

**Scenario**: You want to know how much you've accomplished in this session.

**Ask this skill**: "How many files have we changed so far?"

**What happens**:
1. Check git status
2. Analyze changes (staged, unstaged, untracked)
3. Show summary of work so far
4. Help you decide if ready to commit

### Use Case 5: Plan Next Session

**Scenario**: You want to document what should be done next.

**Ask this skill**: "Create a session summary and highlight the next 3 steps"

**What happens**:
1. Document current work in session summary
2. Analyze remaining tasks
3. Create numbered list of next steps
4. Save summary for next session's /session-start

### Use Case 6: Review Project Context

**Scenario**: You want to quickly understand a project's setup and constraints.

**Ask this skill**: "What does CLAUDE.md say about this project's architecture?"

**What happens**:
1. Read project's CLAUDE.md
2. Extract: architecture patterns, tools, constraints
3. Explain key architectural decisions
4. Show you important guidelines

### Use Case 7: Session Notes

**Scenario**: You want to jot down important insights during the session.

**Ask this skill**: "Add this note to the session summary: 'Need to handle edge case with null values in auth middleware'"

**What happens**:
1. Find or create current session summary (draft)
2. Add your note to "Issues Encountered" section
3. Preserve for final /session-end

### Use Case 8: Multiple Concurrent Sessions

**Scenario**: You're working on multiple projects and want to keep sessions separate.

**Ask this skill**: "Create a new session summary for the frontend work I just did"

**What happens**:
1. Analyze changed frontend files
2. Create separate session document (not mixed with backend work)
3. Keep sessions logically organized in docs/sessions/

## Workflow Patterns

### Pattern 1: Slash Command Workflow (Recommended)

```bash
/session-start          # Load context automatically
# ... work for 1-2 hours ...
/session-end            # Create summary and commit automatically
```

**With Teacher Mode:**
```bash
/session-start --teacher    # Load context with educational explanations
# ... work for 1-2 hours ...
/session-end                # Create summary and commit automatically
```

**Advantages:**
- Fully automatic
- Consistent format
- Ensures commits happen
- Optimal token usage (standard mode)
- Teacher mode helps learn patterns and best practices

**Token cost** (with v2.0 doc scanning):
- Standard: ~4500-5500 per session start (start + end combined ~5500-6500)
- Teacher mode: ~5500-6500 per session start (includes educational content; start + end combined ~6500-7500)

### Pattern 2: Skill-Based Workflow (Flexible)

```
"Load the context from last session"
# ... read response, understand state ...
# ... work as needed ...
"Create a session summary of what we did"
"Commit with conventional commit message"
```

**Advantages:**
- More interactive
- Can review before committing
- Flexible timing
- Educational (learn as you go)

**Token cost**: ~4000-6000 per session (more back-and-forth)

### Pattern 3: Hybrid Workflow (Best for Complex Work)

```bash
/session-start                          # Load context
# ... work on complex feature ...
"Take a checkpoint - create a mid-session summary"
# ... continue working ...
/session-end                            # Final summary and commit
```

**Advantages:**
- Automatic start/end
- Manual checkpoints for complex work
- Document progress without committing
- Learn from feedback

**Token cost**: ~4500-5500 per session

## Key Principles

### 1. Context is Critical

Every session starts by understanding:
- **Previous work** - What was completed
- **Project constraints** - Architecture, patterns, tools
- **Current state** - What's uncommitted
- **Available expertise** - What skills/plugins are active

### 2. Summaries are Essential

Good summaries:
- Document WHAT was done (not exhaustive, just main points)
- Explain WHY decisions were made
- List specific NEXT STEPS
- Help future you understand past decisions

### 3. Commits are Atomic

Each session = one commit (or one logical unit)
- Related changes together
- Clear commit message
- Traceable in git history

### 4. Sessions are Continuity

Each session:
- Reads summary from previous session
- Builds on previous work
- Leaves clear notes for next session
- Creates project memory over time

## Teacher Mode

**Teacher Mode** is an educational enhancement for `/session-start` that transforms context loading into a learning experience.

### What is Teacher Mode?

Enable with: `/session-start --teacher`

Instead of a brief context summary, you get:
- **Step-by-step narration** of what Claude is doing and why
- **Learning context** about patterns, conventions, and best practices
- **Discussion questions** to deepen understanding
- **Alternative approaches** with trade-offs explained

### When to Use Teacher Mode

Use teacher mode when:
- **Learning a new codebase** - Understand patterns and conventions
- **Onboarding to a project** - Get educational context about architecture
- **Understanding decisions** - Learn why previous sessions chose certain approaches
- **Exploring best practices** - See how project patterns align with industry standards
- **Teaching others** - Share the expanded explanation with team members

### Teacher Mode Behavior

When teacher mode is enabled, `/session-start` will:

1. **Explain every action taken**
   - "I'm reading CLAUDE.md to understand project conventions..."
   - "Checking git status helps identify uncommitted work that might affect today's tasks"

2. **Provide learning context**
   - Educational notes about conventions and patterns
   - Explanations of why certain practices are used
   - Industry best practices connections

3. **Ask follow-up questions**
   - Check understanding of previous work
   - Clarify unfamiliar patterns
   - Explore preferences for next steps

4. **Show alternative approaches**
   - Present multiple paths forward
   - Explain trade-offs between options
   - Encourage critical thinking about choices

### Mode Detection

Starting with `/session-start` version 2.0, the command includes explicit **MODE DETECTION** at the top:

```
## ⚠️ MODE DETECTION - READ THIS FIRST

**CRITICAL**: Check if the `--teacher` flag was provided when this command was invoked.

### If `--teacher` flag IS PRESENT:
→ **ACTIVATE TEACHER MODE**
→ Follow teacher mode instructions exclusively

### If `--teacher` flag IS NOT PRESENT:
→ **ACTIVATE STANDARD MODE**
→ Follow standard mode instructions exclusively

**You MUST choose ONE mode. Do NOT blend instructions from both modes.**
```

This explicit routing makes it impossible for Claude to miss which mode is active.

### Documentation Scanning

The command now scans for and lists available documentation during session start:

**Pattern matching**:
- `docs/technical/` or `docs/technique/` (English/French)
- README.md or INDEX.md files in docs/
- Limits to 20 files to conserve tokens

**Token cost**: ~300-700 tokens for listing (vs 20,000+ tokens to load full content)

**What happens**:
- Standard mode: Lists doc count, mentions if relevant files found
- Teacher mode: Explains what docs exist, offers to review specific files

### Example Comparison

**Standard Mode (without --teacher):**
```
📚 Session Context Loaded

✓ Current branch: feature-auth
✓ Git status: 3 files modified
✓ Documentation: 8 files in docs/ (found docs/technical/README.md)
✓ Project guidelines: Authentication patterns, session management
✓ Previous work: Implemented JWT token generation

What would you like to work on today?
```

**Teacher Mode (with --teacher):**
```
📚 Session Context Loaded (Teacher Mode)

🔍 Context Discovery Process:
I started by reading CLAUDE.md to understand how this project is structured...

✓ Current branch: feature-auth
  → This branch name follows the "feature-" prefix convention, which helps
    team members quickly identify feature branches vs bugfix branches

✓ Git status: 3 files modified (auth.ts, jwt.ts, auth.test.ts)
  → Having uncommitted changes is normal mid-feature, but be aware:
    - These changes should be related to the same logical unit
    - Consider if they're ready to commit before starting new work

✓ Documentation: 8 files found in docs/
  → I found docs/technical/README.md which documents authentication patterns
  → Would you like me to review docs/technical/auth-flow.md to understand the design?

✓ Project guidelines: Authentication patterns, session management
  → This project uses JWT over session tokens because:
    - Stateless authentication scales better
    - Frontend can decode tokens without backend call
    - Common pattern in modern SPAs

✓ Previous work: Implemented JWT token generation
  → The previous session created the token generation logic...
  → Notice how they structured error handling for edge cases

💡 Learning Points:
- Stateless auth with JWT is scalable but requires careful token management
- Documentation helps maintain consistent patterns across the project
- Feature branches help isolate work and enable code review

🤔 Discussion Questions:
- Do you understand why JWT was chosen over session tokens?
- Would you like me to explain the token refresh strategy in the docs?

🛤️ Possible Paths Forward:
A) Add refresh token logic to improve security
B) Implement token revocation for logout
C) Add comprehensive auth error handling tests

What would you like to explore today?
```

### Token Cost Consideration

**After documentation scanning addition (v2.0)**:

- **Standard mode**: ~4500 tokens for session start (up from 3700)
  - Context loading: ~3200 tokens
  - Documentation scanning: ~300-500 tokens
  - Response: ~400-800 tokens

- **Teacher mode**: ~5500 tokens for session start (up from 4700)
  - Context loading: ~4000 tokens
  - Documentation scanning: ~300-500 tokens
  - Response: ~1000-1500 tokens

**Still well within budget** (target: <6000 tokens per session start)

**Recommendation**: Use teacher mode selectively when learning is the priority. Once familiar with the codebase, switch back to standard mode for efficiency. Documentation is listed but not loaded, keeping token usage reasonable.

## Session Summary Format

Standard format for all session summaries:

```markdown
# Session Summary - [Date]

## Session Objectives
[1-2 sentences about what this session was for]

## Work Completed
- [Key accomplishment 1]
- [Key accomplishment 2]
- [Key accomplishment 3]

## Files Modified
[List of main files changed]

## Key Decisions
[If applicable: Important architectural or design decisions]

## Issues Encountered
[If applicable: Problems and how they were solved]

## Next Steps
1. [Specific next action]
2. [Specific next action]
3. [Specific next action]
```

**Word count**: 200-500 words (concise, not exhaustive)

## Best Practices

### ✅ DO:

- Start session with `/session-start` to load context
- Take notes during work on key decisions
- Group related changes in single session
- End with `/session-end` to create summary and commit
- Write clear commit messages
- List specific next steps (not vague goals)

### ❌ DON'T:

- Write exhaustive session summaries (just key points)
- Create a session summary for tiny changes (bug fixes might not need summary)
- Commit without summary (unless very minor)
- Skip /session-start (you miss important context)
- Mix unrelated work in one session (hard to summarize)

## Examples

### Example 1: Feature Development Session

```
User: /session-start

🎓 Loading context...
✓ Latest session: feature-auth-jwt.md
  - Implemented JWT token generation
  - Next: Add token refresh logic

[Continue working for 2 hours on refresh tokens]

User: /session-end

Session Summary - January 5, 2026

## Session Objectives
Implement JWT refresh token logic for authentication system.

## Work Completed
- Added refresh token endpoint (POST /auth/refresh)
- Implemented token expiration validation
- Added refresh token rotation for security
- Created tests for token lifecycle

## Files Modified
- src/routes/auth.ts
- src/services/jwt.ts
- tests/auth.test.ts

## Key Decisions
- Used rotating refresh tokens (old token invalidated on new issue)
- Store refresh tokens in database for revocation capability
- 7-day refresh token expiry vs 15-minute access token

## Next Steps
1. Add refresh token revocation endpoint
2. Implement cleanup job for expired tokens
3. Add refresh token to session management

✅ Commit: feat(auth): implement JWT refresh token logic
```

### Example 2: Bug Fix Session

```
User: /session-start

[Load context, find recent changes]

User: [Fix bug in form validation]

User: /session-end

Session Summary - January 5, 2026

## Session Objectives
Fix form validation bug preventing email submission.

## Work Completed
- Fixed regex pattern for email validation
- Removed overly strict length constraint
- Added test cases for edge cases

## Files Modified
- src/utils/validation.ts
- tests/validation.test.ts

## Issues Encountered
- Initial regex too strict, blocked valid emails
- Solution: Updated to RFC 5322 compliant pattern

## Next Steps
1. Test with internationalized email domains
2. Consider adding email verification before submit
3. Review other validation patterns for similar issues

✅ Commit: fix(validation): improve email validation regex
```

### Example 3: Documentation Session

```
User: /session-start

User: [Update README and add API documentation]

User: /session-end

Session Summary - January 5, 2026

## Session Objectives
Improve project documentation for better onboarding.

## Work Completed
- Updated README with complete setup instructions
- Added API endpoint documentation
- Created architecture overview guide
- Added troubleshooting section

## Files Modified
- README.md
- docs/API.md
- docs/ARCHITECTURE.md

## Next Steps
1. Add video walkthrough of setup process
2. Create contributor guidelines
3. Add FAQ section

✅ Commit: docs: improve project documentation
```

## References

For detailed information, see:
- **Session workflow guide**: `references/session-workflow-guide.md`
- **Slash commands**: Use `/session-start` and `/session-end` for automatic workflow
- **Git integration**: Sessions work seamlessly with git commit history

## Quick Tips

1. **Use `/session-start` first** - Always load context before starting work
2. **Enable teacher mode when learning** - Use `/session-start --teacher` for new codebases
3. **Take checkpoint summaries** - For long sessions, document mid-session progress
4. **Use `/session-end` at end** - Automatic summary creation and commit
5. **Review summaries** - Check docs/sessions/ to understand project history
6. **Reference previous sessions** - Build on what was learned before
7. **Switch to standard mode when familiar** - Save tokens once you know the patterns

## When to Use This Skill vs Slash Commands

| Situation | Use | Reason |
|-----------|-----|--------|
| Starting a new session | `/session-start` | Automatic, optimal tokens |
| Learning new codebase | `/session-start --teacher` | Educational context, explanations |
| Ending session normally | `/session-end` | Automatic, creates commit |
| Need to review context | This skill | "What did we work on?" |
| Need to document mid-session | This skill | "Checkpoint summary..." |
| Working in bursts | This skill | More flexible timing |
| Want full automation | `/session-start` + `/session-end` | Fastest, most efficient |
| Want to understand patterns | `/session-start --teacher` | Learn while loading context |

## Integration with Other Skills/Bundles

This skill works with all other bundles and skills:
- **React bundle**: Track React component development sessions
- **Bundle-maker**: Document new bundle creation sessions
- **Any project**: Load CLAUDE.md and project context

Sessions become project memory that persists across contexts.

## Learn More

See `references/session-workflow-guide.md` for:
- Complete session lifecycle documentation
- Advanced patterns for complex projects
- Multi-repository and monorepo workflows
- Session metrics and analytics
- Integration with CI/CD pipelines
