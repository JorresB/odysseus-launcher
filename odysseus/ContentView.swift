import SwiftUI
import WebKit
import Foundation

// MARK: - WebView
struct WebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}

// MARK: - Port check
func isPortOpen(_ port: Int) -> Bool {
    let socketFD = socket(AF_INET, SOCK_STREAM, 0)
    guard socketFD >= 0 else { return false }
    defer { close(socketFD) }

    var addr = sockaddr_in(
        sin_len: UInt8(MemoryLayout<sockaddr_in>.size),
        sin_family: sa_family_t(AF_INET),
        sin_port: UInt16(port).bigEndian,
        sin_addr: in_addr(s_addr: inet_addr("127.0.0.1")),
        sin_zero: (0,0,0,0,0,0,0,0)
    )

    let result = withUnsafePointer(to: &addr) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(socketFD, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }

    return result == 0
}

// MARK: - ContentView
struct ContentView: View {

    private let webView = WKWebView()
    private let port = 7860

    @State private var isReady = false
    @State private var serverStarted = false
    @State private var hasError = false

    var body: some View {
        ZStack {

            // SPLASH / ERROR STATE
            if !isReady {
                VStack(spacing: 12) {

                    if hasError {
                        Text("⚠️ Failed to start Odysseus")
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                        Text("Starting Odysseus...")
                            .opacity(0.7)
                    }
                }
            }

            // WEBVIEW
            WebView(webView: webView)
                .opacity(isReady ? 1 : 0)
                .ignoresSafeArea()
        }
        .onAppear {
            startServerIfNeeded()
            waitForServer()
        }
    }

    // MARK: - Start backend
    func startServerIfNeeded() {
        guard !isPortOpen(port), !serverStarted else { return }

        serverStarted = true

        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath
        let projectURL = URL(fileURLWithPath: currentPath)

        let pythonPath = projectURL
            .appendingPathComponent("backend/venv/bin/python")
            .path

        let task = Process()
        task.currentDirectoryURL = projectURL
        task.executableURL = URL(fileURLWithPath: pythonPath)

        task.arguments = [
            "-m",
            "uvicorn",
            "app:app",
            "--host",
            "127.0.0.1",
            "--port",
            "\(port)"
        ]

        task.standardOutput = Pipe()
        task.standardError = Pipe()

        do {
            try task.run()
        } catch {
            hasError = true
        }

        // fallback timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !isReady {
                hasError = true
            }
        }
    }

    // MARK: - Wait for server
    func waitForServer() {
        let url = URL(string: "http://127.0.0.1:\(port)")!

        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in

            URLSession.shared.dataTask(with: url) { _, response, _ in

                guard let http = response as? HTTPURLResponse,
                      (200...399).contains(http.statusCode) else { return }

                DispatchQueue.main.async {

                    webView.load(URLRequest(url: url))

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isReady = true
                    }

                    timer.invalidate()
                }

            }.resume()
        }
    }
}
