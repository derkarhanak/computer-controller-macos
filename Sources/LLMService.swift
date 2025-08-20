import Foundation
import SwiftUI

enum LLMProvider: String, CaseIterable {
    case deepseek = "DeepSeek"
    case openai = "OpenAI"
    case claude = "Anthropic Claude"
    case groq = "Groq"
    case ollama = "Ollama (Local)"
    
    var baseURL: String {
        switch self {
        case .deepseek:
            return "https://api.deepseek.com/v1/chat/completions"
        case .openai:
            return "https://api.openai.com/v1/chat/completions"
        case .claude:
            return "https://api.anthropic.com/v1/messages"
        case .groq:
            return "https://api.groq.com/openai/v1/chat/completions"
        case .ollama:
            return "http://localhost:11434/api/generate"
        }
    }
    
    var defaultModel: String {
        switch self {
        case .deepseek:
            return "deepseek-chat"
        case .openai:
            return "gpt-4"
        case .claude:
            return "claude-3-sonnet-20240229"
        case .groq:
            return "openai/gpt-oss-20b" // GPT-OSS 20B model
        case .ollama:
            return "llama3.2:3b" // Default, will be overridden by selectedOllamaModel
        }
    }
    
    var requiresApiKey: Bool {
        switch self {
        case .deepseek, .openai, .claude, .groq:
            return true
        case .ollama:
            return false
        }
    }
}

struct GeneratedCode {
    let code: String
    let description: String
}

struct ConversationEntry {
    let userRequest: String
    let generatedCode: String
    let executionResult: String?
    let timestamp: Date
}

@MainActor
class LLMService: ObservableObject {
    @Published var isConnected = false
    @AppStorage("selectedProvider") private var selectedProviderRaw: String = LLMProvider.deepseek.rawValue
    @AppStorage("deepseekApiKey") private var deepseekApiKey: String = ""
    @AppStorage("openaiApiKey") private var openaiApiKey: String = ""
    @AppStorage("claudeApiKey") private var claudeApiKey: String = ""
    @AppStorage("groqApiKey") private var groqApiKey: String = ""
    @AppStorage("selectedGroqModel") var selectedGroqModel: String = "openai/gpt-oss-20b"
    @AppStorage("selectedOllamaModel") var selectedOllamaModel: String = "llama3.2:3b"
    @Published var conversationHistory: [ConversationEntry] = []
    @Published var availableOllamaModels: [String] = []
    @Published var availableGroqModels: [String] = []
    
    var selectedProvider: LLMProvider {
        get {
            LLMProvider(rawValue: selectedProviderRaw) ?? .deepseek
        }
        set {
            selectedProviderRaw = newValue.rawValue
            checkConnection()
            if newValue == .ollama {
                Task {
                    await fetchAvailableOllamaModels()
                }
            } else if newValue == .groq {
                Task {
                    await fetchAvailableGroqModels()
                }
            }
        }
    }
    
    private var currentApiKey: String {
        switch selectedProvider {
        case .deepseek:
            return deepseekApiKey
        case .openai:
            return openaiApiKey
        case .claude:
            return claudeApiKey
        case .groq:
            return groqApiKey
        case .ollama:
            return "" // No API key needed for local Ollama
        }
    }
    
    private var currentModel: String {
        switch selectedProvider {
        case .deepseek:
            return selectedProvider.defaultModel
        case .openai:
            return selectedProvider.defaultModel
        case .claude:
            return selectedProvider.defaultModel
        case .groq:
            return selectedGroqModel
        case .ollama:
            return selectedOllamaModel
        }
    }
    
    init() {
        checkConnection()
        if selectedProvider == .ollama {
            Task {
                await fetchAvailableOllamaModels()
            }
        } else if selectedProvider == .groq {
            Task {
                await fetchAvailableGroqModels()
            }
        }
    }
    
    func checkConnection() {
        if selectedProvider.requiresApiKey {
            isConnected = !currentApiKey.isEmpty
        } else {
            // For Ollama, we assume it's connected if selected
            isConnected = true
        }
    }
    
    func generateCode(for userRequest: String) async throws -> GeneratedCode {
        if selectedProvider.requiresApiKey && currentApiKey.isEmpty {
            throw LLMError.noApiKey
        }
        
        let prompt = createPrompt(for: userRequest)
        print("🤖 Using provider: \(selectedProvider.rawValue)")
        print("🌐 API URL: \(selectedProvider.baseURL)")
        let request = createRequest(prompt: prompt)
        
        do {
            // Set timeout for Ollama (it can be slow)
            var urlRequest = request
            urlRequest.timeoutInterval = selectedProvider == .ollama ? 120 : 30
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                throw LLMError.invalidResponse
            }
            
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Response: \(responseString)")
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw LLMError.httpError(statusCode: httpResponse.statusCode)
            }
        
            let result = try parseResponse(data: data)
            return result
        } catch {
            print("❌ Network Error: \(error)")
            throw LLMError.networkError(error)
        }
    }
    
        private func createPrompt(for userRequest: String) -> String {
        // Simplified prompt for Ollama to avoid timeout
        let basePrompt = selectedProvider == .ollama ? 
        """
        Generate Python code for: \(userRequest)
        
        Rules:
        1. Include all imports (os, shutil, pathlib)
        2. Use try/except for error handling
        3. Print clear messages
        4. No input() or interactive code
        5. Return ONLY the Python code
        """ :
        """
        You are a helpful AI assistant that generates Python code to control a macOS computer.
        The user will describe what they want to do in natural language, and you should generate safe, appropriate Python code to accomplish that task.
        
        IMPORTANT SAFETY RULES:
        1. Only generate code for file operations (move, copy, rename, delete, create directories)
        2. Always use proper error handling with try-catch blocks
        3. Never generate code that could harm the system or access sensitive data
        4. ALWAYS include ALL necessary import statements at the top (import os, import shutil, import pathlib, etc.)
        5. Use the os, shutil, pathlib, and other standard Python libraries
        6. Always check if files/directories exist before operating on them
        7. Provide clear, descriptive output messages
        8. NEVER use input() or any interactive prompts - the code must run automatically
        9. Do not ask for user confirmation in the code - assume the user has already confirmed
        """
        
        var contextPrompt = basePrompt
        
        // Add conversation history for context (less for Ollama to be faster)
        if !conversationHistory.isEmpty && selectedProvider != .ollama {
            contextPrompt += "\nPREVIOUS CONVERSATION HISTORY:\n"
            for (index, entry) in conversationHistory.suffix(3).enumerated() {
                contextPrompt += "\n--- Previous Command \(index + 1) ---\n"
                contextPrompt += "User: \(entry.userRequest)\n"
                contextPrompt += "Generated Code:\n\(entry.generatedCode)\n"
                if let result = entry.executionResult {
                    contextPrompt += "Result: \(result)\n"
                }
            }
            contextPrompt += "\nYou can reference files, folders, or results from the previous commands above.\n"
        } else if !conversationHistory.isEmpty && selectedProvider == .ollama {
            // Minimal context for Ollama
            if let lastEntry = conversationHistory.last {
                contextPrompt += "\nLast command: \(lastEntry.userRequest)\n"
            }
        }
        
        contextPrompt += """
        
        Current User Request: \(userRequest)
        
        Generate Python code that:
        1. STARTS with ALL necessary import statements (import os, import shutil, import pathlib, etc.)
        2. Safely performs the requested operation
        3. Includes proper error handling
        4. Provides user feedback through print statements
        5. Is ready to execute without any user interaction
        6. Can reference previous results if the user is asking for follow-up operations
        7. Runs completely automatically (no input(), confirm prompts, or user interaction)
        
        CRITICAL: The code will run in a non-interactive environment. Do NOT include:
        - input() calls
        - confirmation prompts
        - any code that waits for user input
        
        Return ONLY the Python code, no explanations or markdown formatting.
        """
        
        return contextPrompt
    }
    
    private func createRequest(prompt: String) -> URLRequest {
        var request = URLRequest(url: URL(string: selectedProvider.baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var requestBody: [String: Any] = [:]
        
        switch selectedProvider {
        case .deepseek, .openai, .groq:
            request.setValue("Bearer \(currentApiKey)", forHTTPHeaderField: "Authorization")
            requestBody = [
                "model": currentModel,
                "messages": [
                    [
                        "role": "user",
                        "content": prompt
                    ]
                ],
                "temperature": 0.1,
                "max_tokens": 1000
            ]
            
        case .claude:
            request.setValue(currentApiKey, forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            requestBody = [
                "model": selectedProvider.defaultModel,
                "max_tokens": 1000,
                "messages": [
                    [
                        "role": "user",
                        "content": prompt
                    ]
                ]
            ]
            
        case .ollama:
            requestBody = [
                "model": selectedOllamaModel,
                "prompt": prompt,
                "stream": false,
                "options": [
                    "temperature": 0.1,
                    "top_p": 0.9,
                    "max_tokens": 1000
                ]
            ]
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        return request
    }
    
    private func parseResponse(data: Data) throws -> GeneratedCode {
        let decoder = JSONDecoder()
        var content: String = ""
        
        switch selectedProvider {
        case .deepseek, .openai, .groq:
            let response = try decoder.decode(OpenAIResponse.self, from: data)
            guard let messageContent = response.choices.first?.message.content else {
                throw LLMError.invalidResponse
            }
            content = messageContent
            
        case .claude:
            let response = try decoder.decode(ClaudeResponse.self, from: data)
            guard let textContent = response.content.first?.text else {
                throw LLMError.invalidResponse
            }
            content = textContent
            
        case .ollama:
            let response = try decoder.decode(OllamaResponse.self, from: data)
            content = response.response
        }
        
        // Clean up the response to extract just the code
        let cleanCode = content.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```python", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return GeneratedCode(
            code: cleanCode,
            description: "Generated Python code"
        )
    }
    
    func setApiKey(_ key: String, for provider: LLMProvider) {
        switch provider {
        case .deepseek:
            deepseekApiKey = key
        case .openai:
            openaiApiKey = key
        case .claude:
            claudeApiKey = key
        case .groq:
            groqApiKey = key
        case .ollama:
            break // No API key needed
        }
        checkConnection()
    }
    
    func getApiKey(for provider: LLMProvider) -> String {
        switch provider {
        case .deepseek:
            return deepseekApiKey
        case .openai:
            return openaiApiKey
        case .claude:
            return claudeApiKey
        case .groq:
            return groqApiKey
        case .ollama:
            return ""
        }
    }
    
    func addToHistory(userRequest: String, generatedCode: String, executionResult: String?) {
        let entry = ConversationEntry(
            userRequest: userRequest,
            generatedCode: generatedCode,
            executionResult: executionResult,
            timestamp: Date()
        )
        conversationHistory.append(entry)
        
        // Keep only the last 10 entries to prevent the prompt from getting too long
        if conversationHistory.count > 10 {
            conversationHistory.removeFirst()
        }
    }
    
    func clearHistory() {
        conversationHistory.removeAll()
    }
    
    func fetchAvailableOllamaModels() async {
        do {
            let url = URL(string: "http://localhost:11434/api/tags")!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            struct OllamaTagsResponse: Codable {
                let models: [OllamaModelInfo]
            }
            
            struct OllamaModelInfo: Codable {
                let name: String
            }
            
            let response = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
            let modelNames = response.models.map { $0.name }
            
            await MainActor.run {
                self.availableOllamaModels = modelNames
                // If current selected model is not available, use the first one
                if !modelNames.contains(selectedOllamaModel) && !modelNames.isEmpty {
                    selectedOllamaModel = modelNames.first!
                }
            }
        } catch {
            print("❌ Failed to fetch Ollama models: \(error)")
        }
    }
    
    func setOllamaModel(_ model: String) {
        selectedOllamaModel = model
    }
    
    func setGroqModel(_ model: String) {
        selectedGroqModel = model
    }
    
    func getCurrentModelName() -> String {
        switch selectedProvider {
        case .deepseek:
            return "DeepSeek Chat"
        case .openai:
            return "GPT-4"
        case .claude:
            return "Claude 3 Sonnet"
        case .groq:
            return selectedGroqModel
        case .ollama:
            return selectedOllamaModel
        }
    }
    
    func fetchAvailableGroqModels() async {
        // Groq has a fixed set of available models
        let models = [
            "openai/gpt-oss-20b",  // GPT-OSS 20B (User's preferred model)
            "llama3-8b-8192",      // Fast Llama 3 8B
            "llama3-70b-8192",     // High-quality Llama 3 70B
            "mixtral-8x7b-32768",  // Mixtral 8x7B
            "gemma2-9b-it",        // Gemma 2 9B
            "llama2-70b-4096"      // Llama 2 70B
        ]
        
        await MainActor.run {
            self.availableGroqModels = models
            // If current selected model is not available, use the first one
            if !models.contains(selectedGroqModel) {
                selectedGroqModel = models.first!
            }
        }
    }
    

}

// MARK: - Response Models
// OpenAI/DeepSeek format
struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

struct OpenAIMessage: Codable {
    let content: String
}

// Claude format
struct ClaudeResponse: Codable {
    let content: [ClaudeContent]
}

struct ClaudeContent: Codable {
    let text: String
}

// Ollama format
struct OllamaResponse: Codable {
    let response: String
}

// MARK: - Errors
enum LLMError: LocalizedError {
    case noApiKey
    case invalidResponse
    case httpError(statusCode: Int)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noApiKey:
            return "No API key provided. Please set your DeepSeek API key in settings."
        case .invalidResponse:
            return "Invalid response from DeepSeek API."
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
