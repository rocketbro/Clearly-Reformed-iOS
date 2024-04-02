//
//  ContentView.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import SwiftUI

struct ContentView: View {
    @State private var nav = Navigation()
    @Environment(NetworkMonitor.self) private var networkMonitor
    @State private var webView: WKWebViewRepresentable? = nil
    @State private var loadComplete = false
    @State private var presentToast = false
    @State private var toastMessage = ""
    @State private var hideStatusBar = true
    
    var body: some View {
        setContent()
    }
    
    @ViewBuilder
    func setContent() -> some View {
        switch nav.route {
        case .splash:
            CRSplash()
                .statusBarHidden(hideStatusBar)
                .onAppear {
                    loadWebViewContent()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            nav.route = .webpage
                        }
                    }
                }
        case .webpage:
            ZStack {
                Color.white
                    .ignoresSafeArea()
                if webView != nil {
                    webView
                        .edgesIgnoringSafeArea([.horizontal, .bottom])
                        .zIndex(1)
                        .statusBarHidden(hideStatusBar)
                        .onAppear {
                            withAnimation {
                                hideStatusBar.toggle()
                            }
                        }
                }
                
                
                /* This code causes issues on some devices; the loadComplete variable doesn't
                 seem to consistently publish its current value.
                 
                 if !loadComplete {
                 withAnimation {
                 VStack(spacing: 8) {
                 ProgressView()
                 .foregroundColor(Color.gray)
                 Text("Loading...")
                 .foregroundStyle(Color.gray)
                 .font(.caption)
                 }
                 .zIndex(2)
                 }
                 }
                 
                 */
                
                VStack {
                    Spacer()
                    ToastView(isPresented: $presentToast, message: $toastMessage)
                }.zIndex(3)
                
                
                if !networkMonitor.isConnected {
                    withAnimation {
                        ZStack {
                            primaryGreen.ignoresSafeArea()
                            VStack {
                                Image(systemName: "wifi.exclamationmark")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .padding()
                                Text("Cannot connect to the internet.\nPlease check your connection.")
                            }
                            .foregroundColor(.white)
                            .padding(.bottom, 100)
                        }
                        .transition(.opacity)
                        .zIndex(4)
                        .onChange(of: networkMonitor.isConnected) {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                loadWebViewContent()
//                            }
                            loadWebViewContent()
                        }
                    }
                }
            }
        }
    }
    
    func loadWebViewContent() {
        webView = WKWebViewRepresentable(
            url: URL(string: "https://clearlyreformed.org")!,
            loadComplete: $loadComplete,
            presentToast: $presentToast,
            toastMessage: $toastMessage
        )
    }
}

#Preview {
    ContentView()
}
