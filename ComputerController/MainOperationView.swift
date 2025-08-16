import SwiftUI

struct MainOperationView: View {
    @ObservedObject var llmService: LLMService
    @ObservedObject var pythonExecutor: PythonExecutor
    @State private var userInput = ""
    @State private var isProcessing = false
    @State private var showConfirmation = false
    @State private var generatedCode = ""
    @State private var operationDescription = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Main content
            HStack(spacing: 0) {
                // Input area
                inputArea
                
                // Divider
                Divider()
                    .frame(width: 1)
                    .background(Color.gray.opacity(0.3))
                
                // Output area
                outputArea
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Confirm Operation", isPresented: $showConfirmation) {
            Button("Execute") {
                executeGeneratedCode()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to execute this operation?\n\n\(operationDescription)")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "laptopcomputer")
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Computer Controller")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Control your Mac with natural language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(llmService.isConnected ? .green : .red)
                        .frame(width: 8, height: 8)
                    
                    Text(llmService.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    private var inputArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What would you like me to do?")
                .font(.headline)
                .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                TextEditor(text: $userInput)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .frame(minHeight: 120)
                
                HStack {
                    Button(action: clearInput) {
                        Label("Clear", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button(action: processUserInput) {
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 20, height: 20)
                        } else {
                            Label("Execute", systemImage: "play.fill")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isProcessing || !llmService.isConnected)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var outputArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated Code")
                .font(.headline)
                .padding(.horizontal, 24)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !generatedCode.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Operation:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(operationDescription)
                                .font(.body)
                                .padding(12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Python Code:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(generatedCode)
                                .font(.system(.body, design: .monospaced))
                                .padding(12)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        if pythonExecutor.lastResult != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Result:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(pythonExecutor.lastResult ?? "")
                                    .font(.system(.body, design: .monospaced))
                                    .padding(12)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "terminal")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("No code generated yet")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            if llmService.isConnected {
                                Text("Describe what you want to do in natural language, and I'll generate the appropriate Python code to execute it.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Please set your DeepSeek API key in the Settings tab to start using the app.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 40)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func processUserInput() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isProcessing = true
        
        Task {
            do {
                let result = try await llmService.generateCode(for: userInput)
                await MainActor.run {
                    generatedCode = result.code
                    operationDescription = result.description
                    isProcessing = false
                    showConfirmation = true
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    // Handle error
                }
            }
        }
    }
    
    private func clearInput() {
        userInput = ""
        generatedCode = ""
        operationDescription = ""
        pythonExecutor.lastResult = nil
    }
    
    private func executeGeneratedCode() {
        guard !generatedCode.isEmpty else { return }
        
        Task {
            do {
                let result = try await pythonExecutor.execute(code: generatedCode)
                await MainActor.run {
                    pythonExecutor.lastResult = result
                }
            } catch {
                await MainActor.run {
                    pythonExecutor.lastResult = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    MainOperationView(
        llmService: LLMService(),
        pythonExecutor: PythonExecutor()
    )
}
