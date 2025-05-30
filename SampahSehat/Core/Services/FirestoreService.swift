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
    
    // Use UserDefaults to persist schedules across app sessions
    private let userDefaults = UserDefaults.standard
    private let schedulesKey = "saved_schedules"
    private let initializationKey = "schedules_initialized"
    
    // Function to get today's date string
    private func getTodaysDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    // Function to get current timestamp
    private func getCurrentTimestamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: Date())
    }
    
    // Load schedules from UserDefaults
    private func loadSchedulesFromStorage() -> [PickupSchedule] {
        guard let data = userDefaults.data(forKey: schedulesKey),
              let schedules = try? JSONDecoder().decode([PickupSchedule].self, from: data) else {
            return []
        }
        return schedules
    }
    
    // Save schedules to UserDefaults
    private func saveSchedulesToStorage(_ schedules: [PickupSchedule]) {
        if let data = try? JSONEncoder().encode(schedules) {
            userDefaults.set(data, forKey: schedulesKey)
        }
    }
    
    // Check if schedules have been initialized for today
    private func hasBeenInitializedToday() -> Bool {
        let savedDate = userDefaults.string(forKey: initializationKey)
        let todayString = getTodaysDateString()
        return savedDate == todayString
    }
    
    // Mark schedules as initialized for today
    private func markInitializedForToday() {
        let todayString = getTodaysDateString()
        userDefaults.set(todayString, forKey: initializationKey)
    }
    
    // Generate dummy schedules with today's date dynamically - only once per day
    private func initializeDummySchedules() -> [PickupSchedule] {
        // Check if we already have schedules for today
        if hasBeenInitializedToday() {
            let savedSchedules = loadSchedulesFromStorage()
            if !savedSchedules.isEmpty {
                return savedSchedules
            }
        }
        
        // Create fresh schedules for today
        let todayString = getTodaysDateString()
        
        let newSchedules = [
            PickupSchedule(
                scheduleId: "test_sched_001",
                areaInfo: "Blok A - Jl. Sudirman",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            ),
            PickupSchedule(
                scheduleId: "test_sched_002",
                areaInfo: "Blok B - Jl. Thamrin",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            ),
            PickupSchedule(
                scheduleId: "test_sched_003",
                areaInfo: "Blok C - Jl. Gatot Subroto",
                pickupDate: todayString,
                status: "Completed",
                assignedCollectorId: "collector123",
                timestamp: getCurrentTimestamp()
            ),
            PickupSchedule(
                scheduleId: "test_sched_004",
                areaInfo: "Blok D - Jl. Rasuna Said",
                pickupDate: todayString,
                status: "On Hold",
                assignedCollectorId: "collector123",
                reason: "Road blocked",
                timestamp: getCurrentTimestamp()
            ),
            PickupSchedule(
                scheduleId: "test_sched_005",
                areaInfo: "Blok E - Jl. Kuningan",
                pickupDate: todayString,
                status: "Pending",
                assignedCollectorId: "collector123"
            )
        ]
        
        // Save to storage and mark as initialized
        saveSchedulesToStorage(newSchedules)
        markInitializedForToday()
        
        return newSchedules
    }

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
        
        let schedules = initializeDummySchedules()
        
        return schedules.first { schedule in
            schedule.areaInfo == areaInfo && schedule.pickupDate == dateString
        }
    }

    func getSchedulesForCollector(collectorId: String, date: Date) async -> [PickupSchedule] {
        let schedules = initializeDummySchedules()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let filteredSchedules = schedules.filter { schedule in
            let collectorMatch = schedule.assignedCollectorId == collectorId
            let dateMatch = schedule.pickupDate == dateString
            return collectorMatch && dateMatch
        }
        
        return filteredSchedules
    }

    func updateScheduleStatus(scheduleId: String, status: String, reason: String? = nil) async -> Bool {
        var schedules = initializeDummySchedules()
        
        if let index = schedules.firstIndex(where: { $0.scheduleId == scheduleId }) {
            schedules[index].status = status
            schedules[index].reason = reason
            schedules[index].timestamp = getCurrentTimestamp()
            
            // Save updated schedules back to storage
            saveSchedulesToStorage(schedules)
            
            return true
        }
        return false
    }
    
    // New method for marking as "On Hold"
    func markScheduleOnHold(scheduleId: String, reason: String) async -> Bool {
        return await updateScheduleStatus(scheduleId: scheduleId, status: "On Hold", reason: reason)
    }
    
    // Optional: Method to reset all schedules (for testing)
    func resetSchedules() {
        userDefaults.removeObject(forKey: schedulesKey)
        userDefaults.removeObject(forKey: initializationKey)
    }
    
    // Optional: Method to clear schedules for a new day (call this when date changes)
    func clearSchedulesForNewDay() {
        if !hasBeenInitializedToday() {
            userDefaults.removeObject(forKey: schedulesKey)
            userDefaults.removeObject(forKey: initializationKey)
        }
    }
}
