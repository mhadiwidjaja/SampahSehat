//
//  CollectorScheduleListView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//
import SwiftUI

struct CollectorScheduleListView: View {
    @EnvironmentObject var viewModel: CollectorViewModel
    // Use shared instance instead of creating new one
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading schedule...")
                } else if viewModel.todaysSchedule.isEmpty {
                    VStack {
                        Text("No schedules assigned for today")
                        if let error = viewModel.updateError {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                        }
                        
                        Button("Refresh") {
                            print("🔄 Manual refresh pressed")
                            viewModel.loadTodaysSchedule()
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.todaysSchedule) { schedule in
                            ScheduleListItemView(schedule: schedule)
                                .environmentObject(viewModel)
                        }
                    }
                }

                if let error = viewModel.updateError, !viewModel.todaysSchedule.isEmpty {
                    Text("Update Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Today's Route")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        print("🚪 Logout button pressed")
                        print("🚪 Current user before logout: \(authViewModel.currentUser?.email ?? "nil")")
                        authViewModel.logout()
                        print("🚪 Current user after logout: \(authViewModel.currentUser?.email ?? "nil")")
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        print("🔄 Toolbar refresh pressed")
                        viewModel.loadTodaysSchedule()
                    }
                }
            }
            .onAppear {
                print("🔵 CollectorScheduleListView appeared")
                viewModel.loadTodaysSchedule()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct CollectorScheduleListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = CollectorViewModel()
        mockViewModel.todaysSchedule = [
            PickupSchedule(scheduleId: "1", areaInfo: "Blok A", pickupDate: "2023-10-27T09:00:00Z", status: "Pending", assignedCollectorId: "c1"),
            PickupSchedule(scheduleId: "2", areaInfo: "Blok B", pickupDate: "2023-10-27T10:00:00Z", status: "Completed", assignedCollectorId: "c1")
        ]
        return CollectorScheduleListView().environmentObject(mockViewModel)
    }
}
