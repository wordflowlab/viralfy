# Contributing to Viralfy

Thank you for considering contributing to Viralfy! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Environment details** (OS, Node version, etc.)
- **Screenshots** (if applicable)

### 💡 Suggesting Features

Feature suggestions are welcome! Please include:

- **Clear use case**
- **Why this feature would be useful**
- **Possible implementation approach**

### 🔧 Code Contributions

#### Priority Areas

Current priorities (see `docs/PROJECT_SUMMARY.md` for details):

1. **P0**: Testing and bug fixes for existing features
2. **P1**: Implement `validate` and `research` commands
3. **P2**: Implement `distribute` command
4. **P3**: Implement `analyze` and `style` commands

## Development Setup

### Prerequisites

- Node.js >= 18.0.0
- npm or yarn
- Git

### Setup Steps

```bash
# Clone the repository
git clone https://github.com/your-org/viralfy.git
cd viralfy

# Install dependencies
npm install

# Build the project
npm run build

# Link for local development
npm link

# Test in development mode
npm run dev init
```

### Project Structure

```
viralfy/
├── src/              # TypeScript source code
│   ├── cli.ts        # Main CLI program
│   ├── types/        # Type definitions
│   ├── utils/        # Utility functions
│   └── commands/     # Command implementations
├── scripts/          # Bash/PowerShell scripts
├── templates/        # AI command templates
├── docs/             # Documentation
└── tests/            # Test files (to be added)
```

## Coding Standards

### TypeScript Style

- **Indentation**: 2 spaces
- **Quotes**: Single quotes for strings
- **Semicolons**: Yes
- **Naming**:
  - Files: `kebab-case.ts`
  - Classes: `PascalCase`
  - Functions: `camelCase`
  - Constants: `UPPER_SNAKE_CASE`

### Example

```typescript
// Good
export class FileManager {
  private static readonly CONFIG_DIR = '.viralfy';

  async readConfig(): Promise<ProjectConfig> {
    // Implementation
  }
}

// Bad
export class file_manager {
  private static config_dir = '.viralfy';

  async ReadConfig(): Promise<ProjectConfig> {
    // Implementation
  }
}
```

### Documentation

- Add JSDoc comments for all public functions and classes
- Include parameter descriptions and return types
- Provide usage examples for complex functions

```typescript
/**
 * Read project configuration from .viralfy/config.json
 *
 * @returns Project configuration object
 * @throws {ProjectNotInitializedError} If project is not initialized
 * @throws {InvalidConfigError} If config file is malformed
 *
 * @example
 * ```typescript
 * const config = await FileManager.readConfig();
 * console.log(config.project_name);
 * ```
 */
static async readConfig(): Promise<ProjectConfig> {
  // Implementation
}
```

### Error Handling

- Use custom error classes from `src/types/index.ts`
- Provide helpful error messages
- Include context in error details

```typescript
// Good
throw new FileNotFoundError(configPath);

// Bad
throw new Error('File not found');
```

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build process or auxiliary tool changes

### Examples

```bash
feat(cli): add validate command

Implement Twitter and YouTube analysis for idea validation.
Includes scoring system and top-5 recommendations.

Closes #123
```

```bash
fix(write): resolve progress tracking bug

Fix issue where progress was not saved correctly
when interrupting newsletter creation.

Fixes #456
```

```bash
docs(readme): update installation instructions

Add npm link step and troubleshooting section.
```

## Pull Request Process

### Before Submitting

1. **Update your branch**
   ```bash
   git checkout main
   git pull origin main
   git checkout your-feature-branch
   git rebase main
   ```

2. **Run tests** (when available)
   ```bash
   npm test
   ```

3. **Build successfully**
   ```bash
   npm run build
   ```

4. **Lint and format**
   ```bash
   npm run lint
   npm run format
   ```

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Related Issues
Closes #issue-number

## Testing
Describe how you tested these changes

## Screenshots (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated (if applicable)
- [ ] Build passes
```

### Review Process

1. **Automated checks** must pass
2. **At least one maintainer** must approve
3. **No unresolved conversations**
4. **Up-to-date with main branch**

### After Approval

- Maintainers will merge your PR
- Branch will be deleted automatically
- Release notes will be updated

## Development Workflow

### Feature Development

```bash
# Create feature branch
git checkout -b feat/validate-command

# Make changes
# ... edit files ...

# Commit changes
git add .
git commit -m "feat(validate): add Twitter analysis"

# Push to GitHub
git push origin feat/validate-command

# Create Pull Request on GitHub
```

### Bug Fixes

```bash
# Create bugfix branch
git checkout -b fix/progress-tracking

# Fix the bug
# ... edit files ...

# Commit with issue reference
git commit -m "fix(write): resolve progress tracking bug

Fixes #456"

# Push and create PR
git push origin fix/progress-tracking
```

## Testing Guidelines

### Unit Tests (to be implemented)

```typescript
// Example test structure
describe('FileManager', () => {
  describe('readConfig', () => {
    it('should read config successfully', async () => {
      // Test implementation
    });

    it('should throw error if config not found', async () => {
      // Test implementation
    });
  });
});
```

### Integration Tests

Test complete workflows:
- Project initialization
- Newsletter creation with resume
- Multi-platform distribution

## Documentation Updates

When adding features:

1. **Update relevant .md files**
2. **Add command templates** in `templates/commands/`
3. **Update CHANGELOG.md**
4. **Add examples** in `docs/` or `README.md`

## Getting Help

- **Questions**: Open a Discussion on GitHub
- **Bug Reports**: Open an Issue
- **Real-time Chat**: Join our Discord (if available)
- **Email**: contact@viralfy.com (if available)

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in documentation (for significant contributions)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Viralfy!** 🚀

Every contribution, no matter how small, helps make Viralfy better for everyone.
