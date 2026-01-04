# Comprehensive Skill Creation Guide

This guide combines methodologies from both **Anthropic's skill-creator** and **Claude Code's skill-development** to provide a complete skill creation workflow.

## Table of Contents

1. [Understanding Skills](#understanding-skills)
2. [Skill Anatomy](#skill-anatomy)
3. [Core Principles](#core-principles)
4. [Skill Creation Process](#skill-creation-process)
5. [Progressive Disclosure Patterns](#progressive-disclosure-patterns)
6. [Writing Style Requirements](#writing-style-requirements)
7. [Validation and Testing](#validation-and-testing)
8. [Common Mistakes to Avoid](#common-mistakes-to-avoid)

## Understanding Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks—they transform Claude from a general-purpose agent into a specialized agent equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. **Specialized workflows** - Multi-step procedures for specific domains
2. **Tool integrations** - Instructions for working with specific file formats or APIs
3. **Domain expertise** - Company-specific knowledge, schemas, business logic
4. **Bundled resources** - Scripts, references, and assets for complex and repetitive tasks

## Skill Anatomy

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   ├── description: (required)
│   │   └── version: (optional, recommended for plugins)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation loaded into context as needed
    └── examples/         - Working code examples (formerly assets/)
```

### SKILL.md (Required)

Every SKILL.md consists of:

**Frontmatter (YAML):**
- `name`: The skill identifier
- `description`: PRIMARY TRIGGERING MECHANISM - must include:
  - What the skill does
  - Specific trigger phrases users would say
  - Contexts when skill should activate
  - Use third-person format: "This skill should be used when..."

**Body (Markdown):**
- Instructions and guidance for using the skill
- Only loaded AFTER the skill triggers
- Should be lean (1,500-2,000 words ideal, <5k max)
- Written in imperative/infinitive form

### Bundled Resources (Optional)

#### Scripts (`scripts/`)

Executable code for tasks requiring deterministic reliability or repeatedly rewritten code.

**When to include:**
- Same code is rewritten repeatedly
- Deterministic reliability is needed
- Complex operations benefit from tested utilities

**Examples:**
- `scripts/rotate_pdf.py` for PDF rotation
- `scripts/validate-schema.sh` for validation
- `scripts/parse-config.py` for configuration parsing

**Benefits:**
- Token efficient (can be executed without loading into context)
- Deterministic behavior
- Reusable across tasks

**Note:** Scripts may still need to be read by Claude for patching or environment-specific adjustments.

#### References (`references/`)

Documentation and reference material loaded into context as needed to inform Claude's process.

**When to include:**
- Documentation Claude should reference while working
- Detailed patterns and techniques
- API specifications and schemas
- Migration guides and advanced features

**Examples:**
- `references/patterns.md` for detailed implementation patterns
- `references/api-docs.md` for API specifications
- `references/advanced.md` for advanced techniques
- `references/migration.md` for migration strategies

**Use cases:**
- Database schemas
- API documentation
- Domain knowledge
- Company policies
- Detailed workflow guides

**Benefits:**
- Keeps SKILL.md lean
- Loaded only when Claude determines it's needed
- Progressive disclosure of information

**Best practice:**
- For files >10k words, include grep search patterns in SKILL.md
- Information should live in EITHER SKILL.md OR references, not both
- Prefer references for detailed information unless truly core to skill

#### Examples (`examples/`)

Working code examples and templates intended for copying or modification.

**When to include:**
- Complete, runnable scripts
- Configuration file templates
- Boilerplate code
- Sample implementations

**Examples:**
- `examples/basic-usage.sh` for basic usage
- `examples/advanced-config.json` for configuration
- `examples/component-template.tsx` for React components

**Benefits:**
- Users can copy and adapt directly
- Demonstrates working implementations
- Reduces errors by providing tested examples

## Core Principles

### 1. Concise is Key

The context window is a public good. Skills share the context window with everything else Claude needs: system prompt, conversation history, other skills' metadata, and the actual user request.

**Default assumption: Claude is already very smart.**

Only add context Claude doesn't already have. Challenge each piece of information:
- "Does Claude really need this explanation?"
- "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### 2. Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability:

**High freedom (text-based instructions):**
- Multiple approaches are valid
- Decisions depend on context
- Heuristics guide the approach

**Medium freedom (pseudocode or scripts with parameters):**
- A preferred pattern exists
- Some variation is acceptable
- Configuration affects behavior

**Low freedom (specific scripts, few parameters):**
- Operations are fragile and error-prone
- Consistency is critical
- A specific sequence must be followed

Think of Claude as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### 3. Progressive Disclosure

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words, ideally 1,500-2,000)
3. **Bundled resources** - As needed by Claude (unlimited*)

*Unlimited because scripts can be executed without reading into context window.

## Skill Creation Process

Follow these steps in order, skipping only if there is a clear reason why they are not applicable.

### Step 1: Understanding the Skill with Concrete Examples

**Skip this step only when the skill's usage patterns are already clearly understood.**

To create an effective skill, clearly understand concrete examples of how the skill will be used. This understanding can come from either direct user examples or generated examples validated with user feedback.

**Example questions for an image-editor skill:**
- "What functionality should the image-editor skill support? Editing, rotating, anything else?"
- "Can you give some examples of how this skill would be used?"
- "I can imagine users asking for things like 'Remove the red-eye from this image' or 'Rotate this image'. Are there other ways you imagine this skill being used?"
- "What would a user say that should trigger this skill?"

**Avoid overwhelming users:** Don't ask too many questions in a single message. Start with the most important questions and follow up as needed.

**Conclude this step when:** There is a clear sense of the functionality the skill should support.

### Step 2: Planning the Reusable Skill Contents

To turn concrete examples into an effective skill, analyze each example by:

1. Considering how to execute on the example from scratch
2. Identifying what scripts, references, and examples would be helpful when executing these workflows repeatedly

**Example: pdf-editor skill**
- Query: "Help me rotate this PDF"
- Analysis:
  1. Rotating a PDF requires re-writing the same code each time
  2. A `scripts/rotate_pdf.py` script would be helpful to store in the skill

**Example: frontend-webapp-builder skill**
- Queries: "Build me a todo app" or "Build me a dashboard to track my steps"
- Analysis:
  1. Writing a frontend webapp requires the same boilerplate HTML/React each time
  2. An `examples/hello-world/` template containing the boilerplate HTML/React project files would be helpful

**Example: big-query skill**
- Query: "How many users have logged in today?"
- Analysis:
  1. Querying BigQuery requires re-discovering the table schemas and relationships each time
  2. A `references/schema.md` file documenting the table schemas would be helpful

**Example: hooks skill (plugin context)**
- Queries: "Create a pre-commit hook" or "Validate my code before committing"
- Analysis:
  1. Developers repeatedly need to validate hooks.json and test hook scripts
  2. `scripts/validate-hook-schema.sh` and `scripts/test-hook.sh` utilities would be helpful
  3. `references/patterns.md` for detailed hook patterns to avoid bloating SKILL.md

**Result:** Create a list of reusable resources to include: scripts, references, and examples.

### Step 3: Create Skill Structure

**For standalone skills (using Anthropic's skill-creator):**

Run the initialization script:

```bash
~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>
```

This creates:
- Skill directory with SKILL.md template
- Example resource directories: `scripts/`, `references/`, `assets/`
- Proper frontmatter structure

**For plugin skills (Claude Code plugins):**

Create the structure manually in the plugin's `skills/` directory:

```bash
cd <plugin-path>/skills
mkdir -p <skill-name>/{references,examples,scripts}
touch <skill-name>/SKILL.md
```

**Note:** Plugin skills use `examples/` instead of `assets/` and are created directly without initialization scripts.

### Step 4: Edit the Skill

When editing the skill, remember that it's being created for another instance of Claude to use. Include information that would be beneficial and non-obvious to Claude.

#### Start with Reusable Skill Contents

Begin implementation with the reusable resources identified in Step 2:
- Create `scripts/` for utilities
- Create `references/` for detailed documentation
- Create `examples/` for working code samples

**Important:** This step may require user input. For example:
- `brand-guidelines` skill may need user to provide brand assets
- `database-schema` skill may need user to provide schema documentation
- `api-integration` skill may need API credentials or documentation

**Testing scripts:** All added scripts must be tested by actually running them to ensure:
- No bugs in implementation
- Output matches expectations
- Scripts work in target environment

For many similar scripts, test a representative sample to balance confidence and time to completion.

**Clean up examples:** Delete any example files and directories not needed for the skill. Initialization scripts create example files to demonstrate structure, but most skills won't need all of them.

#### Update SKILL.md

##### Frontmatter

Write the YAML frontmatter with `name` and `description`:

**`name`:** The skill identifier (lowercase, hyphens for spaces)

**`description`:** This is the PRIMARY TRIGGERING MECHANISM for your skill. Must include:
1. What the Skill does
2. Specific triggers/contexts for when to use it
3. Use third-person format: "This skill should be used when..."

**Include ALL "when to use" information in description** - Not in the body. The body is only loaded after triggering, so "When to Use This Skill" sections in the body are NOT helpful to Claude.

**Good description examples:**

```yaml
# Hook development skill
description: This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", "validate tool use", "implement prompt-based hooks", or mentions hook events (PreToolUse, PostToolUse, Stop). Provides comprehensive hooks API guidance.
```

```yaml
# DOCX skill
description: Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying or editing content, (3) Working with tracked changes, (4) Adding comments, or any other document tasks.
```

```yaml
# Bundle maker skill
description: This skill should be used when the user asks to "create a bundle", "make a plugin", "build a Claude plugin", "create a skill bundle", "package skills", or wants to create comprehensive Claude Code plugins with skills, commands, agents, hooks, or MCP servers.
```

**Bad description examples:**

```yaml
description: Provides guidance for working with hooks.
# Why bad: Vague, no specific trigger phrases, not third person
```

```yaml
description: Load when user needs hook help.
# Why bad: Not third person, vague trigger
```

```yaml
description: Use this skill when working with bundles.
# Why bad: Wrong person (second person instead of third), no specific triggers
```

**Optional: `version`**

For plugin skills, include a version number for tracking:

```yaml
version: 1.0.0
```

Use semantic versioning: MAJOR.MINOR.PATCH

##### Body

Write instructions for using the skill and its bundled resources using **imperative/infinitive form** (verb-first instructions).

**What to include in SKILL.md body:**
1. What is the purpose of the skill? (2-3 sentences)
2. Core workflows and procedures
3. Essential quick reference information
4. Pointers to references/examples/scripts
5. Most common use cases

**Target word count: 1,500-2,000 words (maximum 5,000 words)**

**When approaching the limit:** Split content into separate reference files. When splitting, it's very important to reference them from SKILL.md and describe clearly when to read them.

**Progressive disclosure pattern:**

```markdown
# SKILL.md (core essentials - 1,800 words)

## Quick Start

[Basic usage examples]

## Core Workflows

[Essential procedures]

## Advanced Features

For detailed patterns and techniques, consult:
- **`references/patterns.md`** - Detailed implementation patterns
- **`references/advanced.md`** - Advanced techniques and edge cases
- **`references/api-reference.md`** - Complete API documentation

## Additional Resources

### Example Files

Working examples in `examples/`:
- **`examples/basic-usage.sh`** - Basic usage example
- **`examples/advanced-config.json`** - Advanced configuration

### Utility Scripts

Helper scripts in `scripts/`:
- **`scripts/validate.sh`** - Validation utility
```

This approach keeps SKILL.md lean while making detailed information discoverable.

### Step 5: Validate and Test

**For standalone skills (using package_skill.py):**

```bash
~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/skill-creator/scripts/package_skill.py <path/to/skill-folder>
```

The packaging script automatically validates:
- YAML frontmatter format and required fields
- Skill naming conventions and directory structure
- Description completeness and quality
- File organization and resource references

If validation fails, fix errors and run again.

**For plugin skills:**

Manual validation checklist:

**Structure:**
- [ ] Skill directory in `plugin-name/skills/skill-name/`
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] Frontmatter has `name` and `description` fields
- [ ] Markdown body is present and substantial
- [ ] Referenced files actually exist

**Description Quality:**
- [ ] Uses third person ("This skill should be used when...")
- [ ] Includes specific trigger phrases users would say
- [ ] Lists concrete scenarios ("create X", "configure Y")
- [ ] Not vague or generic

**Content Quality:**
- [ ] SKILL.md body uses imperative/infinitive form (not second person)
- [ ] Body is focused and lean (1,500-2,000 words ideal, <5k max)
- [ ] Detailed content moved to references/
- [ ] Examples are complete and working
- [ ] Scripts are executable and documented

**Progressive Disclosure:**
- [ ] Core concepts in SKILL.md
- [ ] Detailed docs in references/
- [ ] Working code in examples/
- [ ] Utilities in scripts/
- [ ] SKILL.md references these resources

**Testing:**
- [ ] Skill triggers on expected user queries
- [ ] Content is helpful for intended tasks
- [ ] No duplicated information across files
- [ ] References load when needed

### Step 6: Iterate

After testing the skill, users may request improvements. Often this happens right after using the skill, with fresh context of how the skill performed.

**Iteration workflow:**

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Identify how SKILL.md or bundled resources should be updated
4. Implement changes and test again

**Common improvements:**
- Strengthen trigger phrases in description
- Move long sections from SKILL.md to references/
- Add missing examples or scripts
- Clarify ambiguous instructions
- Add edge case handling
- Update outdated information

## Progressive Disclosure Patterns

Keep SKILL.md body to the essentials and under 5,000 words (ideally 1,500-2,000) to minimize context bloat. Split content into separate files when approaching this limit.

**Key principle:** When a skill supports multiple variations, frameworks, or options, keep only the core workflow and selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

### Pattern 1: High-level guide with references

```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- **Form filling**: See `references/forms.md` for complete guide
- **API reference**: See `references/api-reference.md` for all methods
- **Examples**: See `examples/` for common patterns
```

Claude loads forms.md or api-reference.md only when needed.

### Pattern 2: Domain-specific organization

For skills with multiple domains, organize content by domain to avoid loading irrelevant context:

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, Claude only reads sales.md.

Similarly, for skills supporting multiple frameworks:

```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Claude only reads aws.md.

### Pattern 3: Conditional details

Show basic content, link to advanced content:

```markdown
# DOCX Processing

## Creating documents

Use docx-js for new documents. See `references/docx-js.md`.

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See `references/redlining.md`
**For OOXML details**: See `references/ooxml.md`
```

Claude reads redlining.md or ooxml.md only when the user needs those features.

### Important Guidelines

**Avoid deeply nested references:**
- Keep references one level deep from SKILL.md
- All reference files should link directly from SKILL.md
- Don't create references that reference other references

**Structure longer reference files:**
- For files >100 lines, include a table of contents at the top
- This lets Claude see the full scope when previewing
- Makes it easier to find specific information

## Writing Style Requirements

### Imperative/Infinitive Form

Write using verb-first instructions, not second person.

**Correct (imperative):**
```
To create a hook, define the event type.
Configure the MCP server with authentication.
Validate settings before use.
Parse the frontmatter using sed.
Extract fields with grep.
```

**Incorrect (second person):**
```
You should create a hook by defining the event type.
You need to configure the MCP server.
You must validate settings before use.
You can parse the frontmatter...
Claude should extract fields...
The user might validate values...
```

### Third-Person in Description

The frontmatter description must use third person:

**Correct:**
```yaml
description: This skill should be used when the user asks to "create X", "configure Y"...
```

**Incorrect:**
```yaml
description: Use this skill when you want to create X...
description: Load this skill when user asks...
```

### Objective, Instructional Language

Focus on what to do, not who should do it:

**Correct:**
```
Parse the frontmatter using sed.
Extract fields with grep.
Validate values before use.
```

**Incorrect:**
```
You can parse the frontmatter...
Claude should extract fields...
The user might validate values...
```

## Validation Checklist

Before finalizing a skill, verify:

**Structure:**
- [ ] SKILL.md file exists with valid YAML frontmatter
- [ ] Frontmatter has `name` and `description` fields
- [ ] Markdown body is present and substantial
- [ ] Referenced files actually exist
- [ ] Directory structure is clean (no unused examples)

**Description Quality:**
- [ ] Uses third person ("This skill should be used when...")
- [ ] Includes specific trigger phrases users would say
- [ ] Lists concrete scenarios ("create X", "configure Y")
- [ ] Not vague or generic
- [ ] Comprehensive (covers all usage scenarios)

**Content Quality:**
- [ ] SKILL.md body uses imperative/infinitive form
- [ ] Body is focused and lean (1,500-2,000 words ideal, <5k max)
- [ ] Detailed content moved to references/
- [ ] Examples are complete and working
- [ ] Scripts are executable and documented
- [ ] No second-person language anywhere

**Progressive Disclosure:**
- [ ] Core concepts in SKILL.md
- [ ] Detailed docs in references/
- [ ] Working code in examples/
- [ ] Utilities in scripts/
- [ ] SKILL.md references these resources clearly
- [ ] No deeply nested references

**Testing:**
- [ ] Skill triggers on expected user queries
- [ ] Content is helpful for intended tasks
- [ ] No duplicated information across files
- [ ] References load when needed
- [ ] Scripts execute correctly

## Common Mistakes to Avoid

### Mistake 1: Weak Trigger Description

❌ **Bad:**
```yaml
description: Provides guidance for working with hooks.
```

**Why bad:** Vague, no specific trigger phrases, not third person

✅ **Good:**
```yaml
description: This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", "validate tool use", or mentions hook events. Provides comprehensive hooks API guidance.
```

**Why good:** Third person, specific phrases, concrete scenarios

### Mistake 2: Too Much in SKILL.md

❌ **Bad:**
```
skill-name/
└── SKILL.md  (8,000 words - everything in one file)
```

**Why bad:** Bloats context when skill loads, detailed content always loaded

✅ **Good:**
```
skill-name/
├── SKILL.md  (1,800 words - core essentials)
└── references/
    ├── patterns.md (2,500 words)
    └── advanced.md (3,700 words)
```

**Why good:** Progressive disclosure, detailed content loaded only when needed

### Mistake 3: Second Person Writing

❌ **Bad:**
```markdown
You should start by reading the configuration file.
You need to validate the input.
You can use the grep tool to search.
```

**Why bad:** Second person, not imperative form

✅ **Good:**
```markdown
Start by reading the configuration file.
Validate the input before processing.
Use the grep tool to search for patterns.
```

**Why good:** Imperative form, direct instructions

### Mistake 4: Missing Resource References

❌ **Bad:**
```markdown
# SKILL.md

[Core content]

[No mention of references/ or examples/]
```

**Why bad:** Claude doesn't know references exist

✅ **Good:**
```markdown
# SKILL.md

[Core content]

## Additional Resources

### Reference Files
- **`references/patterns.md`** - Detailed patterns
- **`references/advanced.md`** - Advanced techniques

### Examples
- **`examples/script.sh`** - Working example
```

**Why good:** Claude knows where to find additional information

### Mistake 5: Vague or Generic Triggers

❌ **Bad:**
```yaml
description: Helper for development tasks.
description: Assists with coding.
description: Provides support for projects.
```

**Why bad:** Too vague, Claude won't know when to trigger

✅ **Good:**
```yaml
description: This skill should be used when the user asks to "refactor React components", "extract custom hooks", "implement TypeScript strict mode", or needs React performance optimization guidance.
```

**Why good:** Specific, actionable trigger phrases

## Quick Reference

### Skill Structure Options

**Minimal Skill:**
```
skill-name/
└── SKILL.md
```
Good for: Simple knowledge, no complex resources needed

**Standard Skill (Recommended):**
```
skill-name/
├── SKILL.md
├── references/
│   └── detailed-guide.md
└── examples/
    └── working-example.sh
```
Good for: Most plugin skills with detailed documentation

**Complete Skill:**
```
skill-name/
├── SKILL.md
├── references/
│   ├── patterns.md
│   └── advanced.md
├── examples/
│   ├── example1.sh
│   └── example2.json
└── scripts/
    └── validate.sh
```
Good for: Complex domains with validation utilities

### Best Practices Summary

✅ **DO:**
- Use third-person in description ("This skill should be used when...")
- Include specific trigger phrases ("create X", "configure Y")
- Keep SKILL.md lean (1,500-2,000 words)
- Use progressive disclosure (move details to references/)
- Write in imperative/infinitive form
- Reference supporting files clearly
- Provide working examples
- Create utility scripts for common operations
- Test scripts before including
- Validate before finalizing

❌ **DON'T:**
- Use second person anywhere ("You should...")
- Have vague trigger conditions
- Put everything in SKILL.md (>5k words without references/)
- Leave resources unreferenced
- Include broken or incomplete examples
- Skip validation and testing
- Duplicate information across files
- Create deeply nested references
- Use generic, non-specific trigger descriptions

## Conclusion

Creating effective skills requires:

1. **Clear understanding** of usage patterns and concrete examples
2. **Careful planning** of reusable resources (scripts, references, examples)
3. **Proper structure** with lean SKILL.md and progressive disclosure
4. **Strong trigger descriptions** with specific, actionable phrases
5. **Imperative writing style** throughout the skill body
6. **Thorough validation and testing** before deployment
7. **Continuous iteration** based on real-world usage

Follow this guide to create skills that trigger appropriately, load efficiently, and provide targeted guidance for Claude's specialized tasks.
