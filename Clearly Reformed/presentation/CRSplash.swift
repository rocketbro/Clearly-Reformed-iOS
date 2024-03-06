//
//  CRSplash.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import SwiftUI
import AVKit

struct CRSplash: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var logoOpacity: Double = 0
    @State private var player = AVPlayer(url: Bundle.main.url(forResource: "cr_logo_ring_hevc", withExtension: "mov")!)
    
    var baseSize: CGFloat {
        if sizeClass == .compact {
            return 90
        } else {
            return 130
        }
    }
    
    var body: some View {
        ZStack {
            primaryGreen.ignoresSafeArea()
            Image("lake_lucerne_cropped")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.25)
                .zIndex(1)
            
            VStack(spacing: baseSize * 0.28) {
                VideoPlayer(player: player)
                    .frame(width: baseSize, height: baseSize)
                    .blendMode(.screen)
                    .onAppear {
                        player.play()
                    }
                Image("cr-logotype-white")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: baseSize * 3)
                    .opacity(logoOpacity)
            }.padding(.bottom, baseSize)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.6)) { logoOpacity = 1 }
            }
        }
    }
}

#Preview {
    CRSplash()
}
