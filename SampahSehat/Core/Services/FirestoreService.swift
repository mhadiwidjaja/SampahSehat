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
    
    // Store the schedules persistently during the session
    private var currentSchedules: [PickupSchedule] = []
    private var hasInitialized = false
    
    // Function to get today's date string
    private func getTodaysDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    // Generate dummy schedules with today's date dynamically - only once
    private func initializeDummySchedules() {
        // Only initialize once per session
        if hasInitialized && !currentSchedules.isEmpty {
            print("📋 Using existing schedules - not regenerating")
            return
        }
        
        let todayString = getTodaysDateString()
        print("📅 Initializing schedules for date: \(todayString)")
        
        currentSchedules = [
            PickupSchedule(
                scheduleId: "schedule1",
                areaInfo: "Blok A - Jl. Sudirman",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            ),
            PickupSchedule(
                scheduleId: "schedule2",
                areaInfo: "Blok B - Jl. Thamrin",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            ),
            PickupSchedule(
                scheduleId: "schedule3",
                areaInfo: "Blok C - Jl. Gatot Subroto",
                pickupDate: todayString,
                status: "Completed",
                assignedCollectorId: "collector123"
            ),
            PickupSchedule(
                scheduleId: "schedule4",
                areaInfo: "Blok D - Jl. Rasuna Said",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            ),
            PickupSchedule(
                scheduleId: "schedule5",
                areaInfo: "Blok E - Jl. Kuningan",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            )
        ]
        
        hasInitialized = true
        print("✅ Initialized \(currentSchedules.count) schedules")
    }

    func getUser(userId: String) async -> User? {
        print("👤 Getting user with ID: \(userId)")
        // Return dummy collector user
        if userId == "collector123" {
            return User(
                userId: "collector123",
                email: "collector@test.com",
                locationInfo: "Jakarta Area",
                role: "Collector"
            )
        }
        print("❌ No user found for ID: \(userId)")
        return nil
    }
    
    func getScheduleForArea(areaInfo: String, date: Date) async -> PickupSchedule? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Initialize only if needed
        initializeDummySchedules()
        
        return currentSchedules.first { schedule in
            schedule.areaInfo == areaInfo && schedule.pickupDate == dateString
        }
    }

    func getSchedulesForCollector(collectorId: String, date: Date) async -> [PickupSchedule] {
        print("📋 Getting schedules for collector: \(collectorId)")
        
        // Initialize dummy data only once
        initializeDummySchedules()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        print("📅 Looking for schedules on date: \(dateString)")
        print("📊 Total available schedules: \(currentSchedules.count)")
        
        // Print current status of each schedule
        for schedule in currentSchedules {
            print("📝 Schedule: \(schedule.scheduleId) - \(schedule.areaInfo) - Status: \(schedule.status) - Date: \(schedule.pickupDate) - Collector: \(schedule.assignedCollectorId)")
        }
        
        let filteredSchedules = currentSchedules.filter { schedule in
            let collectorMatch = schedule.assignedCollectorId == collectorId
            let dateMatch = schedule.pickupDate == dateString
            print("🔍 Checking schedule \(schedule.scheduleId): collector(\(schedule.assignedCollectorId) == \(collectorId)) = \(collectorMatch), date(\(schedule.pickupDate) == \(dateString)) = \(dateMatch)")
            return collectorMatch && dateMatch
        }
        
        print("✅ Found \(filteredSchedules.count) matching schedules for collector \(collectorId)")
        return filteredSchedules
    }

    func updateScheduleStatus(scheduleId: String, status: String) async -> Bool {
        print("🔄 Updating schedule \(scheduleId) to status: \(status)")
        
        // Make sure we have initialized data
        initializeDummySchedules()
        
        if let index = currentSchedules.firstIndex(where: { $0.scheduleId == scheduleId }) {
            let oldStatus = currentSchedules[index].status
            currentSchedules[index].status = status
            print("✅ Updated schedule \(scheduleId) from status '\(oldStatus)' to '\(status)'")
            
            // Print all schedules to verify the update
            print("📋 Current schedule statuses after update:")
            for schedule in currentSchedules {
                print("   \(schedule.scheduleId): \(schedule.status)")
            }
            
            return true
        }
        print("❌ Failed to find schedule with ID: \(scheduleId)")
        return false
    }
    
    // Optional: Method to reset all schedules (for testing)
    func resetSchedules() {
        print("🔄 Resetting all schedules to original state")
        hasInitialized = false
        currentSchedules = []
        initializeDummySchedules()
    }
}
