//
//  CollectorViewModel.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

@MainActor
class CollectorViewModel: ObservableObject {
    private var firestoreService = FirestoreService()
    // Use shared instance instead of creating new one
    private var authService = FirebaseAuthService.shared

    @Published var todaysSchedule: [PickupSchedule] = []
    @Published var isLoading: Bool = false
    @Published var updateError: String? = nil

    func loadTodaysSchedule() {
        print("🚀 CollectorViewModel: Starting to load today's schedule")
        
        guard let collectorId = authService.getCurrentUserAuthId() else {
            print("❌ No collector ID found from auth service")
            updateError = "Collector not logged in."
            return
        }

        print("👤 Loading schedule for collector: \(collectorId)")
        isLoading = true
        updateError = nil
        
        Task {
            print("📞 Calling firestoreService.getSchedulesForCollector...")
            let schedules = await firestoreService.getSchedulesForCollector(collectorId: collectorId, date: Date())
            print("📨 Received \(schedules.count) schedules from service")
            
            // Update UI on main thread
            await MainActor.run {
                self.todaysSchedule = schedules
                self.isLoading = false
                
                if schedules.isEmpty {
                    self.updateError = "No schedules found for today."
                    print("❌ No schedules found - setting error message")
                } else {
                    self.updateError = nil
                    print("✅ Successfully loaded \(schedules.count) schedules")
                }
            }
            
            // Print each schedule for debugging
            for schedule in schedules {
                print("📋 Loaded schedule: \(schedule.areaInfo) - \(schedule.status)")
            }
        }
    }

    func markScheduleCompleted(scheduleId: String) {
        print("✅ Marking schedule \(scheduleId) as completed")
        updateError = nil
        Task {
            let success = await firestoreService.updateScheduleStatus(scheduleId: scheduleId, status: "Completed")
            await MainActor.run {
                if success {
                    if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                        todaysSchedule[index].status = "Completed"
                        print("✅ UI updated for completed schedule")
                    }
                } else {
                    updateError = "Failed to mark as completed. Please try again."
                    print("❌ Failed to mark schedule as completed")
                }
            }
        }
    }

    func markScheduleMissed(scheduleId: String) {
        print("❌ Marking schedule \(scheduleId) as missed")
        updateError = nil
        Task {
            let success = await firestoreService.updateScheduleStatus(scheduleId: scheduleId, status: "Missed")
            await MainActor.run {
                if success {
                    if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                        todaysSchedule[index].status = "Missed"
                        print("✅ UI updated for missed schedule")
                    }
                } else {
                    updateError = "Failed to mark as missed. Please try again."
                    print("❌ Failed to mark schedule as missed")
                }
            }
        }
    }
}
