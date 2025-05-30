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
    private var authService = FirebaseAuthService.shared

    @Published var todaysSchedule: [PickupSchedule] = []
    @Published var isLoading: Bool = false
    @Published var updateError: String? = nil
    @Published var pendingUpdatesCount: Int = 0

    func loadTodaysSchedule() {
        guard let collectorId = authService.getCurrentUserAuthId() else {
            updateError = "Collector not logged in."
            return
        }

        isLoading = true
        updateError = nil
        
        Task {
            // Try to sync any pending updates first
            await firestoreService.syncPendingUpdates()
            
            // Load schedules
            let schedules = await firestoreService.getSchedulesForCollector(collectorId: collectorId, date: Date())
            
            // Update UI on main thread
            await MainActor.run {
                self.todaysSchedule = schedules
                self.isLoading = false
                self.pendingUpdatesCount = firestoreService.getPendingUpdatesCount()
                
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
                    self.pendingUpdatesCount = firestoreService.getPendingUpdatesCount()
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
                    self.pendingUpdatesCount = firestoreService.getPendingUpdatesCount()
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
                    self.pendingUpdatesCount = firestoreService.getPendingUpdatesCount()
                } else {
                    updateError = "Failed to mark as on hold. Please try again."
                }
            }
        }
    }
    
    func syncPendingUpdates() {
        Task {
            await firestoreService.syncPendingUpdates()
            await MainActor.run {
                self.pendingUpdatesCount = firestoreService.getPendingUpdatesCount()
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
