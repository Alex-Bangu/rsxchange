
import SwiftUI

struct NavigationBarTitleColorModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .onAppear(perform: setupAppearance)
            .onChange(of: colorScheme) { _ in setupAppearance() }
    }

    private func setupAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0) // Blue header background
        
        // Set title text color dynamically
        appearance.titleTextAttributes = [.foregroundColor: colorScheme == .dark ? UIColor.black : UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: colorScheme == .dark ? UIColor.black : UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension View {
    func navigationBarTitleColor() -> some View {
        self.modifier(NavigationBarTitleColorModifier())
    }
}
