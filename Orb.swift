import Cocoa
import WebKit

class OrbPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override func sendEvent(_ event: NSEvent) {
        let point = event.locationInWindow
        let center = NSPoint(x: 66, y: frame.height - 66)
        guard event.type == .leftMouseDown,
              hypot(point.x - center.x, point.y - center.y) <= 61 else {
            super.sendEvent(event)
            return
        }
        let start = convertPoint(toScreen: point)
        let origin = frame.origin
        var dragging = false
        while let next = nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) {
            let cursor = convertPoint(toScreen: next.locationInWindow)
            let dx = cursor.x - start.x
            let dy = cursor.y - start.y
            if hypot(dx, dy) >= 4 { dragging = true }
            if dragging {
                setFrameOrigin(NSPoint(x: origin.x + dx, y: origin.y + dy))
            }
            if next.type == .leftMouseUp {
                if !dragging {
                    (contentView as? WKWebView)?.evaluateJavaScript("document.getElementById('bubble')?.click()")
                }
                break
            }
        }
    }
}

class Orb: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    let window = OrbPanel(contentRect: NSRect(x: 0,y: 0,width: 132,height: 132),
                          styleMask: [.borderless,.nonactivatingPanel], backing: .buffered, defer: false)
    let url = URL(string:"http://127.0.0.1:18742/")!
    var web: WKWebView!
    var backend: Process?
    func applicationDidFinishLaunching(_ note: Notification) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath:"/usr/bin/python3")
        let folder = Bundle.main.resourceURL!
        task.arguments = ["-B",folder.appendingPathComponent("app.py").path,"--quiet"]
        try? task.run()
        backend = task
        let config = WKWebViewConfiguration()
        config.userContentController.add(self,name:"orb")
        web = WKWebView(frame:window.contentView!.bounds,configuration:config)
        web.setValue(false,forKey:"drawsBackground")
        web.navigationDelegate = self
        window.contentView = web
        window.title = "Antigravity 用量悬浮球"
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.level = .floating
        window.hidesOnDeactivate = false
        window.collectionBehavior = [.canJoinAllSpaces,.fullScreenAuxiliary]
        let screen = NSScreen.main!.visibleFrame
        window.setFrameTopLeftPoint(NSPoint(x:screen.maxX-148,y:screen.maxY-32))
        window.orderFrontRegardless()
        web.load(URLRequest(url:url))
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline:.now()+1){ self.web.load(URLRequest(url:self.url)) }
    }
    func userContentController(_ controller: WKUserContentController,didReceive message: WKScriptMessage){
        guard let action = message.body as? String else{return}
        if action == "quit" { NSApp.terminate(nil);return }
        let size = action == "expand" ? NSSize(width:300,height:320) : NSSize(width:132,height:132)
        let prev = window.frame
        var x = prev.maxX-size.width
        var y = prev.maxY-size.height
        if let screen = window.screen?.visibleFrame {
            x = min(max(x,screen.minX),screen.maxX-size.width)
            y = min(max(y,screen.minY),screen.maxY-size.height)
        }
        window.setFrame(NSRect(origin:NSPoint(x:x,y:y),size:size),display:true)
        if action == "expand" { NSApp.activate(ignoringOtherApps:true);window.makeKeyAndOrderFront(nil) }
    }
    func applicationWillTerminate(_ notification: Notification) {
        if backend?.isRunning == true { backend?.terminate() }
    }
}
let app=NSApplication.shared
let delegate=Orb()
app.delegate=delegate
app.setActivationPolicy(.accessory)
app.run()
