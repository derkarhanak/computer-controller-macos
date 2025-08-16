# Contributing to Computer Controller

Thank you for your interest in contributing to Computer Controller! 🎉

## Getting Started

1. **Fork the repository**
2. **Clone your fork**: `git clone https://github.com/yourusername/computer-controller-macos.git`
3. **Create a branch**: `git checkout -b feature/your-feature-name`
4. **Make your changes**
5. **Test thoroughly**
6. **Submit a pull request**

## Development Setup

### Prerequisites
- macOS 12.0+ (Monterey or later)
- Xcode 14.0+
- Swift 5.7+
- Swift Package Manager

### Building the App
```bash
# Clone the repository
git clone https://github.com/yourusername/computer-controller-macos.git
cd computer-controller-macos

# Build the app
swift build -c release

# Run the app
swift run
```

### Project Structure
```
Sources/
├── App.swift              # Main app entry point
├── ContentView.swift      # Root view with tabs
├── MainOperationView.swift # AI interaction interface
├── FileOperationView.swift # Settings and tools
├── LLMService.swift       # AI provider communication
├── PythonExecutor.swift   # Code execution engine
└── FileManager+Extensions.swift # File utilities
```

## Contributing Guidelines

### Code Style
- Follow Swift naming conventions
- Use SwiftUI best practices
- Add comments for complex logic
- Keep functions focused and small

### Features We'd Love
- 🤖 **More LLM Providers** (Gemini, Cohere, etc.)
- 🔧 **Additional Automation Tasks** (system management, app control)
- 🎨 **UI Improvements** (animations, themes)
- 🛡️ **Enhanced Security** (better sandboxing, permission management)
- 📊 **Analytics & Logging** (optional usage statistics)
- 🌍 **Internationalization** (multiple languages)
- 🔌 **Plugin System** (extensible functionality)

### Bug Reports
Please include:
- macOS version
- App version
- Steps to reproduce
- Expected vs actual behavior
- Console logs (if available)

### Pull Request Process
1. Update documentation if needed
2. Add tests for new features
3. Ensure all tests pass
4. Update README.md if necessary
5. Follow the commit message format: `feat: add new feature` or `fix: resolve issue`

## Code of Conduct

- Be respectful and inclusive
- Help newcomers learn
- Focus on constructive feedback
- Celebrate contributions of all sizes

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for questions or ideas
- Check existing issues before creating new ones

Happy coding! 🚀
