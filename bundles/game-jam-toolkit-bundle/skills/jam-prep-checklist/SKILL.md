---
name: jam-prep-checklist
description: setup preparation readiness checklist pre-jam verification launch ready
---

# Jam Prep Checklist Skill

Interactive walkthrough to ensure your project is ready to start the game jam.

## What This Does

Guides you through complete project setup:

- **Script Integration** - Verifies all 20 starter scripts are in your project
- **Manager Initialization** - Checks GameManager, AudioManager, InputManager, UIManager setup and initialization order
- **Prefab Setup** - Confirms key prefabs (player, UI canvas, pooled objects) are created
- **Input Configuration** - Modern Input System setup and bindings ready
- **Scene Setup** - Proper scene hierarchy, GameManager placement, component connections
- **Team Readiness** - Git setup, team members have correct project structure
- **Performance Baseline** - Initial profiling data, target performance metrics

## Activation Triggers

This skill activates when you:
- Ask "am I ready to start the jam?"
- Request "pre-jam checklist" or "setup checklist"
- Run `/jam-status` before jam start
- Ask about "getting ready" or "final checks"

## Output Format

Interactive checklist with:
- ✓ Completed items
- ⚠ Items needing attention
- ❌ Critical blockers
- **Final Verdict** - "Ready to jam!" or list of things to fix

## When to Use

Run this the day before your jam starts (or morning-of) to catch any setup issues before crunch time.

## Team Sharing

Checklist can be shared with team to ensure everyone has identical project setup.
