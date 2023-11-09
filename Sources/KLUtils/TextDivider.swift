//
//  SwiftUIView.swift
//  
//
//  Created by Kilo Loco on 11/8/23.
//

import SwiftUI

public struct TextDivider: View {
    private let text: LocalizedStringKey
    
    public init(text: LocalizedStringKey) {
        self.text = text
    }
    
    public var body: some View {
        HStack {
            Color.systemForeground
                .frame(height: 0.5)
            
            Text(text)
            
            Color.systemForeground
                .frame(height: 0.5)
        }
    }
}

#Preview {
    TextDivider(text: "Divider")
}
