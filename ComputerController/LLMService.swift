import Foundation
import SwiftUI

struct GeneratedCode {
    let code: String
    let description: String
}

class LLMService: ObservableObject {
    @Published var isConnected = false
    @AppStorage("deepseekApiKey") private var apiKey: String = ""
    
    private let baseURL = "https://api.deepseek.com/v1/chat/completions"
    
    init() {
        checkConnection()
    }
    
    func checkConnection() {
        isConnected = !apiKey.isEmpty
    }
    
    func generateCode(for userRequest: String) async throws -> GeneratedCode {
        guard !apiKey.isEmpty else {
            throw LLMError.noApiKey
        }
        
        let prompt = createPrompt(for: userRequest)
        let request = createRequest(prompt: prompt)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw LLMError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw LLMError.httpError(statusCode: httpResponse.statusCode)
            }
        
            let result = try parseResponse(data: data)
            return result
        } catch {
            throw LLMError.networkError(error)
        }
    }
    
    private func createPrompt(for userRequest: String) -> String {
        return """
        You are a helpful AI assistant that generates Python code to control a macOS computer. 
        The user will describe what they want to do in natural language, and you should generate safe, appropriate Python code to accomplish that task.
        
        IMPORTANT SAFETY RULES:
        1. Only generate code for file operations (move, copy, rename, delete, create directories)
        2. Always use proper error handling with try-catch blocks
        3. Never generate code that could harm the system or access sensitive data
        4. Use the os, shutil, pathlib, and other standard Python libraries
        5. Always check if files/directories exist before operating on them
        6. Provide clear, descriptive output messages
        
        User Request: \(userRequest)
        
        Generate Python code that:
        1. Safely performs the requested operation
        2. Includes proper error handling
        3. Provides user feedback
        4. Is ready to execute
        
        Return ONLY the Python code, no explanations or markdown formatting.
        """
    }
    
    private func createRequest(prompt: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.1,
            "max_tokens": 1000
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        return request
    }
    
    private func parseResponse(data: Data) throws -> GeneratedCode {
        let decoder = JSONDecoder()
        let response = try decoder.decode(DeepSeekResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content else {
            throw LLMError.invalidResponse
        }
        
        // Clean up the response to extract just the code
        let cleanCode = content.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```python", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return GeneratedCode(
            code: cleanCode,
            description: "Executing: \(userRequest)"
        )
    }
    
    func setApiKey(_ key: String) {
        apiKey = key
        checkConnection()
    }
    
    func getApiKey() -> String {
        return apiKey
    }
}

// MARK: - Response Models
struct DeepSeekResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
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
