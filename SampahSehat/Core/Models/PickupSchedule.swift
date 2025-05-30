//
//  PickupSchedule.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import Foundation

struct PickupSchedule: Identifiable, Codable {
    let id = UUID()
    var scheduleId: String
    var areaInfo: String
    var pickupDate: String
    var status: String // "Pending", "Completed", "Missed", "On Hold"
    var assignedCollectorId: String
    var reason: String? // For missed or on hold reasons
    var timestamp: String? // When status was last updated
    
    init(scheduleId: String, areaInfo: String, pickupDate: String, status: String, assignedCollectorId: String, reason: String? = nil, timestamp: String? = nil) {
        self.scheduleId = scheduleId
        self.areaInfo = areaInfo
        self.pickupDate = pickupDate
        self.status = status
        self.assignedCollectorId = assignedCollectorId
        self.reason = reason
        self.timestamp = timestamp
    }
}
