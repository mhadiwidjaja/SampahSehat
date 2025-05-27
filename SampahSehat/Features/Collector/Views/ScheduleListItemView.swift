//
//  ScheduleListItemView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct ScheduleListItemView: View {
    @EnvironmentObject var viewModel: CollectorViewModel
    var schedule: PickupSchedule

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("ID: \(schedule.scheduleId)")
                    .font(.caption)
                Text(schedule.areaInfo)
                    .font(.headline)
                Text("Time: \(formattedDate(schedule.pickupDate))")
                    .font(.subheadline)
                Text("Status: \(schedule.status)")
                    .font(.footnote)
                    .foregroundColor(statusColor(schedule.status))
            }

            Spacer()

            if schedule.status == "Pending" {
                Button {
                    viewModel.markScheduleCompleted(scheduleId: schedule.scheduleId)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .buttonStyle(BorderlessButtonStyle())

                Button {
                    viewModel.markScheduleMissed(scheduleId: schedule.scheduleId)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }

    private func formattedDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .none
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        let simpleDateFormatter = DateFormatter()
        simpleDateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = simpleDateFormatter.date(from: dateString) {
             let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "completed":
            return .green
        case "missed":
            return .orange
        default:
            return .gray
        }
    }
}

struct ScheduleListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let schedule = PickupSchedule(scheduleId: "prev1", areaInfo: "Preview Area", pickupDate: "2023-10-27T11:00:00Z", status: "Pending", assignedCollectorId: "c1")
        let vm = CollectorViewModel()
        vm.todaysSchedule = [schedule]
        return ScheduleListItemView(schedule: schedule)
            .environmentObject(vm)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
