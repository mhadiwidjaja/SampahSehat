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
        guard let collectorId = authService.getCurrentUserAuthId() else {
            updateError = "Collector not logged in."
            return
        }

        isLoading = true
        updateError = nil
        
        Task {
            let schedules = await firestoreService.getSchedulesForCollector(collectorId: collectorId, date: Date())
            
            // Update UI on main thread
            await MainActor.run {
                self.todaysSchedule = schedules
                self.isLoading = false
                
                if schedules.isEmpty {
                    self.updateError = "No schedules found for today."
                } else {
                    self.updateError = nil
                }
            }
        }
    }

    func markScheduleCompleted(scheduleId: String) {
        updateError = nil
        Task {
            let success = await firestoreService.updateScheduleStatus(scheduleId: scheduleId, status: "Completed")
            await MainActor.run {
                if success {
                    if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                        todaysSchedule[index].status = "Completed"
                        todaysSchedule[index].timestamp = getCurrentTimestamp()
                    }
                } else {
                    updateError = "Failed to mark as completed. Please try again."
                }
            }
        }
    }

    func markScheduleMissed(scheduleId: String, reason: String) {
        updateError = nil
        Task {
            let success = await firestoreService.updateScheduleStatus(scheduleId: scheduleId, status: "Missed", reason: reason)
            await MainActor.run {
                if success {
                    if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                        todaysSchedule[index].status = "Missed"
                        todaysSchedule[index].reason = reason
                        todaysSchedule[index].timestamp = getCurrentTimestamp()
                    }
                } else {
                    updateError = "Failed to mark as missed. Please try again."
                }
            }
        }
    }
    
    func markScheduleOnHold(scheduleId: String, reason: String) {
        updateError = nil
        Task {
            let success = await firestoreService.markScheduleOnHold(scheduleId: scheduleId, reason: reason)
            await MainActor.run {
                if success {
                    if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                        todaysSchedule[index].status = "On Hold"
                        todaysSchedule[index].reason = reason
                        todaysSchedule[index].timestamp = getCurrentTimestamp()
                    }
                } else {
                    updateError = "Failed to mark as on hold. Please try again."
                }
            }
        }
    }
    
    private func getCurrentTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: Date())
    }
}
