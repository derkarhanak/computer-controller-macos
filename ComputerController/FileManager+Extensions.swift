import Foundation

extension FileManager {
    
    // Get user's common directories
    var documentsDirectory: URL {
        return homeDirectoryForCurrentUser.appendingPathComponent("Documents")
    }
    
    var downloadsDirectory: URL {
        return homeDirectoryForCurrentUser.appendingPathComponent("Downloads")
    }
    
    var desktopDirectory: URL {
        return homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
    }
    
    var picturesDirectory: URL {
        return homeDirectoryForCurrentUser.appendingPathComponent("Pictures")
    }
    
    var musicDirectory: URL {
        return homeDirectoryForCurrentUser.appendingPathComponent("Music")
    }
    
    var moviesDirectory: URL {
        return homeDirectoryForCurrentUser.appendingPathComponent("Movies")
    }
    
    // Check if a path exists and is accessible
    func isPathAccessible(_ path: String) -> Bool {
        return fileExists(atPath: path) && isReadableFile(atPath: path)
    }
    
    // Get file size in human readable format
    func fileSizeString(at url: URL) -> String {
        do {
            let attributes = try attributesOfItem(atPath: url.path)
            let size = attributes[.size] as? Int64 ?? 0
            
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: size)
        } catch {
            return "Unknown size"
        }
    }
    
    // Get file creation and modification dates
    func fileDates(at url: URL) -> (created: Date?, modified: Date?) {
        do {
            let attributes = try attributesOfItem(atPath: url.path)
            let created = attributes[.creationDate] as? Date
            let modified = attributes[.modificationDate] as? Date
            return (created, modified)
        } catch {
            return (nil, nil)
        }
    }
    
    // List contents of a directory
    func listDirectoryContents(at url: URL) -> [URL] {
        do {
            let contents = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            return contents.sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            return []
        }
    }
    
    // Check if a file is hidden
    func isHiddenFile(at url: URL) -> Bool {
        return url.lastPathComponent.hasPrefix(".")
    }
    
    // Get file type description
    func fileTypeDescription(at url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "pdf":
            return "PDF Document"
        case "doc", "docx":
            return "Word Document"
        case "xls", "xlsx":
            return "Excel Spreadsheet"
        case "ppt", "pptx":
            return "PowerPoint Presentation"
        case "jpg", "jpeg", "png", "gif", "bmp":
            return "Image"
        case "mp4", "mov", "avi", "mkv":
            return "Video"
        case "mp3", "wav", "aac":
            return "Audio"
        case "txt", "rtf":
            return "Text Document"
        case "zip", "rar", "7z":
            return "Archive"
        case "":
            return "Folder"
        default:
            return "\(pathExtension.uppercased()) File"
        }
    }
}
