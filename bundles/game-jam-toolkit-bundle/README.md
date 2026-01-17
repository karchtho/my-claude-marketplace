# Game Jam Toolkit Bundle

Your complete game jam development partner for Unity 2D projects. Validates your starter scripts, guides modern architecture, and generates production-ready features during the jam.

## What It Does

This bundle transforms game jam development with three core capabilities:

1. **Pre-Jam Validation** - Audit your 20 starter scripts before the jam starts
2. **Modern Architecture Guidance** - Build features using Input System, async/await, dependency injection, and memory optimization
3. **Jam-Time Code Generation** - Design features → generate complete scripts → integrate → test

Built specifically for your [unity-starter](https://github.com/karchtho/unity-starter) repository with its 20 C# starter scripts (GameManager, AudioManager, InputManager, UIManager, PoolingManager, PlayerController, Enemy systems, etc.).

## Quick Start

### Pre-Jam (1-2 Days Before)

```bash
# 1. Validate all your starter scripts
/review-starters

# 2. Check modern pattern readiness
Ask: "audit my scripts for modern patterns"

# 3. Run setup checklist
/jam-status
```

### During Jam

```bash
# 1. Design a feature
/design-feature
Describe: "I need a boss enemy with 3 attack patterns"
→ Get: Architecture plan, class structure, integration points

# 2. Generate the code
/generate-feature
Describe: "Generate boss enemy based on this architecture"
→ Get: Complete, compilable C# scripts ready to paste

# 3. Team member code review
/review-code
Paste: Their script
→ Get: Instant feedback on patterns, modern practices, integration

# 4. Check integration
Ask: "validate this integrates with my starters"
→ Get: Dependency map, initialization order, potential issues
```

## Skills & Commands

### 1. **validate-starter-scripts**
Comprehensive audit of your 20 starter scripts.

**Triggers:**
- `/review-starters` command
- "validate my starter scripts"
- "code audit" or "quality check"

**Checks:**
- Code quality and consistency
- Best practices (Singleton patterns, error handling, null checks)
- Integration health between scripts
- Memory safety (pooling, cleanup, leaks)
- Modern pattern readiness

**Output:**
- Critical issues (must fix)
- Best practice suggestions
- Integration warnings
- Modern pattern gaps
- Ready status

---

### 2. **modern-patterns-audit**
Analyzes scripts against modern Unity development practices.

**Triggers:**
- "modern patterns" or "modern practices"
- "Input System audit"
- "async/await review"
- "is my code up to date?"

**Evaluates:**
- **Input System** - Ready for modern Input System (not legacy)?
- **Async/Await** - Where coroutines should be async?
- **Dependency Injection** - Systems loose or tightly coupled?
- **Memory Optimization** - Pooling, Addressables, resource cleanup
- **Architecture** - Can features plug in cleanly?

**Output:**
- Pattern readiness analysis
- Modernization opportunities
- Action items (prioritized)

---

### 3. **jam-prep-checklist**
Interactive walkthrough ensuring project readiness.

**Triggers:**
- "am I ready to start the jam?"
- "pre-jam checklist"
- `/jam-status` (day before jam)
- "final checks"

**Verifies:**
- All 20 starter scripts in project
- Manager initialization order
- Key prefabs created
- Input System setup
- Scene hierarchy
- Team project structure
- Performance baseline

**Output:**
- ✓ Completed items
- ⚠ Items needing attention
- ❌ Critical blockers
- Final verdict: "Ready to jam!" or action items

---

### 4. **feature-architect**
Designs game feature architecture before coding.

**Triggers:**
- `/design-feature` command
- "design a feature" or "plan out"
- "how should I structure..."
- "what classes do I need?"

**Takes:** Feature description
Example: "I need a shop system where players buy upgrades"

**Produces:**
- System overview
- Class structure & relationships
- Dependency map
- Integration strategy (connects to which managers)
- Modern patterns used (Input System, async, DI)
- Code skeleton (class signatures)
- Next step indicator

**Output:** Ready for `/generate-feature`

---

### 5. **feature-generator**
Writes complete, production-ready C# scripts.

**Triggers:**
- `/generate-feature` command
- "generate a script" or "write a script"
- "implement this feature"

**Generates Code That:**
- Matches your starter patterns exactly
- Uses modern practices (Input System, async/await, DI, pooling)
- Integrates seamlessly with GameManager, managers, utilities
- Is production quality (error handling, null checks, logging)
- Is memory safe (pooling, cleanup, no leaks)
- Is well-documented

**Output:**
- Full C# code (ready to copy/paste)
- Integration notes (what to wire in Inspector)
- Modern pattern usage explained
- Performance notes
- Ready to test immediately

---

### 6. **code-reviewer**
Fast feedback during jam without blocking workflow.

**Triggers:**
- `/review-code` command
- "feedback on code"
- "code review"
- "is this good?"
- "does this follow the pattern?"

**Reviews For:**
- Starter pattern compliance
- Modern practices (Input System, async, DI, pooling)
- Memory safety
- Integration readiness
- Performance
- Best practices (error handling, null checks)
- Architectural consistency

**Output:**
- Status (✓ Good / ⚠ Minor issues / ❌ Rework needed)
- Pattern match assessment
- Modern practice usage
- Memory safety analysis
- Integration check
- Specific issues found
- Quick fix suggestions
- Ready to ship or action items

---

### 7. **integration-validator**
Ensures new code works with existing systems.

**Triggers:**
- "does this work with my starters?"
- "integration check"
- "dependencies"
- "will this work with the rest?"
- "initialization order"

**Validates:**
- New code ↔ starter scripts compatibility
- Manager dependencies
- Initialization order
- Circular dependencies
- Reference integrity
- Event/callback chains
- Pooling integration
- Async coordination

**Output:**
- Integration map
- Dependency graph
- Initialization sequence
- Compatibility check
- Potential issues
- Connection checklist
- Ready to integrate or fixes needed

---

## Agents (Advanced Use)

### @jam-architect
System design expert for game jam features. Collaborates on complex architecture decisions, Integration patterns, and modern best practices.

```
@jam-architect: Design a progression system where players unlock abilities through level completion
```

### @feature-developer
Writes complete, production-ready C# scripts. Matches your starter patterns, uses modern practices, handles integration.

```
@feature-developer: Generate the full UIManager upgrades panel based on this architecture
```

### @code-quality
Code review focused on jam-time quality. Catches memory leaks, pattern inconsistencies, async issues, pooling problems without blocking workflow.

```
@code-quality: Review this enemy spawner - is it efficient during high-spawn moments?
```

---

## Workflows

### Pre-Jam Workflow

1. **Day 3-4 Before:**
   ```
   /review-starters
   → Read full validation report
   → Discuss with team if changes needed
   ```

2. **Day 2 Before:**
   ```
   Ask: "audit my scripts for modern patterns"
   → Review modernization opportunities
   → Decide what to update before jam
   ```

3. **Day 1 Before:**
   ```
   /jam-status
   → Run prep checklist
   → Fix any setup issues
   → Team confirms everyone ready
   ```

### Jam-Time Workflow (Per Feature)

1. **Design:**
   ```
   /design-feature
   → Describe feature needed
   → Review architecture with team
   → Approve design before coding
   ```

2. **Generate:**
   ```
   /generate-feature
   → Paste architecture
   → Get complete scripts
   → Copy/paste into project
   ```

3. **Review (Optional):**
   ```
   /review-code
   → Any team member code submitted
   → Get instant feedback
   → Fix issues (usually minor)
   ```

4. **Integrate:**
   ```
   Ask: "validate this integrates with my starters"
   → Check dependencies
   → Confirm initialization order
   → Ready to test
   ```

5. **Test & Move On:**
   ```
   Test in editor
   → Works? Ship it
   → Issues? @code-quality reviews specific problems
   ```

---

## Modern Patterns Covered

This bundle emphasizes these modern Unity practices:

### Input System
- Modern Input System (not legacy Input.GetKey)
- Rebindable controls
- Input actions
- Multiple device support

### Async/Await
- Modern async/await patterns
- Async/await instead of coroutines
- Proper async cancellation
- Task-based workflows

### Dependency Injection
- Loose coupling between systems
- Constructor injection
- Interface-based design
- Service locators (when appropriate)

### Memory Optimization
- Object pooling integration
- Resource cleanup
- Addressables usage
- No unnecessary allocations

### Architecture
- Clean architecture
- Systems that integrate cleanly
- Event-based communication
- Proper initialization order

---

## Team Collaboration Tips

### Share Pre-Jam Results
```
Run /review-starters → save report
Share with team → discuss improvements
Everyone understands baseline code quality
```

### Use `/jam-status` for Daily Health Checks
```
Morning standup: /jam-status
→ Quick view of code quality
→ Any integration issues surfacing?
→ Memory leaks or patterns breaking?
```

### Code Review During Crunch
```
Team members submit code → /review-code
Fast feedback without blocking
Keep standards high without slowing development
```

### Validate Integrations Early
```
Before merging features: integration-validator
Catch cross-system issues early
Prevent last-minute integration problems
```

---

## File Structure

```
game-jam-toolkit-bundle/
├── .claude-plugin/
│   └── plugin.json          # Bundle manifest with 7 skills, 3 agents, 5 commands
├── skills/
│   ├── validate-starter-scripts/SKILL.md
│   ├── modern-patterns-audit/SKILL.md
│   ├── jam-prep-checklist/SKILL.md
│   ├── feature-architect/SKILL.md
│   ├── feature-generator/SKILL.md
│   ├── code-reviewer/SKILL.md
│   └── integration-validator/SKILL.md
└── README.md               # This file
```

---

## Quick Reference

| Need | Use |
|------|-----|
| Check if starters are solid | `/review-starters` |
| Verify modern pattern readiness | Ask: "audit for modern patterns" |
| Pre-jam setup check | `/jam-status` |
| Design a new feature | `/design-feature` |
| Write a feature | `/generate-feature` |
| Quick code feedback | `/review-code` |
| Verify integration | `integration-validator` skill |
| Complex design help | `@jam-architect` agent |
| Advanced code generation | `@feature-developer` agent |
| Deeper code review | `@code-quality` agent |

---

## Design Philosophy

**No boilerplate.** Code generated matches your starters exactly.

**Modern first.** Input System, async/await, DI, and pooling are built-in, not optional.

**Team-friendly.** Fast reviews and feedback during crunch time.

**Integration-focused.** Everything designed to work with your existing starter scripts.

**Jam-optimized.** Design → generate → test → next feature. No refactoring needed.

---

## For Your Team

This bundle is configured specifically for:
- **Your 20 starter scripts** from [unity-starter](https://github.com/karchtho/unity-starter)
- **2D game development** (platformers, puzzles, UI-heavy games)
- **Modern C# and Unity practices** (Input System, async/await, DI, pooling)
- **Team collaboration** during high-pressure game jams

Share this README with your team before the jam so everyone knows what's available.

---

## Questions?

The bundle is self-documenting through skills. Ask any of the agents or commands directly during the jam if you need help.

Good luck with your game jam! 🎮
