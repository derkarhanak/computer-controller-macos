# Computer Controller - macOS AI Assistant

A modern, open-source macOS application that allows you to control your computer using natural language. The app supports multiple AI providers (DeepSeek, OpenAI, Claude, Ollama) to generate Python code for file operations and other computer tasks, with built-in safety confirmations.

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)](https://www.apple.com/macos/)

## 🌟 Open Source

This project is open source and welcomes contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to get involved.

## Features

- **AI-Powered Control**: Use natural language to describe what you want to do
- **Safe Code Execution**: All generated code is reviewed and requires confirmation before execution
- **File Operations**: Move, copy, rename, delete files and create directories
- **Modern UI**: Clean, native macOS interface with SwiftUI
- **Real-time Status**: See connection status and operation results
- **Quick Actions**: Easy access to common directories and file operations

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building)
- DeepSeek API key
- Python 3.x (included with macOS)

## Setup Instructions

### 1. Get Your DeepSeek API Key

1. Visit [DeepSeek's website](https://platform.deepseek.com/)
2. Create an account and navigate to the API section
3. Generate a new API key
4. Copy the key for use in the app

### 2. Build and Run the App

1. Clone or download this repository
2. Open `ComputerController.xcodeproj` in Xcode
3. Build the project (⌘+B)
4. Run the app (⌘+R)

### 3. Configure the API Key

1. Launch the app
2. Go to the "Settings & Tools" tab
3. Click "Set Key" and enter your DeepSeek API key
4. The app will show "Connected" status when configured correctly

## Usage Examples

### File Operations

**Move files:**
```
"Move all PDF files from Downloads to Documents folder"
```

**Rename files:**
```
"Rename all image files in Pictures folder to include today's date"
```

**Create directories:**
```
"Create a backup folder in Documents and copy all important files there"
```

**Clean up:**
```
"Delete all empty folders in Downloads directory"
```

### How It Works

1. **Input**: Describe what you want to do in natural language
2. **AI Generation**: DeepSeek generates appropriate Python code
3. **Review**: Review the generated code and operation description
4. **Confirm**: Confirm the operation before execution
5. **Execute**: The app runs the Python code safely
6. **Results**: See the results and any output

## Safety Features

- **Code Validation**: Checks for potentially dangerous operations
- **User Confirmation**: Always requires confirmation before execution
- **Sandboxed Execution**: Runs Python code in a controlled environment
- **Error Handling**: Comprehensive error handling and user feedback
- **File System Limits**: Restricted to safe file operations only

## Architecture

The app is built with a clean, modular architecture:

- **ContentView**: Main tab-based interface
- **MainOperationView**: AI-powered computer control interface
- **FileOperationView**: Settings and quick file operations
- **LLMService**: DeepSeek API integration
- **PythonExecutor**: Safe Python code execution
- **FileManager Extensions**: Additional file operation utilities

## File Structure

```
ComputerController/
├── ComputerControllerApp.swift      # App entry point
├── ContentView.swift               # Main tab interface
├── MainOperationView.swift         # AI control interface
├── FileOperationView.swift         # Settings and tools
├── LLMService.swift               # DeepSeek API service
├── PythonExecutor.swift           # Python execution engine
├── FileManager+Extensions.swift   # File operation utilities
├── Assets.xcassets/               # App assets
└── Info.plist                     # App configuration
```

## Troubleshooting

### Common Issues

**"Not Connected" Status:**
- Ensure you've entered your DeepSeek API key correctly
- Check your internet connection
- Verify your API key is valid and has sufficient credits

**Code Execution Errors:**
- Make sure Python 3.x is installed (usually included with macOS)
- Check that the requested files/directories exist
- Ensure you have proper permissions for the target locations

**Build Errors:**
- Make sure you're using Xcode 15.0 or later
- Verify macOS 14.0+ target
- Check that all Swift files are included in the project

### Permissions

The app may request access to:
- **Full Disk Access**: Required for file operations across the system
- **Network Access**: Required for DeepSeek API communication

## Development

### Adding New Features

The app is designed to be easily extensible:

1. **New LLM Models**: Modify `LLMService.swift` to support additional providers
2. **Additional Operations**: Extend `PythonExecutor.swift` for new operation types
3. **UI Enhancements**: Add new views and integrate them into the tab system

### Code Style

- Follow SwiftUI best practices
- Use proper error handling and user feedback
- Maintain the safety-first approach for all operations
- Keep the UI clean and intuitive

## Contributing

We welcome contributions! Here are some ways you can help:

### 🤖 **Add More AI Providers**
- Gemini, Cohere, Mistral
- Local models (MLX, llama.cpp)
- Custom API endpoints

### 🔧 **New Features**
- System management tasks
- Application control
- Scheduled automation
- Plugin system

### 🎨 **UI/UX Improvements**
- Animations and transitions
- Additional themes
- Better responsive design
- Accessibility features

### 📖 **Documentation**
- Video tutorials
- Use case examples
- API documentation
- Internationalization

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Community

- **Issues**: Report bugs or request features
- **Discussions**: Ask questions or share ideas
- **Pull Requests**: Contribute code improvements
- **Wiki**: Community-maintained documentation

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the code comments for implementation details
3. Ensure all requirements are met
4. Test with simple operations first

## Future Enhancements

Potential areas for expansion:
- **System Settings**: Control system preferences and settings
- **Application Management**: Launch, quit, and manage applications
- **Network Operations**: Network configuration and monitoring
- **Process Management**: View and control running processes
- **Automation**: Schedule and automate recurring tasks
- **Plugin System**: Support for custom operation plugins

---

**Note**: This app is designed for personal use and file management. Always review generated code before execution and ensure you have proper backups of important data.
