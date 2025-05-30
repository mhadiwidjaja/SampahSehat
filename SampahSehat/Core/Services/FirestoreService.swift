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
    
    // Collection references
    private let usersCollection = "users"
    private let schedulesCollection = "pickup_schedules"
    
    // Use UserDefaults as backup for offline scenarios
    private let userDefaults = UserDefaults.standard
    private let schedulesKey = "cached_schedules"
    private let initializationKey = "schedules_initialized_date"
    
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
    
    // MARK: - Initialize Dummy Data in Firestore
    func initializeDummyDataInFirestore() async {
        let todayString = getTodaysDateString()
        
        // Check if already initialized for today
        if await hasBeenInitializedInFirestore(date: todayString) {
            return
        }
        
        // Create dummy user if not exists
        await createDummyUser()
        
        // Create dummy schedules for today
        await createDummySchedules(date: todayString)
        
        // Mark as initialized
        await markInitializedInFirestore(date: todayString)
    }
    
    private func createDummyUser() async {
        do {
            let userRef = db.collection(usersCollection).document("collector123")
            
            // Check if user already exists
            let userDoc = try await userRef.getDocument()
            if userDoc.exists {
                return
            }
            
            // Create user document
            let userData: [String: Any] = [
                "userId": "collector123",
                "email": "collector@test.com",
                "locationInfo": "Jakarta Area",
                "role": "Collector",
                "createdAt": getCurrentTimestamp()
            ]
            
            try await userRef.setData(userData)
            print("✅ Created dummy user in Firestore")
        } catch {
            print("❌ Error creating dummy user: \(error)")
        }
    }
    
    private func createDummySchedules(date: String) async {
        let dummySchedules = [
            [
                "scheduleId": "test_sched_001",
                "areaInfo": "Blok A - Jl. Sudirman",
                "pickupDate": date,
                "status": "Pending",
                "assignedCollectorId": "collector123",
                "createdAt": getCurrentTimestamp()
            ],
            [
                "scheduleId": "test_sched_002",
                "areaInfo": "Blok B - Jl. Thamrin",
                "pickupDate": date,
                "status": "Pending",
                "assignedCollectorId": "collector123",
                "createdAt": getCurrentTimestamp()
            ],
            [
                "scheduleId": "test_sched_003",
                "areaInfo": "Blok C - Jl. Gatot Subroto",
                "pickupDate": date,
                "status": "Completed",
                "assignedCollectorId": "collector123",
                "timestamp": getCurrentTimestamp(),
                "createdAt": getCurrentTimestamp()
            ],
            [
                "scheduleId": "test_sched_004",
                "areaInfo": "Blok D - Jl. Rasuna Said",
                "pickupDate": date,
                "status": "On Hold",
                "assignedCollectorId": "collector123",
                "reason": "Road blocked",
                "timestamp": getCurrentTimestamp(),
                "createdAt": getCurrentTimestamp()
            ],
            [
                "scheduleId": "test_sched_005",
                "areaInfo": "Blok E - Jl. Kuningan",
                "pickupDate": date,
                "status": "Pending",
                "assignedCollectorId": "collector123",
                "createdAt": getCurrentTimestamp()
            ]
        ]
        
        do {
            for scheduleData in dummySchedules {
                let scheduleId = scheduleData["scheduleId"] as! String
                let docRef = db.collection(schedulesCollection).document(scheduleId)
                try await docRef.setData(scheduleData)
            }
            print("✅ Created \(dummySchedules.count) dummy schedules in Firestore")
        } catch {
            print("❌ Error creating dummy schedules: \(error)")
        }
    }
    
    private func hasBeenInitializedInFirestore(date: String) async -> Bool {
        do {
            let snapshot = try await db.collection(schedulesCollection)
                .whereField("pickupDate", isEqualTo: date)
                .whereField("assignedCollectorId", isEqualTo: "collector123")
                .limit(to: 1)
                .getDocuments()
            
            return !snapshot.isEmpty
        } catch {
            print("❌ Error checking initialization: \(error)")
            return false
        }
    }
    
    private func markInitializedInFirestore(date: String) async {
        userDefaults.set(date, forKey: initializationKey)
    }
    
    // MARK: - User Methods
    func getUser(userId: String) async -> User? {
        do {
            let document = try await db.collection(usersCollection).document(userId).getDocument()
            
            if document.exists, let data = document.data() {
                return User(
                    userId: data["userId"] as? String ?? userId,
                    email: data["email"] as? String ?? "",
                    locationInfo: data["locationInfo"] as? String ?? "",
                    role: data["role"] as? String ?? ""
                )
            }
        } catch {
            print("❌ Error fetching user: \(error)")
        }
        
        // Fallback to dummy data
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
    
    // MARK: - Schedule Methods
    func getSchedulesForCollector(collectorId: String, date: Date) async -> [PickupSchedule] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // First, try to initialize dummy data if needed
        await initializeDummyDataInFirestore()
        
        do {
            // Try to fetch from Firestore (online)
            let snapshot = try await db.collection(schedulesCollection)
                .whereField("assignedCollectorId", isEqualTo: collectorId)
                .whereField("pickupDate", isEqualTo: dateString)
                .getDocuments()
            
            let schedules = snapshot.documents.compactMap { doc -> PickupSchedule? in
                let data = doc.data()
                return PickupSchedule(
                    scheduleId: data["scheduleId"] as? String ?? doc.documentID,
                    areaInfo: data["areaInfo"] as? String ?? "",
                    pickupDate: data["pickupDate"] as? String ?? dateString,
                    status: data["status"] as? String ?? "Pending",
                    assignedCollectorId: data["assignedCollectorId"] as? String ?? collectorId,
                    reason: data["reason"] as? String,
                    timestamp: data["timestamp"] as? String
                )
            }
            
            // Cache the schedules locally for offline use
            cacheSchedules(schedules)
            
            print("✅ Fetched \(schedules.count) schedules from Firestore")
            return schedules
            
        } catch {
            print("❌ Error fetching schedules from Firestore: \(error)")
            print("🔄 Falling back to cached data...")
            
            // Fallback to cached data (offline mode)
            return getCachedSchedules(collectorId: collectorId, date: dateString)
        }
    }
    
    func updateScheduleStatus(scheduleId: String, status: String, reason: String? = nil) async -> Bool {
        let timestamp = getCurrentTimestamp()
        
        do {
            // Prepare update data
            var updateData: [String: Any] = [
                "status": status,
                "timestamp": timestamp,
                "lastModified": timestamp
            ]
            
            if let reason = reason {
                updateData["reason"] = reason
            }
            
            // Try to update in Firestore (online)
            try await db.collection(schedulesCollection).document(scheduleId).updateData(updateData)
            
            // Also update cached data
            updateCachedSchedule(scheduleId: scheduleId, status: status, reason: reason, timestamp: timestamp)
            
            print("✅ Updated schedule \(scheduleId) to \(status) in Firestore")
            return true
            
        } catch {
            print("❌ Error updating schedule in Firestore: \(error)")
            print("🔄 Updating locally for offline sync...")
            
            // Update locally for offline sync
            let success = updateCachedSchedule(scheduleId: scheduleId, status: status, reason: reason, timestamp: timestamp)
            
            // Store pending update for later sync
            if success {
                storePendingUpdate(scheduleId: scheduleId, status: status, reason: reason, timestamp: timestamp)
            }
            
            return success
        }
    }
    
    // MARK: - Caching Methods
    private func cacheSchedules(_ schedules: [PickupSchedule]) {
        if let data = try? JSONEncoder().encode(schedules) {
            userDefaults.set(data, forKey: schedulesKey)
        }
    }
    
    private func getCachedSchedules(collectorId: String, date: String) -> [PickupSchedule] {
        guard let data = userDefaults.data(forKey: schedulesKey),
              let schedules = try? JSONDecoder().decode([PickupSchedule].self, from: data) else {
            return []
        }
        
        return schedules.filter { schedule in
            schedule.assignedCollectorId == collectorId && schedule.pickupDate == date
        }
    }
    
    private func updateCachedSchedule(scheduleId: String, status: String, reason: String?, timestamp: String) -> Bool {
        guard let data = userDefaults.data(forKey: schedulesKey),
              var schedules = try? JSONDecoder().decode([PickupSchedule].self, from: data) else {
            return false
        }
        
        if let index = schedules.firstIndex(where: { $0.scheduleId == scheduleId }) {
            schedules[index].status = status
            schedules[index].reason = reason
            schedules[index].timestamp = timestamp
            
            cacheSchedules(schedules)
            return true
        }
        
        return false
    }
    
    // MARK: - Offline Sync Methods
    private func storePendingUpdate(scheduleId: String, status: String, reason: String?, timestamp: String) {
        let pendingUpdate: [String: Any] = [
            "scheduleId": scheduleId,
            "status": status,
            "reason": reason ?? NSNull(),
            "timestamp": timestamp,
            "pendingSince": getCurrentTimestamp()
        ]
        
        var pendingUpdates = userDefaults.array(forKey: "pending_updates") as? [[String: Any]] ?? []
        pendingUpdates.append(pendingUpdate)
        userDefaults.set(pendingUpdates, forKey: "pending_updates")
        
        print("📤 Stored pending update for schedule \(scheduleId)")
    }
    
    func syncPendingUpdates() async {
        let pendingUpdates = userDefaults.array(forKey: "pending_updates") as? [[String: Any]] ?? []
        
        if pendingUpdates.isEmpty {
            return
        }
        
        print("🔄 Syncing \(pendingUpdates.count) pending updates...")
        
        var successfulUpdates: [Int] = []
        
        for (index, update) in pendingUpdates.enumerated() {
            guard let scheduleId = update["scheduleId"] as? String,
                  let status = update["status"] as? String,
                  let timestamp = update["timestamp"] as? String else {
                continue
            }
            
            let reason = update["reason"] as? String
            
            do {
                var updateData: [String: Any] = [
                    "status": status,
                    "timestamp": timestamp,
                    "lastModified": getCurrentTimestamp(),
                    "syncedAt": getCurrentTimestamp()
                ]
                
                if let reason = reason {
                    updateData["reason"] = reason
                }
                
                try await db.collection(schedulesCollection).document(scheduleId).updateData(updateData)
                successfulUpdates.append(index)
                print("✅ Synced update for schedule \(scheduleId)")
                
            } catch {
                print("❌ Failed to sync update for schedule \(scheduleId): \(error)")
            }
        }
        
        // Remove successfully synced updates
        if !successfulUpdates.isEmpty {
            var remainingUpdates = pendingUpdates
            for index in successfulUpdates.reversed() {
                remainingUpdates.remove(at: index)
            }
            userDefaults.set(remainingUpdates, forKey: "pending_updates")
            print("✅ Removed \(successfulUpdates.count) synced updates")
        }
    }
    
    // MARK: - Utility Methods
    func markScheduleOnHold(scheduleId: String, reason: String) async -> Bool {
        return await updateScheduleStatus(scheduleId: scheduleId, status: "On Hold", reason: reason)
    }
    
    func resetSchedules() {
        userDefaults.removeObject(forKey: schedulesKey)
        userDefaults.removeObject(forKey: initializationKey)
        userDefaults.removeObject(forKey: "pending_updates")
    }
    
    func getPendingUpdatesCount() -> Int {
        let pendingUpdates = userDefaults.array(forKey: "pending_updates") as? [[String: Any]] ?? []
        return pendingUpdates.count
    }
}
