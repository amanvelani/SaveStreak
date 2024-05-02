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
            .navigationBarTitle("Location Wise Spending", displayMode: .inline)
            .navigationBarItems(trailing: refreshButton)
            .onAppear {
                viewModel.fetchTransactions()
            }
        }
    }
    

    private var filterBar: some View {
           VStack(spacing: 8) {
               menuPicker("Category: \(viewModel.selectedCategory)", options: viewModel.categories, selection: $viewModel.selectedCategory)
               menuPicker("Date Range: \(viewModel.selectedDateRange)", options: viewModel.dateRanges, selection: $viewModel.selectedDateRange)
           }
           .padding()
           .background(Color.white)
           .cornerRadius(12)
           .shadow(radius: 4)
           .padding(.horizontal)
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
               }
           } label: {
               HStack {
                   Text(title)
                   Spacer()
                   Image(systemName: "chevron.down")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 12, height: 8)
               }
               .padding()
               .foregroundColor(Color.blue)
               .background(Color(.systemBackground))
               .overlay(
                   RoundedRectangle(cornerRadius: 10)
                       .stroke(Color.black, lineWidth: 1)
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
    }

    private func annotationView(for transaction: LocationTransaction) -> some View {
        VStack {
            Image(systemName: "dollarsign.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(categoryColor(for: String(viewModel.selectedCategory)))
                .background(Circle().fill(Color.white))
                .clipShape(Circle())
                .shadow(radius: 5)
            Text("\(transaction.amount, specifier: "%.2f")")
                .foregroundColor(.black)
                .font(.caption.bold())
                .padding(5)
                .background(Color.white)
                .cornerRadius(5)
                .shadow(radius: 5)
            Text(transaction.name)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .padding(2)
                .background(Color.white)
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
            return .gray
        }
    }
}
