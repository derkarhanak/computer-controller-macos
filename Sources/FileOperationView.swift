import SwiftUI

struct FileOperationView: View {
    @StateObject private var llmService = LLMService()
    @State private var showApiKeyInput = false
    @State private var tempApiKey = ""
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Settings & File Operations")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
            
            // LLM Provider Section
            VStack(alignment: .leading, spacing: 16) {
                Text("AI Provider Configuration")
                    .font(.headline)
                
                // Provider Selection
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Select AI Provider")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Current provider indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 6, height: 6)
                            Text("Using: \(llmService.selectedProvider.rawValue)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Responsive grid layout for provider buttons
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: geometry.size.width > 600 ? 4 : 2), spacing: 12) {
                        ForEach(LLMProvider.allCases, id: \.self) { provider in
                            ProviderButton(
                                provider: provider,
                                isSelected: llmService.selectedProvider == provider,
                                action: {
                                    llmService.selectedProvider = provider
                                }
                            )
                        }
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Key Status")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(llmService.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                            
                            Text(llmService.isConnected ? "Connected" : "Not Connected")
                                .font(.body)
                                .foregroundColor(llmService.isConnected ? .green : .red)
                        }
                    }
                    
                    Spacer()
                    
                    if llmService.selectedProvider.requiresApiKey {
                        Button(action: { showApiKeyInput = true }) {
                            Label(llmService.isConnected ? "Change Key" : "Set Key", systemImage: "key")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Text("No API key required")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if llmService.selectedProvider.requiresApiKey {
                    if llmService.isConnected {
                        Text("✓ Your \(llmService.selectedProvider.rawValue) API key is configured and working")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("⚠ Please set your \(llmService.selectedProvider.rawValue) API key to use the app")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✓ \(llmService.selectedProvider.rawValue) is ready to use (local AI)")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        // Ollama model selection
                        if llmService.selectedProvider == .ollama && !llmService.availableOllamaModels.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Model:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Ollama Model", selection: $llmService.selectedOllamaModel) {
                                    ForEach(llmService.availableOllamaModels, id: \.self) { model in
                                        Text(model).tag(model)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: 200)
                            }
                        }
                        
                        // Groq model selection
                        if llmService.selectedProvider == .groq && !llmService.availableGroqModels.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Select Model:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Groq Model", selection: $llmService.selectedGroqModel) {
                                    ForEach(llmService.availableGroqModels, id: \.self) { model in
                                        Text(model).tag(model)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: 200)
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
            
            // Appearance Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Appearance")
                    .font(.headline)
                
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "sun.max.fill")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .secondary : .orange)
                        
                        Text("Light")
                            .font(.subheadline)
                            .fontWeight(isDarkMode ? .regular : .semibold)
                            .foregroundColor(isDarkMode ? .secondary : .primary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $isDarkMode)
                        .toggleStyle(SwitchToggleStyle())
                        .scaleEffect(1.1)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text("Dark")
                            .font(.subheadline)
                            .fontWeight(isDarkMode ? .semibold : .regular)
                            .foregroundColor(isDarkMode ? .primary : .secondary)
                        
                        Image(systemName: "moon.fill")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .blue : .secondary)
                    }
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
            
            // Quick Actions Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick File Operations")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: geometry.size.width > 500 ? 4 : 2), spacing: 16) {
                    QuickActionButton(
                        title: "Open Downloads",
                        icon: "folder",
                        action: { openDirectory(.downloads) }
                    )
                    
                    QuickActionButton(
                        title: "Open Desktop",
                        icon: "desktopcomputer",
                        action: { openDirectory(.desktop) }
                    )
                    
                    QuickActionButton(
                        title: "Open Documents",
                        icon: "doc.text",
                        action: { openDirectory(.documents) }
                    )
                    
                    QuickActionButton(
                        title: "Open Pictures",
                        icon: "photo",
                        action: { openDirectory(.pictures) }
                    )
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
            
            // Example Commands Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Example Commands")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    ExampleCommand(
                        command: "Move all PDF files from Downloads to Documents",
                        description: "Organize your files automatically"
                    )
                    
                    ExampleCommand(
                        command: "Rename all image files in Pictures folder",
                        description: "Batch rename with date prefixes"
                    )
                    
                    ExampleCommand(
                        command: "Create a backup folder and copy important files",
                        description: "Set up automated backups"
                    )
                    
                    ExampleCommand(
                        command: "Clean up empty folders in Downloads",
                        description: "Remove unnecessary directories"
                    )
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, max(20, min(40, geometry.size.width * 0.05)))
            
                    Spacer()
                }
                .padding(.top, 20)
                .frame(minWidth: geometry.size.width)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showApiKeyInput) {
            ApiKeyInputView(llmService: llmService, isPresented: $showApiKeyInput)
        }
    }
    

    
    private func openDirectory(_ type: DirectoryType) {
        let url: URL
        switch type {
        case .downloads:
            url = FileManager.default.downloadsDirectory
        case .desktop:
            url = FileManager.default.desktopDirectory
        case .documents:
            url = FileManager.default.documentsDirectory
        case .pictures:
            url = FileManager.default.picturesDirectory
        }
        
        NSWorkspace.shared.open(url)
    }
}

enum DirectoryType {
    case downloads, desktop, documents, pictures
}

struct ProviderButton: View {
    let provider: LLMProvider
    let isSelected: Bool
    let action: () -> Void
    
    private var providerIcon: String {
        switch provider {
        case .deepseek:
            return "brain.head.profile"
        case .openai:
            return "cpu"
        case .claude:
            return "sparkles"
        case .groq:
            return "bolt.fill"
        case .ollama:
            return "house"
        }
    }
    
    private var providerColor: Color {
        switch provider {
        case .deepseek:
            return .orange
        case .openai:
            return .green
        case .claude:
            return .purple
        case .groq:
            return .red
        case .ollama:
            return .blue
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: providerIcon)
                    .font(.title3)
                    .foregroundColor(isSelected ? providerColor : .secondary)
                
                Text(provider.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? providerColor : .primary)
                    .multilineTextAlignment(.center)
                
                if !provider.requiresApiKey {
                    Text("Local")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? providerColor.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? providerColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ExampleCommand: View {
    let command: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(command)
                .font(.body)
                .fontWeight(.medium)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.05))
        .cornerRadius(6)
    }
}

struct ApiKeyInputView: View {
    @ObservedObject var llmService: LLMService
    @Binding var isPresented: Bool
    @State private var apiKey = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Text("\(llmService.selectedProvider.rawValue) API Key")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter your \(llmService.selectedProvider.rawValue) API key to enable AI-powered file operations.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Provider-specific instructions
            switch llmService.selectedProvider {
            case .deepseek:
                Text("Get your API key from platform.deepseek.com")
                    .font(.caption)
                    .foregroundColor(.blue)
            case .openai:
                Text("Get your API key from platform.openai.com")
                    .font(.caption)
                    .foregroundColor(.blue)
            case .claude:
                Text("Get your API key from console.anthropic.com")
                    .font(.caption)
                    .foregroundColor(.blue)
            case .groq:
                Text("Get your API key from console.groq.com")
                    .font(.caption)
                    .foregroundColor(.blue)
            case .ollama:
                Text("Ollama runs locally - no API key needed")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            SecureField("API Key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    llmService.setApiKey(apiKey, for: llmService.selectedProvider)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.isEmpty)
            }
        }
        .padding(32)
        .frame(width: 400)
        .onAppear {
            apiKey = llmService.getApiKey(for: llmService.selectedProvider)
        }
    }
}

#Preview {
    FileOperationView()
}
