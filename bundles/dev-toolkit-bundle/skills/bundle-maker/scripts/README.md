# Bundle Maker Utility Scripts

This directory contains utility scripts for bundle creation, management, and validation.

## Scripts

### `create-bundle.sh`

Creates a new bundle directory structure with plugin.json template.

**Usage:**
```bash
./create-bundle.sh <bundle-name> [--with-all]
```

**Options:**
- `--with-all` - Create all component directories (skills, commands, agents, hooks, mcp)
- Without `--with-all` - Create only skills directory

**Examples:**
```bash
# Create minimal bundle (skills only)
./create-bundle.sh react-frontend-bundle

# Create complete bundle (all components)
./create-bundle.sh full-stack-bundle --with-all
```

**Output:**
- Creates bundle directory in `<marketplace>/bundles/<bundle-name>/`
- Creates `.claude-plugin/plugin.json` with TODO placeholders
- Creates component directories as specified

**Next steps after running:**
1. Edit `.claude-plugin/plugin.json` to fill in TODOs
2. Add skills to `skills/` directory
3. Register bundle in `marketplace.json`

---

### `add-skill-to-bundle.sh`

Adds a skill structure to an existing bundle.

**Usage:**
```bash
./add-skill-to-bundle.sh <bundle-path> <skill-name>
```

**Parameters:**
- `<bundle-path>` - Path to the bundle directory
- `<skill-name>` - Kebab-case name for the skill

**Examples:**
```bash
# Add skill to existing bundle
./add-skill-to-bundle.sh ./bundles/react-frontend-bundle react-patterns

# Add skill with relative path
./add-skill-to-bundle.sh ../react-frontend-bundle ui-ux-design
```

**Output:**
- Creates skill directory in `<bundle-path>/skills/<skill-name>/`
- Creates `SKILL.md` with TODO placeholders
- Creates `references/`, `examples/`, `scripts/` subdirectories

**Next steps after running:**
1. Edit `SKILL.md` to add description with trigger phrases
2. Add core workflows and procedures
3. Add reference files, examples, and scripts as needed
4. Update bundle's `plugin.json` to include the new skill path

---

### `validate-bundle.sh`

Validates bundle structure and plugin.json format.

**Usage:**
```bash
./validate-bundle.sh <bundle-path>
```

**Parameters:**
- `<bundle-path>` - Path to the bundle directory to validate

**Examples:**
```bash
# Validate a bundle
./validate-bundle.sh ./bundles/react-frontend-bundle

# Validate from marketplace root
./validate-bundle.sh bundles/react-frontend-bundle
```

**Validation Checks:**

**Errors (will fail validation):**
- Missing `.claude-plugin/` directory
- Missing `plugin.json` file
- Invalid JSON format
- Missing required fields: name, version, description, author
- Missing author.name or author.email
- Skill directories listed but not found
- Missing SKILL.md in skill directories

**Warnings (will pass but show issues):**
- TODO placeholders in author fields
- TODO placeholders in description
- Missing YAML frontmatter in SKILL.md
- No skills array or components object

**Exit codes:**
- `0` - Validation passed (may have warnings)
- `1` - Validation failed (has errors)

**Example output:**
```
Validating bundle: ./bundles/react-frontend-bundle

✓ .claude-plugin/ directory exists
✓ plugin.json exists
✓ plugin.json is valid JSON
✓ Required field exists: name
✓ Required field exists: version
✓ Required field exists: description
✓ Required field exists: author
✓ author.name is set: John Doe
✓ author.email is set: john.doe@example.com
✓ Skills array exists (2 skills listed)
✓ Skill valid: ./skills/react-patterns
✓ Skill valid: ./skills/ui-ux-design

════════════════════════════════════════════
Validation Results
════════════════════════════════════════════
Errors: 0
Warnings: 0

✓ Bundle is valid!
```

---

## Workflow Examples

### Creating a New Bundle from Scratch

```bash
# Step 1: Create bundle structure
./create-bundle.sh my-new-bundle

# Step 2: Edit plugin.json (remove TODOs)
# Edit bundles/my-new-bundle/.claude-plugin/plugin.json

# Step 3: Add first skill
./add-skill-to-bundle.sh bundles/my-new-bundle my-first-skill

# Step 4: Edit skill (remove TODOs, add content)
# Edit bundles/my-new-bundle/skills/my-first-skill/SKILL.md

# Step 5: Validate before registering
./validate-bundle.sh bundles/my-new-bundle

# Step 6: Register in marketplace.json
# Add entry to .claude-plugin/marketplace.json

# Step 7: Install and test
# /plugin install my-new-bundle@my-marketplace
```

### Adding Skills to Existing Bundle

```bash
# Add new skill
./add-skill-to-bundle.sh bundles/existing-bundle new-skill

# Edit the skill
# Edit bundles/existing-bundle/skills/new-skill/SKILL.md

# Update plugin.json to include new skill
# Add "./skills/new-skill" to skills array

# Validate changes
./validate-bundle.sh bundles/existing-bundle

# Reinstall to pick up changes
# /plugin install existing-bundle@my-marketplace
```

### Validating All Bundles

```bash
# Validate all bundles in marketplace
for bundle in bundles/*/; do
  echo "Validating $bundle..."
  ./validate-bundle.sh "$bundle"
  echo ""
done
```

---

## Requirements

These scripts require:
- `bash` (version 4.0+)
- `jq` (for JSON validation) - Install with: `sudo apt-get install jq` or `brew install jq`
- `grep`, `sed` (standard Unix utilities)

## Troubleshooting

**"Could not find marketplace.json"**
- Run scripts from marketplace root or bundles/ directory
- Or specify absolute paths to bundles

**"jq: command not found"**
- Install jq: `sudo apt-get install jq` (Linux) or `brew install jq` (macOS)

**"Permission denied"**
- Make scripts executable: `chmod +x *.sh`

**Validation fails with skill path errors**
- Check that skill paths in plugin.json match actual directory structure
- Paths should be relative to bundle root: `"./skills/skill-name"` or `"skills/skill-name"`
