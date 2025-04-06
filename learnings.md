# Game Development Learnings

## Testing & Debugging

### Resource Loading

- Keep track of resource loading errors and their causes
- Document common patterns in resource loading failures
- Track solutions implemented for each type of error

### Scene Management

- Document scene transition issues
- Track scene dependency relationships
- Note common pitfalls in scene setup

### Best Practices

- Document successful patterns
- Note anti-patterns to avoid
- Track performance implications

## Current Session

### Startup Testing (2024-04-06)

#### Resource Loading Issues

1. Missing Scene File

   - Error: Cannot open file 'res://scenes/enemy_fish.tscn'
   - Impact: Prevents main scene from loading properly
   - Learning: Always verify scene files exist in the correct paths before referencing

2. Resource Dependencies
   - Multiple ext_resource reference errors in main.tscn
   - Cascading errors when dependent resources are missing
   - Learning: Need to maintain proper scene hierarchy and verify all dependencies

#### Testing Approach

1. Headless Testing
   - Using `godot --headless --script` reveals initialization issues
   - Provides clear error messages for resource loading problems
   - Effective for catching startup issues before runtime

#### Best Practices Identified

1. Resource Organization

   - Keep scene files in consistent locations
   - Update all references when moving files
   - Maintain clear documentation of scene dependencies

2. Error Handling
   - Check for resource existence before loading
   - Implement graceful fallbacks for missing resources
   - Keep error messages informative for debugging

#### Resource Loading Analysis

1. Resource Loading Order

   - Godot attempts to load resources in a specific order
   - Main scene loads first, followed by its dependencies
   - Resource import cache (.godot/imported/) is checked for assets

2. Multiple Reference Points

   - Same resource (enemy_fish.tscn) is referenced from multiple locations
   - Scene is being looked for in both res://scenes/ and res://enemies/
   - Inconsistent path references can cause loading failures

3. Import System
   - Assets need to be properly imported before use
   - .godot/imported/ directory contains processed resources
   - Some resources require editor to process them first

#### Debugging Techniques

1. Verbose Mode

   - Using `--verbose` flag provides detailed loading information
   - Shows exact resource loading sequence
   - Helps identify which resources fail to load and why

2. Resource Dependencies
   - Main scene has multiple ext_resource references
   - Each resource can have its own dependencies
   - Failure to load one resource can affect others

### Bug Fixes and Solutions

1. Missing Node Reference

   - Issue: fish_ai.gd script referenced a non-existent HungerTimer node
   - Fix: Added HungerTimer node to enemy_fish.tscn
   - Learning: Always ensure scene nodes match script references

2. Scene Loading Sequence

   - Issue: Resource loading errors during startup
   - Fix: Added missing nodes and verified scene dependencies
   - Learning: Check both scene structure and script requirements

3. Best Practices

   - Always verify script node references in scene files
   - Test scene loading in isolation before integration
   - Keep scene structure in sync with script expectations

4. Resource UID Conflicts

   - Issue: Multiple scenes sharing the same UID causes loading conflicts
   - Fix: Updated small_fish.tscn with a unique UID
   - Learning: Always ensure scene UIDs are unique across the project

5. Resource Loading Best Practices

   - Check for UID uniqueness when copying scenes
   - Verify resource paths and references
   - Test scene loading in isolation
   - Document resource dependencies and relationships

6. Scene Reference Errors

   - Issue: Incorrect scene references in main.tscn
   - Fix: Updated Player and GameUI nodes to use correct scene files
   - Learning: Double-check instance references when copying nodes

7. Scene Loading Validation

   - Verify all scene references point to correct files
   - Check for duplicate scene references
   - Ensure proper scene hierarchy
   - Test scene loading in isolation before integration

8. Resource Reference Management

   - Issue: Duplicate and incorrect resource references in main scene
   - Fix: Cleaned up resource references and fixed incorrect instance assignments
   - Learning: Maintain clean resource references and avoid duplicates

9. Scene Loading Best Practices

   - Keep resource load_steps count in sync with actual resources
   - Avoid duplicate resource references
   - Use consistent resource IDs across scenes
   - Verify instance references match intended scene types

10. UI Scene References

    - Issue: Missing UIDs for UI scene references
    - Fix: Added unique UIDs for game_over.tscn and debug_panel.tscn
    - Learning: All PackedScene resources should have unique UIDs

11. Resource Loading Chain

    - Scene loading errors can cascade through dependencies
    - Missing UIDs can cause resource loading failures
    - Proper resource identification is crucial for scene loading
    - Always verify complete resource loading chain

12. Resource UID Management

    - Issue: Manually added UIDs causing loading errors
    - Fix: Let Godot handle UID generation for UI scenes
    - Learning: Only specify UIDs when necessary, let engine handle them otherwise

13. Scene Loading Workflow

    - Let Godot generate UIDs during scene save
    - Only reference existing UIDs from engine
    - Remove manual UID assignments when not needed
    - Use path-based references for simple scene loading

14. Instance Reference Cleanup

    - Issue: Duplicate and incorrect instance references in main scene
    - Fix: Removed duplicate FishSpawner and fixed GameUI instance
    - Learning: Check for duplicate instances and verify correct resource usage

15. Scene Loading Best Practices

    - Avoid duplicate instance references
    - Verify instance types match intended usage
    - Keep scene structure clean and organized
    - Document instance dependencies and relationships

16. Resource Import Requirements

    - Issue: Resources need to be imported by opening project in editor
    - Fix: Project must be opened in editor before running headless
    - Learning: Resource importing is a crucial step in project setup

17. Testing Best Practices
    - Open project in editor first to ensure resource imports
    - Use headless mode for automated testing
    - Check resource loading order and dependencies
    - Document resource import requirements
