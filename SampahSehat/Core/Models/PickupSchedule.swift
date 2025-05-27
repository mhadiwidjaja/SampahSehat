//
//  PickupSchedule.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import Foundation

struct PickupSchedule: Identifiable, Codable {
    var id: String { scheduleId }
    var scheduleId: String
    var areaInfo: String
    var pickupDate: String
    var status: String
    var assignedCollectorId: String?

    enum CodingKeys: String, CodingKey {
        case scheduleId
        case areaInfo
        case pickupDate
        case status
        case assignedCollectorId
    }
}
