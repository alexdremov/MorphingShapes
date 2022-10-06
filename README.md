# MorphingShapes

Code for https://alexdremov.me/swiftui-advanced-animation/

Added support for optional outline


https://user-images.githubusercontent.com/25539425/184550942-bb9cc1da-5916-42be-8342-883f200e2cbd.mov

```swift
import SwiftUI
import MorphingShapes

struct ContentView: View {
    var body: some View {
        VStack {
            // added support for optional outline:
            MorphingCircle(outlineColor: .orange, outlineWidth: 10.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```
