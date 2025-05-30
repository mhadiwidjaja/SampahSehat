//
//  CollectorScheduleListView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//
import SwiftUI

struct CollectorScheduleListView: View {
    @EnvironmentObject var viewModel: CollectorViewModel
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    headerView
                    
                    // Content Section
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.todaysSchedule.isEmpty {
                        emptyStateView
                    } else {
                        scheduleListView
                    }
                    
                    // Error Section
                    if let error = viewModel.updateError, !viewModel.todaysSchedule.isEmpty {
                        errorView(error: error)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadTodaysSchedule()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Logo
                Image("SampahSehat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Route")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(getCurrentDateString())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.loadTodaysSchedule()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        authViewModel.logout()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 40, height: 40)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Stats Row
            if !viewModel.todaysSchedule.isEmpty {
                statsView
                    .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Stats View
    private var statsView: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Pending",
                count: viewModel.todaysSchedule.filter { $0.status == "Pending" }.count,
                color: .blue,
                icon: "clock.fill"
            )
            
            StatCard(
                title: "Completed",
                count: viewModel.todaysSchedule.filter { $0.status == "Completed" }.count,
                color: .green,
                icon: "checkmark.circle.fill"
            )
            
            StatCard(
                title: "Missed",
                count: viewModel.todaysSchedule.filter { $0.status == "Missed" }.count,
                color: .red,
                icon: "x.circle.fill"
            )
            
            StatCard(
                title: "On Hold",
                count: viewModel.todaysSchedule.filter { $0.status == "On Hold" }.count,
                color: .orange,
                icon: "pause.circle.fill"
            )
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(1.5)
            
            Text("Loading your schedule...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Schedules Today")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("You don't have any pickup schedules assigned for today.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let error = viewModel.updateError {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
            
            Button("Refresh") {
                viewModel.loadTodaysSchedule()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.green, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, -50)
    }
    
    // MARK: - Schedule List View
    private var scheduleListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.todaysSchedule) { schedule in
                    ScheduleListItemView(schedule: schedule)
                        .environmentObject(viewModel)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Error View
    private func errorView(error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
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
