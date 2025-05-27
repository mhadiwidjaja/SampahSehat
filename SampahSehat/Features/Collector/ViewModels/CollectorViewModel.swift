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
    private var authService = FirebaseAuthService()

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
            self.todaysSchedule = await firestoreService.getSchedulesForCollector(collectorId: collectorId, date: Date())
            isLoading = false
        }
    }

    func markScheduleCompleted(scheduleId: String) {
        updateError = nil
        Task {
            let success = await firestoreService.updateScheduleStatus(scheduleId: scheduleId, status: "Completed")
            if success {
                if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                    todaysSchedule[index].status = "Completed"
                }
            } else {
                updateError = "Failed to mark as completed. Please try again."
            }
        }
    }

    func markScheduleMissed(scheduleId: String) {
        updateError = nil
        Task {
            let success = await firestoreService.updateScheduleStatus(scheduleId: scheduleId, status: "Missed")
            if success {
                if let index = todaysSchedule.firstIndex(where: { $0.scheduleId == scheduleId }) {
                    todaysSchedule[index].status = "Missed"
                }
            } else {
                updateError = "Failed to mark as missed. Please try again."
            }
        }
    }
}
