import SwiftUI

struct ContentView: View {
    @StateObject private var llmService = LLMService()
    @StateObject private var pythonExecutor = PythonExecutor()
    @State private var selectedTab = 0
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainOperationView(llmService: llmService, pythonExecutor: pythonExecutor)
                .tabItem {
                    Image(systemName: "laptopcomputer")
                    Text("Computer Control")
                }
                .tag(0)
            
            FileOperationView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings & Tools")
                }
                .tag(1)
        }
        .frame(minWidth: 800, minHeight: 600)
        .preferredColorScheme(preferredColorScheme)
    }
    
    private var preferredColorScheme: ColorScheme? {
        return isDarkMode ? .dark : .light
    }
}

#Preview {
    ContentView()
}
