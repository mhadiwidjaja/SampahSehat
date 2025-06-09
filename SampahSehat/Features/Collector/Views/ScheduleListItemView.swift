//
//  ScheduleListItemView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct ScheduleListItemView: View {
    let schedule: PickupSchedule
    @EnvironmentObject var viewModel: CollectorViewModel
    @State private var showingMissedAlert = false
    @State private var showingOnHoldAlert = false
    @State private var missedReason = ""
    @State private var onHoldReason = ""
    
    private let missedReasons = ["Bin not accessible", "Address not found", "Road blocked", "Customer not available", "Other"]
    private let onHoldReasons = ["Road blocked", "Vehicle breakdown", "Weather conditions", "Safety concerns", "Other"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Content
            HStack(alignment: .top, spacing: 16) {
                // Status Icon
                statusIconView
                
                // Schedule Info
                VStack(alignment: .leading, spacing: 8) {
                    // Area Name
                    Text(schedule.areaInfo)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // Status and Time Info
                    HStack(spacing: 12) {
                        statusBadge
                        
                        Spacer()
                        
                        if let timestamp = schedule.timestamp {
                            Text(formatTime(timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                    
                    // Reason (if exists)
                    if let reason = schedule.reason {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(statusColor.opacity(0.7))
                            
                            Text("Reason: \(reason)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding(20)
            
            // Action Buttons (only for pending schedules)
            if schedule.status == "Pending" {
                Divider()
                    .background(statusColor.opacity(0.2))
                
                actionButtonsView
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(statusColor.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(16)
        .shadow(color: statusColor.opacity(0.15), radius: 8, x: 0, y: 4)
        .alert("Mark as Missed", isPresented: $showingMissedAlert) {
            ForEach(missedReasons, id: \.self) { reason in
                Button(reason) {
                    missedReason = reason
                    viewModel.markScheduleMissed(scheduleId: schedule.scheduleId, reason: reason)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select a reason for marking this pickup as missed:")
        }
        .alert("Mark as On Hold", isPresented: $showingOnHoldAlert) {
            ForEach(onHoldReasons, id: \.self) { reason in
                Button(reason) {
                    onHoldReason = reason
                    viewModel.markScheduleOnHold(scheduleId: schedule.scheduleId, reason: reason)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Select a reason for putting this pickup on hold:")
        }
    }
    
    // MARK: - Status Icon View
    private var statusIconView: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 50, height: 50)
            
            Circle()
                .stroke(statusColor, lineWidth: 3)
                .frame(width: 50, height: 50)
            
            Image(systemName: statusIconName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
        }
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        Text(schedule.status.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(statusColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
            )
    }
    
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            Button(action: {
                viewModel.markScheduleCompleted(scheduleId: schedule.scheduleId)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                    Text("Complete")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            Button(action: {
                showingMissedAlert = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "x.circle.fill")
                        .font(.body)
                    Text("Missed")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.red, .red.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            Button(action: {
                showingOnHoldAlert = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "pause.circle.fill")
                        .font(.body)
                    Text("Hold")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.orange, .orange.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        switch schedule.status {
        case "Completed": return .green
        case "Missed": return .red
        case "On Hold": return .orange
        case "Pending": return .blue
        default: return .gray
        }
    }
    
    private var backgroundColor: Color {
        switch schedule.status {
        case "Completed": return Color.green.opacity(0.05)
        case "Missed": return Color.red.opacity(0.05)
        case "On Hold": return Color.orange.opacity(0.05)
        case "Pending": return Color.blue.opacity(0.05)
        default: return Color.gray.opacity(0.05)
        }
    }
    
    private var statusIconName: String {
        switch schedule.status {
        case "Completed": return "checkmark"
        case "Missed": return "xmark"
        case "On Hold": return "pause"
        case "Pending": return "clock"
        default: return "questionmark"
        }
    }
    
    private func formatTime(_ timestamp: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.timeZone = TimeZone.current
        
        if let date = inputFormatter.date(from: timestamp) {
            return outputFormatter.string(from: date)
        }
        return "N/A"
    }
}

struct ScheduleListItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 16) {
                ScheduleListItemView(schedule: PickupSchedule(
                    scheduleId: "test_sched_001",
                    areaInfo: "Blok A - Jl. Sudirman",
                    pickupDate: "2025-05-30",
                    status: "Pending",
                    assignedCollectorId: "collector123"
                ))
                
                ScheduleListItemView(schedule: PickupSchedule(
                    scheduleId: "test_sched_002",
                    areaInfo: "Blok B - Jl. Thamrin",
                    pickupDate: "2025-05-30",
                    status: "Completed",
                    assignedCollectorId: "collector123",
                    timestamp: "2025-05-30 10:30:00"
                ))
                
                ScheduleListItemView(schedule: PickupSchedule(
                    scheduleId: "test_sched_003",
                    areaInfo: "Blok C - Jl. Gatot Subroto",
                    pickupDate: "2025-05-30",
                    status: "Missed",
                    assignedCollectorId: "collector123",
                    reason: "Bin not out",
                    timestamp: "2025-05-30 11:00:00"
                ))
            }
            .padding()
        }
        .environmentObject(CollectorViewModel())
        .previewLayout(.sizeThatFits)
    }
}
