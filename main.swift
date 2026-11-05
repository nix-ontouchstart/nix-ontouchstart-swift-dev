import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, 
            defer: false
        )
        window.center()
        window.title = "Nix Native GUI Example"
        window.makeKeyAndOrderFront(nil)

        // Create a native button
        let button = NSButton(frame: NSRect(x: 150, y: 80, width: 100, height: 40))
        button.title = "Click Me!"
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(buttonClicked)

        if let contentView = window.contentView {
            contentView.addSubview(button)
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func buttonClicked() {
        print("Hello from a Nix-built native GUI!")
    }
}

// Bootstrap the application without an Info.plist requirement for simplicity
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()

