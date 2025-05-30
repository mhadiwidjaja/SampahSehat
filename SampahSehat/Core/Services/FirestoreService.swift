//
//  FirestoreService.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()
    
    // Dummy data for testing
    private let dummySchedules: [PickupSchedule] = [
        PickupSchedule(
            scheduleId: "schedule1",
            areaInfo: "Blok A - Jl. Sudirman",
            pickupDate: "2025-05-30",
            status: "Pending",
            assignedCollectorId: "collector123"
        ),
        PickupSchedule(
            scheduleId: "schedule2",
            areaInfo: "Blok B - Jl. Thamrin",
            pickupDate: "2025-05-30",
            status: "Pending",
            assignedCollectorId: "collector123"
        ),
        PickupSchedule(
            scheduleId: "schedule3",
            areaInfo: "Blok C - Jl. Gatot Subroto",
            pickupDate: "2025-05-30",
            status: "Completed",
            assignedCollectorId: "collector123"
        ),
        PickupSchedule(
            scheduleId: "schedule4",
            areaInfo: "Blok D - Jl. Rasuna Said",
            pickupDate: "2025-05-30",
            status: "Pending",
            assignedCollectorId: "collector123"
        )
    ]
    
    private var currentSchedules: [PickupSchedule] = []

    func getUser(userId: String) async -> User? {
        // Return dummy collector user
        if userId == "collector123" {
            return User(
                userId: "collector123",
                email: "collector@test.com",
                locationInfo: "Jakarta Area",
                role: "Collector"
            )
        }
        return nil
    }
    
    func getScheduleForArea(areaInfo: String, date: Date) async -> PickupSchedule? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return currentSchedules.first { schedule in
            schedule.areaInfo == areaInfo && schedule.pickupDate == dateString
        }
    }

    func getSchedulesForCollector(collectorId: String, date: Date) async -> [PickupSchedule] {
        // Initialize dummy data if needed
        if currentSchedules.isEmpty {
            currentSchedules = dummySchedules
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return currentSchedules.filter { schedule in
            schedule.assignedCollectorId == collectorId && schedule.pickupDate == dateString
        }
    }

    func updateScheduleStatus(scheduleId: String, status: String) async -> Bool {
        // Initialize dummy data if needed
        if currentSchedules.isEmpty {
            currentSchedules = dummySchedules
        }
        
        if let index = currentSchedules.firstIndex(where: { $0.scheduleId == scheduleId }) {
            currentSchedules[index].status = status
            print("Updated schedule \(scheduleId) to status: \(status)")
            return true
        }
        return false
    }
}
