//
//  WKWebViewRepresentable.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import SwiftUI
import WebKit

struct WKWebViewRepresentable: UIViewRepresentable {
    typealias UIViewType = WKWebView
    var url: URL
    var webView: WKWebView
    
    @Binding var loadComplete: Bool
    @Binding var presentToast: Bool
    @Binding var toastMessage: String
    
    init(url: URL, loadComplete: Binding<Bool>, presentToast: Binding<Bool>, toastMessage: Binding<String>) {
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        
        let printJS = """
window.print = function() {
    window.webkit.messageHandlers.print.postMessage('print')
};
"""
        let printScript = WKUserScript(source: printJS, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(printScript)
        configuration.preferences = preferences
        configuration.dataDetectorTypes = [.all]
        
        self.url = url
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self._loadComplete = loadComplete
        self._presentToast = presentToast
        self._toastMessage = toastMessage
    }
    
    func makeUIView(context: Context) -> WKWebView {
        self.webView.configuration.userContentController.add(context.coordinator, name: "print")
        self.webView.uiDelegate = context.coordinator
        self.webView.navigationDelegate = context.coordinator
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.scrollView.isScrollEnabled = true
        self.webView.customUserAgent = "Clearly Reformed iOS App"
        
        self.webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        
#if DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, loadComplete: $loadComplete, presentToast: $presentToast, toastMessage: $toastMessage)
    }
    
    
    
}

extension WKWebViewRepresentable {
    
    final class Coordinator : NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: WKWebViewRepresentable
        @Binding var loadComplete: Bool
        @Binding var presentToast: Bool
        @Binding var toastMessage: String
        
        init(_ parent: WKWebViewRepresentable, loadComplete: Binding<Bool>, presentToast: Binding<Bool>, toastMessage: Binding<String>) {
            self.parent = parent
            self._loadComplete = loadComplete
            self._presentToast = presentToast
            self._toastMessage = toastMessage
        }
        
        // MARK: Intercept WKScriptMessages
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.body as! String == "print" {
                printPage()
            }
        }
        
        // MARK: Printing UI setup
        @objc func printPage() {
            let pInfo: UIPrintInfo = UIPrintInfo.printInfo()
            pInfo.outputType = UIPrintInfo.OutputType.general
            pInfo.jobName = parent.webView.title ?? "Unknown page title"
            pInfo.orientation = UIPrintInfo.Orientation.portrait
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = pInfo
            printController.printFormatter = parent.webView.viewPrintFormatter()
            printController.present(animated: true, completionHandler: nil)
        }
        
        // MARK: Estimated Page Load Progress
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress" {
                if parent.webView.estimatedProgress == 1 {
                    loadComplete = true
                }
            }
        }
        
        // MARK: Pull down to refresh webpage
        @objc func reloadWebView(_ sender: UIRefreshControl) {
            parent.webView.reload()
            sender.endRefreshing()
        }
        
        // MARK: Handle pop up requests
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                return nil
            }
            
            return nil
        }
        
        
        // MARK: Define Navigation Rules
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // if there is a url, unwrap it
            if let url = navigationAction.request.url {
                //print(navigationAction.request.url ?? "No Url Found")
                
                // define schemes we plan to handle
                enum URLSchemes: String {
                    case https, http, about, mailto
                }
                
                let scheme = url.scheme ?? "none"
                //print("Scheme: \(scheme)")
                
                
                
                
                
                // MARK: Handle Web URLs
                if scheme == URLSchemes.https.rawValue  || scheme == URLSchemes.http.rawValue {
                    let host = url.host() ?? "none"
                    //print("Host: \(host)")
                    
                    let allowedHosts = [
                        "clearlyreformed.org",
                        "www.youtube.com",
                        "player.vimeo.com",
                        "embed.podcasts.apple.com"
                    ]
                    
                    if allowedHosts.contains(host) {
                        print(host)
                        
                        if host == "www.youtube.com" {
                            if url.pathComponents.contains("embed") {
                                decisionHandler(.allow)
                                return
                            } else {
                                UIApplication.shared.open(navigationAction.request.url!)
                                decisionHandler(.cancel)
                                return
                            }
                        } else {
                            decisionHandler(.allow)
                            return
                        }
                        
                    } else {
                        UIApplication.shared.open(navigationAction.request.url!)
                        decisionHandler(.cancel)
                        return
                    }
                    
                    
                    
                    // MARK: Handle URLs with 'about' scheme
                } else if scheme == URLSchemes.about.rawValue {
                    decisionHandler(.allow)
                    return
                    
                    
                    // MARK: Handle Email URLs
                } else if scheme == URLSchemes.mailto.rawValue {
                    let email = url.absoluteString
                    if let emailURL = URL(string: email) {
                        
                        if UIApplication.shared.canOpenURL(emailURL) {
                            UIApplication.shared.open(emailURL)
                            decisionHandler(.cancel)
                            return
                        } else {
                            withAnimation {
                                toastMessage = "Unable to open mail app"
                                presentToast = true
                            }
                            decisionHandler(.cancel)
                            return
                        }
                        
                    } else {
                        decisionHandler(.cancel)
                        return
                    }
                    
                    
                    // MARK: Handle all other cases
                } else {
                    decisionHandler(.allow)
                }
            }
        }
    }
}

