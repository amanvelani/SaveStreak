//
//  MapView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/3/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.04322, longitude: -76.13726),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    @State private var selectedCategory: String = "Food"
    let categories = ["Food", "Coffee", "Shopping", "Entertainment"]
    
    @State private var selectedDateRange: String = "Last Month"
    let dateRanges = ["Last Week", "Last Month", "Last Year"]
    

        
        // Sample store locations
        let stores: [Store] = [
            Store(name: "Alto Cinco", coordinate: CLLocationCoordinate2D(latitude: 43.04322, longitude: -76.12003), rank: 1),
            Store(name: "Chipotle", coordinate: CLLocationCoordinate2D(latitude: 43.04173, longitude: -76.13544), rank: 2),
            Store(name: "Tai Chi", coordinate: CLLocationCoordinate2D(latitude: 43.04707, longitude: -76.13726), rank: 3),
            Store(name: "Burger King", coordinate: CLLocationCoordinate2D(latitude: 43.04898, longitude: -76.12787), rank: 4),
            Store(name: "Peaks Coffee", coordinate: CLLocationCoordinate2D(latitude: 43.04678, longitude: -76.13132), rank: 5)
        ]
        
        var body: some View {
            NavigationView {
                ZStack {
                    VStack {
                        // Selectors placed in a horizontal stack for layout
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Category")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Picker("Category", selection: $selectedCategory) {
                                    ForEach(categories, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding(.leading)
                            
                            VStack(alignment: .leading) {
                                Text("Date Range")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Picker("Date Range", selection: $selectedDateRange) {
                                    ForEach(dateRanges, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding(.leading)
                        }
                        .padding(.top)
                        
                        Map(coordinateRegion: $region, annotationItems: stores) { store in
                            MapAnnotation(coordinate: store.coordinate) {
                                VStack {
                                    Text("\(store.rank)")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .padding(5)
                                        .background(Circle().fill(Color.blue))
                                    Text(store.name)
                                        .font(.caption)
                                }
                            }
                        }
//                        .edgesIgnoringSafeArea(.all)
                    }
                }
                .navigationBarTitle("Location Wise Spending", displayMode: .inline)
            }
        }

    }

    struct Store: Identifiable {
        let id = UUID()
        let name: String
        let coordinate: CLLocationCoordinate2D
        let rank: Int
    }
#Preview {
    MapView()
}
