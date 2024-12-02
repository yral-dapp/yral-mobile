import SwiftUI
import Firebase

@main
struct IosApp: App {
  init () {
    FirebaseApp.configure()
  }

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
