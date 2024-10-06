/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The SwiftUI app for iOS.
*/

import SwiftUI

@main
struct MirroringWorkoutsSampleApp: App {
    private let workoutManager = WorkoutManager.shared
    @StateObject private var globalState = GlobalState()

    var body: some Scene {
        WindowGroup {
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                
                StartView()
                    .environmentObject(workoutManager)
                    .environmentObject(globalState) // Make it available to the entire view hierarchy
                
            } else {
                WorkoutListView()
            }
        }
    }
}
