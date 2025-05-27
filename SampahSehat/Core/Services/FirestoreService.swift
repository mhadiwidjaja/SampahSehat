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

    func getUser(userId: String) async -> User? {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            return try document.data(as: User.self)
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getScheduleForArea(areaInfo: String, date: Date) async -> PickupSchedule? {
        let dateString = ISO8601DateFormatter().string(from: date)
        do {
            let querySnapshot = try await db.collection("pickupSchedules")
                .whereField("areaInfo", isEqualTo: areaInfo)
                .whereField("pickupDate", isEqualTo: dateString)
                .limit(to: 1)
                .getDocuments()
            guard let document = querySnapshot.documents.first else { return nil }
            return try document.data(as: PickupSchedule.self)
        } catch {
            print("Error fetching schedule for area: \(error.localizedDescription)")
            return nil
        }
    }

    func getSchedulesForCollector(collectorId: String, date: Date) async -> [PickupSchedule] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStringForQuery = dateFormatter.string(from: date)

        do {
            let querySnapshot = try await db.collection("pickupSchedules")
                .whereField("assignedCollectorId", isEqualTo: collectorId)
                .getDocuments()
            let schedules = querySnapshot.documents.compactMap { document -> PickupSchedule? in
                var schedule = try? document.data(as: PickupSchedule.self)
                if let dateStr = schedule?.pickupDate, dateStr.hasPrefix(dateStringForQuery) {
                    schedule?.scheduleId = document.documentID
                    return schedule
                } else if let dateStr = schedule?.pickupDate, schedule?.pickupDate == dateStringForQuery {
                     schedule?.scheduleId = document.documentID
                    return schedule
                }
                return nil
            }
            return schedules
        } catch {
            print("Error fetching schedules for collector: \(error.localizedDescription)")
            return []
        }
    }

    func updateScheduleStatus(scheduleId: String, status: String) async -> Bool {
        do {
            try await db.collection("pickupSchedules").document(scheduleId).updateData([
                "status": status,
                "lastUpdated": Timestamp()
            ])
            return true
        } catch {
            print("Error updating schedule status: \(error.localizedDescription)")
            return false
        }
    }
}
