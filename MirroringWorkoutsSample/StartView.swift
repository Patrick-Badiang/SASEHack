/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A SwiftUI view that shows a button to start the watchOS app.
*/

import os
import SwiftUI
import HealthKitUI
import HealthKit

// Color extension for hex color support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 4) & 0xF0F, (int >> 4) & 0xF0F, int & 0xF0F)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct StartView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var isFullScreenCoverActive = false
    @State private var didStartWorkout = false
    @State private var triggerAuthorization = false

    var body: some View {
        /**
         Is the view that is on start up, is the 'home'
         */
        
        NavigationStack {
        
                VStack {
                    Button {
                        if !workoutManager.sessionState.isActive {
                            startCyclingOnWatch()
                        }
                        didStartWorkout = true
                    } label: {
                        let title = workoutManager.sessionState.isActive ? "View ongoing workout" : "Start Workout"
                        ButtonLabel(title: title, systemImage: "figure.outdoor.cycle")
                            .frame(width: 150, height: 150)
                            .fontWeight(.medium)
                    }
                    .clipShape(Circle())
                    .overlay {
                        Circle().stroke(.white, lineWidth: 4)
                    }
                    .shadow(radius: 7)
                    .buttonStyle(.bordered)
                    .tint(Color(hex: "B7BD9E"))
                    .foregroundColor(.black)
                    .frame(width: 400, height: 400)
                    
                }
                .onAppear() {
                    triggerAuthorization.toggle()
                    workoutManager.retrieveRemoteSession()
                }
                .healthDataAccessRequest(store: workoutManager.healthStore,
                                         shareTypes: workoutManager.typesToShare,
                                         readTypes: workoutManager.typesToRead,
                                         trigger: triggerAuthorization, completion: { result in
                    switch result {
                    case .success(let success):
                        print("\(success) for authorization")
                    case .failure(let error):
                        print("\(error) for authorization")
                    }
                })
                .navigationDestination(isPresented: $didStartWorkout) {
                    MirroringWorkoutView()
                }
                .navigationBarTitle("Workout for the day")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            isFullScreenCoverActive = true
                        } label: {
                            Label("Workout list", systemImage: "list.bullet.below.rectangle")
                        }
                    }
                }
                .fullScreenCover(isPresented: $isFullScreenCoverActive) {
                    WorkoutListView()
                }
            
        }
    }
        
    private func startCyclingOnWatch() {
        Task {
            do {
                try await workoutManager.startWatchWorkout(workoutType: .cycling)
            } catch {
                Logger.shared.log("Failed to start cycling on the paired watch.")
            }
        }
        
    }
}
