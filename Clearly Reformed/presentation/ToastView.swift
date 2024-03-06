//
//  ToastView.swift
//  Clearly Reformed
//
//  Created by Asher Pope on 3/6/24.
//

import SwiftUI

struct ToastView: View {
    @Binding var isPresented: Bool
    @Binding var message: String
    
    var body: some View {
        if isPresented {
            Text(message)
                .font(.body)
                .foregroundStyle(primaryGreen)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(28)
                .shadow(color: Color.black.opacity(0.2), radius: 10, y: CGFloat(6))
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
        }
    }
}
