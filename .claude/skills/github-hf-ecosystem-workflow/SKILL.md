```markdown
# github-hf-ecosystem-workflow Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development conventions and workflows used in the `github-hf-ecosystem-workflow` TypeScript repository. It covers file organization, code style, commit message patterns, and testing practices to ensure consistency and maintainability across the codebase.

## Coding Conventions

### File Naming
- Use **snake_case** for all file names.
  - Example: `my_module.ts`, `user_service.test.ts`

### Import Style
- Use **relative imports** for referencing modules within the project.
  - Example:
    ```typescript
    import { myFunction } from './utils';
    ```

### Export Style
- Use **named exports** for all exported functions, classes, or constants.
  - Example:
    ```typescript
    // In utils.ts
    export function myFunction() { ... }

    // In another file
    import { myFunction } from './utils';
    ```

### Commit Messages
- Follow the **conventional commit** format.
- Use the `fix` prefix for bug fixes.
- Keep commit messages concise (average ~78 characters).
  - Example:
    ```
    fix: correct user authentication flow in login handler
    ```

## Workflows

_No automated workflows detected in this repository._

## Testing Patterns

- **Test files** use the pattern `*.test.*` (e.g., `user_service.test.ts`).
- **Testing framework** is unknown; follow the test file pattern for consistency.
- Example test file:
  ```typescript
  // user_service.test.ts
  import { getUser } from './user_service';

  describe('getUser', () => {
    it('returns user data for valid id', () => {
      // test implementation
    });
  });
  ```

## Commands

| Command | Purpose |
|---------|---------|
| /fix    | Start a bug fix workflow (commit with `fix:` prefix) |
| /test   | Run all test files matching `*.test.*` |
```