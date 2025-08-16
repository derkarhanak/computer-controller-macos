import SwiftUI

struct FileOperationView: View {
    @StateObject private var llmService = LLMService()
    @State private var showApiKeyInput = false
    @State private var tempApiKey = ""
    
    var body: some View {
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
            .padding(.horizontal, 24)
            
            // API Key Section
            VStack(alignment: .leading, spacing: 16) {
                Text("DeepSeek API Configuration")
                    .font(.headline)
                
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
                    
                    Button(action: { showApiKeyInput = true }) {
                        Label(llmService.isConnected ? "Change Key" : "Set Key", systemImage: "key")
                    }
                    .buttonStyle(.bordered)
                }
                
                if llmService.isConnected {
                    Text("✓ Your DeepSeek API key is configured and working")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("⚠ Please set your DeepSeek API key to use the app")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
            // Quick Actions Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick File Operations")
                    .font(.headline)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
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
            .padding(.horizontal, 24)
            
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
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.top, 20)
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
            Text("DeepSeek API Key")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Enter your DeepSeek API key to enable AI-powered file operations.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            SecureField("API Key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    llmService.setApiKey(apiKey)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.isEmpty)
            }
        }
        .padding(32)
        .frame(width: 400)
    }
}

#Preview {
    FileOperationView()
}
