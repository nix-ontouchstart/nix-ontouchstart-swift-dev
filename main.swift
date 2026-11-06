import SwiftUI
import AppKit

// --- The UI Logic ---
struct ContentView: View {
    @State private var count = 0
    @State private var message = "Click the magic button"
    
    var body: some View {
        ZStack {
            // Fancy Gradient Background
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Fancy Swift App")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text(message)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("\(count)")
                    .font(.system(size: 80, weight: .black, design: .monospaced))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                
                Button(action: {
                    count += 1
                    message = "Magic Power: \(count)"
                }) {
                    Text("TAP ME")
                        .font(.headline)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.purple)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(count > 0 ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
            }
            .padding(40)
        }
        .frame(width: 400, height: 500)
    }
}

// --- The Boilerplate to launch a GUI from a single file ---
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Fancy Swift App"
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// Initialize the app
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

