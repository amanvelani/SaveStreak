//
//  MapView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/3/24.
//
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel = MapViewModel()

    var body: some View {
        NavigationView {
            VStack {
                filterBar
                mapDisplay
            }
            .background(BackgroundGradient())
            .navigationBarTitle("Money Trails")
            .navigationBarItems(trailing: refreshButton)
            .onAppear {
                viewModel.fetchTransactions()
            }
        }
    }
    

    private var filterBar: some View {
        VStack(spacing: 4) {
            menuPicker("Category: \(viewModel.selectedCategory)", options: viewModel.categories, selection: $viewModel.selectedCategory)
            segmentedDateRangePicker
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))  // Slight visual contrast
        .cornerRadius(10)
        .shadow(radius: 2)
        .padding(.horizontal)
    }

    private var segmentedDateRangePicker: some View {
        Picker("Date Range", selection: $viewModel.selectedDateRange) {
            ForEach(viewModel.dateRanges, id: \.self) { range in
                Text(range)
                    .tag(range)
                    .font(.system(size: 16, weight: .medium)) // Enhanced font size and weight
            }
        }
        .pickerStyle(SegmentedPickerStyle())  // Use segmented control style
        .padding(.horizontal)
        .onChange(of: viewModel.selectedDateRange) { newValue in
            viewModel.fetchTransactions()  // Fetch transactions when the date range changes
        }
    }

    private func menuPicker(_ title: String, options: [String], selection: Binding<String>) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    withAnimation {
                        selection.wrappedValue = option
                        viewModel.fetchTransactions()
                    }
                }
                .font(.system(size: 16)) // Enhanced font size for options
            }
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold)) // Enhanced font size and weight for the title
                Spacer()
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 6)
            }
            .padding()
            .foregroundColor(Color.primary)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
        }
    }




    private var mapDisplay: some View {
        Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.locationTransactions) { transaction in
            MapAnnotation(coordinate: transaction.coordinate) {
                annotationView(for: transaction)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .padding(.bottom)
    }

    private func annotationView(for transaction: LocationTransaction) -> some View {
        VStack {
            Image(systemName: "dollarsign.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(categoryColor(for: String(viewModel.selectedCategory)))
                .background(Circle().fill(Color(UIColor.systemBackground)))
                .clipShape(Circle())
                .shadow(radius: 5)
            
            Text("\(transaction.amount, specifier: "%.2f")")
                .foregroundColor(Color.primary)
                .font(.caption.bold())
                .padding(5)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(5)
                .shadow(radius: 5)
            
            Text(transaction.name)
                .foregroundColor(Color.primary)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .padding(2)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(5)
                .shadow(radius: 5)
        }
    }
    private var refreshButton: some View {
        Button(action: {
            viewModel.fetchTransactions()
        }) {
            Image(systemName: "arrow.clockwise")
                .foregroundColor(.blue)
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Food and Drink":
            return .green
        case "Healthcare":
            return .red
        case "Payment":
            return .blue
        default:
            return .orange
        }
    }
}

