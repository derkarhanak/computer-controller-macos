import Foundation
import SwiftUI

class PythonExecutor: ObservableObject {
    @Published var lastResult: String?
    
    private let pythonPath = "/usr/bin/python3"
    
    func execute(code: String) async throws -> String {
        // Create a temporary Python file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("temp_script_\(UUID().uuidString).py")
        
        // Write the code to the temporary file
        try code.write(to: tempFile, atomically: true, encoding: .utf8)
        
        defer {
            // Clean up the temporary file
            try? FileManager.default.removeItem(at: tempFile)
        }
        
        // Create the process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)
        process.arguments = [tempFile.path]
        
        // Set up pipes for input/output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Set working directory to user's home directory for safety
        process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        do {
            try process.run()
            process.waitUntilExit()
            
            // Read output and error
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8) ?? ""
            
            // Check if the process completed successfully
            if process.terminationStatus == 0 {
                return output.isEmpty ? "Operation completed successfully" : output
            } else {
                return "Error: \(error.isEmpty ? "Process failed with exit code \(process.terminationStatus)" : error)"
            }
        } catch {
            throw PythonExecutionError.executionFailed(error)
        }
    }
    
    func validateCode(_ code: String) -> Bool {
        // Basic validation - check for potentially dangerous operations
        let dangerousPatterns = [
            "import subprocess",
            "import os.system",
            "eval(",
            "exec(",
            "open(",
            "__import__",
            "globals(",
            "locals(",
            "compile(",
            "input("
        ]
        
        let lowercasedCode = code.lowercased()
        
        for pattern in dangerousPatterns {
            if lowercasedCode.contains(pattern.lowercased()) {
                return false
            }
        }
        
        // Check if it's a valid Python file operation
        let safePatterns = [
            "import os",
            "import shutil",
            "import pathlib",
            "import glob",
            "os.path",
            "shutil.",
            "pathlib.",
            "glob.glob",
            "os.makedirs",
            "os.remove",
            "os.rename",
            "shutil.move",
            "shutil.copy",
            "shutil.rmtree"
        ]
        
        var hasSafeOperation = false
        for pattern in safePatterns {
            if lowercasedCode.contains(pattern.lowercased()) {
                hasSafeOperation = true
                break
            }
        }
        
        return hasSafeOperation
    }
}

enum PythonExecutionError: LocalizedError {
    case executionFailed(Error)
    case invalidCode
    
    var errorDescription: String? {
        switch self {
        case .executionFailed(let error):
            return "Python execution failed: \(error.localizedDescription)"
        case .invalidCode:
            return "Invalid or unsafe Python code detected"
        }
    }
}
