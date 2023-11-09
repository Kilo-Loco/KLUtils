import SwiftUI

public struct BackgroundView<Content: View>: View {
    private let color: Color
    private let content: (() -> Content)
    
    public init(color: Color = Color(uiColor: .secondarySystemBackground), content: @escaping (() -> Content)) {
        self.color = color
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            color.ignoresSafeArea()
            content()
        }
    }
}

#Preview {
    BackgroundView {
        Text("hello world")
    }
}
