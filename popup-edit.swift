#!/usr/bin/env swift

import Cocoa

class EditorWindowController: NSObject, NSWindowDelegate, NSTextViewDelegate {
    var window: NSWindow!
    var textView: NSTextView!
    var saved = false
    var filePath: String

    init(filePath: String) {
        self.filePath = filePath
        super.init()
        setupWindow()
    }

    func setupWindow() {
        // Create window
        let windowRect = NSRect(x: 0, y: 0, width: 600, height: 400)
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Claude Prompt"
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.center()
        window.level = .floating

        // Create main container
        let contentView = NSView(frame: windowRect)
        contentView.wantsLayer = true

        // Create scroll view with text view
        let scrollView = NSScrollView(frame: NSRect(x: 16, y: 56, width: 568, height: 328))
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.borderType = .bezelBorder

        textView = NSTextView(frame: scrollView.bounds)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.delegate = self

        // Load file content
        if let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
            textView.string = content
        }

        scrollView.documentView = textView
        contentView.addSubview(scrollView)

        // Create buttons
        let cancelButton = NSButton(frame: NSRect(x: 400, y: 12, width: 80, height: 32))
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.target = self
        cancelButton.action = #selector(cancelAction)
        cancelButton.keyEquivalent = "\u{1b}" // Escape
        cancelButton.autoresizingMask = [.minXMargin, .maxYMargin]
        contentView.addSubview(cancelButton)

        let saveButton = NSButton(frame: NSRect(x: 488, y: 12, width: 96, height: 32))
        saveButton.title = "Save ⌘↩"
        saveButton.bezelStyle = .rounded
        saveButton.target = self
        saveButton.action = #selector(saveAction)
        saveButton.keyEquivalent = "\r"
        saveButton.keyEquivalentModifierMask = [.command]
        saveButton.autoresizingMask = [.minXMargin, .maxYMargin]
        contentView.addSubview(saveButton)

        // Hint label
        let hintLabel = NSTextField(labelWithString: "⌘↩ to save  •  ⎋ to cancel")
        hintLabel.frame = NSRect(x: 16, y: 16, width: 200, height: 20)
        hintLabel.font = NSFont.systemFont(ofSize: 11)
        hintLabel.textColor = .secondaryLabelColor
        hintLabel.autoresizingMask = [.maxXMargin, .maxYMargin]
        contentView.addSubview(hintLabel)

        window.contentView = contentView
    }

    @objc func saveAction() {
        do {
            try textView.string.write(toFile: filePath, atomically: true, encoding: .utf8)
            saved = true
            NSApp.stopModal(withCode: .OK)
            window.close()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Error saving file"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    @objc func cancelAction() {
        NSApp.stopModal(withCode: .cancel)
        window.close()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApp.stopModal(withCode: .cancel)
        return true
    }

    func run() -> Bool {
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textView)
        textView.selectAll(nil) // Select all text initially

        NSApp.activate(ignoringOtherApps: true)
        NSApp.runModal(for: window)

        return saved
    }
}

// Main
guard CommandLine.arguments.count > 1 else {
    fputs("Usage: popup-edit <file>\n", stderr)
    exit(1)
}

let filePath = CommandLine.arguments[1]

// Verify file exists or can be created
if !FileManager.default.fileExists(atPath: filePath) {
    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let controller = EditorWindowController(filePath: filePath)
let success = controller.run()

exit(success ? 0 : 1)
