	//
	//  InsightsView.swift
	//  SaveStreak
	//
	//  Created by Chinmay Yadav on 3/11/24.
	//

import SwiftUI
import SwiftUICharts
import Charts

struct StepCount: Identifiable {
	let id = UUID()
	let weekday: Date
	let steps: Int
	
	init(day: String, steps: Int) {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyyMMdd"
		
		self.weekday = formatter.date(from: day) ?? Date.distantPast
		self.steps = steps
	}
	
	var weekdayString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMdd"
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale(identifier: "en_US")
		return  dateFormatter.string(from: weekday)
	}
}

struct InsightsView: View {
	
	@State private var showingCategory = true
	@State private var startDate = Date()
	@State private var endDate = Date()
	@StateObject var viewModel = SpendingViewModel()
	@State private var selectedName: String? = nil
	@State private var selectedValue: Double? = nil
	@State 	var selectedAngle: Double?
	@State private var showingFilters = false
	@State var fromDateComponents = DateComponents(year: 2024, month: 02)
	@State var toDateComponents = DateComponents(year: 2024, month: 5)

	
	var selectedItem: CategorySpend? {
		guard let selectedAngle else { return nil }
		if let selected = viewModel.categoryRanges.firstIndex(where: {
			$0.range.contains(selectedAngle)
		}) {
			return viewModel.categoryWiseSpend[selected]
		}
		return nil
	}
	
	
	
	var body: some View {
		NavigationView {
			VStack {
				Picker("Select Graph Type", selection: $showingCategory) {
					Text("Spend by Category").tag(true)
					Text("Monthly Spend").tag(false)
				}
				.pickerStyle(SegmentedPickerStyle())
				if(viewModel.isBusy){
					Spacer()
					ProgressView()
					Spacer()
				} else{
					HStack {
						if showingCategory {
							Text("Total Expenses: $\(viewModel.totalPosts, specifier: "%.2f")")

						}
						Button(action: {
							showingFilters.toggle()
						}) {
							Image(systemName: "line.horizontal.3.decrease.circle")
						}
						
						if showingFilters {
							Button(action: {
								viewModel.loadCategoryData()
								showingFilters.toggle()
							}) {
								Image(systemName: "xmark.circle")
							}
						}
					}
					.padding()
					
					if showingFilters && showingCategory{
						DatePicker("From", selection: $startDate, displayedComponents: .date)
						DatePicker("To", selection: $endDate, displayedComponents: .date)
						Button("Apply Filter") {
							viewModel.filterData(startDate: startDate, endDate: endDate, isCategory: showingCategory == true)
						}
					} else if showingFilters && !showingCategory {
						VStack {
							HStack {
								Text("From")
								if let monthBinding = Binding($fromDateComponents.month) {
									MonthPicker(month: monthBinding)
								}
								
								if let yearBinding = Binding($fromDateComponents.year) {
									YearPicker(year: yearBinding)
								}
							}
							HStack {
								Text("To")
								if let monthBinding = Binding($toDateComponents.month) {
									MonthPicker(month: monthBinding)
								}
								
								if let yearBinding = Binding($toDateComponents.year) {
									YearPicker(year: yearBinding)
								}
							}
						}
						Button("Apply Filter") {
							viewModel.filterSpendData(startMonth: fromDateComponents, endMonth: toDateComponents)
						}
					}
					if showingCategory {
						List(viewModel.categoryWiseSpend, id: \.self) { category in
							HStack {
								Text("\(category._id) ")
								Spacer()
								Text("$\(category.total_expense, specifier: "%.2f") ")
							}
							
						}
						
						Chart(viewModel.categoryWiseSpend, id: \._id) { element in
							SectorMark(
								angle: .value("Sales", element.total_expense),
								innerRadius: .ratio(0.6),
								angularInset: 2
							)
							.opacity(element._id == selectedItem?._id ? 1 : 0.7)
							.cornerRadius(5)
							.foregroundStyle(by: .value("Name", element._id))
						}
						.scaledToFit()
						.chartLegend(alignment: .center, spacing: 16)
						.chartBackground { chartProxy in
							GeometryReader { geometry in
								if let anchor = chartProxy.plotFrame {
									let frame = geometry[anchor]
									titleView
										.position(x: frame.midX, y: frame.midY)
								}
							}
						}
						.chartAngleSelection(value: $selectedAngle)
						
					} else {
							Chart(viewModel.trendSpendData) {
									BarMark(
										x: .value("Step Count", $0.total_spending),
										y: .value("Week Day", $0._id)
									)
							}.padding()
						
						List(viewModel.trendSpendData, id: \.self) { category in
							HStack {
								Text("\(category._id) ")
								Spacer()
								Text("$\(category.total_spending, specifier: "%.2f") ")
							}
							
						}
					}
				}
			}.navigationTitle("Spending Overview")
		}.onAppear() {
			viewModel.loadCategoryData()
			viewModel.loadSpendingTrendData()
			UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation to portrait
			AppDelegate.orientationLock = .portrait // And making sure it stays that way

		}.onDisappear {
			AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
		}
//		.background(PortraitOnlyViewModifier()) // Apply the orientation lock

	}
	
	
	private var titleView: some View {
		VStack {
			Text(selectedItem?._id ?? "")
				.font(.title)
			if let totalExpense = selectedItem?.total_expense {
				Text("$\(totalExpense, specifier: "%.2f")")
					.font(.callout)
			}
		}
	}
}


extension Date {
	var startOfMonth: Date {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.year, .month], from: self)
		return calendar.date(from: components)!
	}
	
	var endOfMonth: Date {
		let calendar = Calendar.current
		let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1), to: self.startOfMonth)!
		let endOfThisMonth = calendar.date(byAdding: DateComponents(day: -1), to: startOfNextMonth)!
		return endOfThisMonth
	}
}

struct MonthPicker: View {
	@Binding var month: Int
	@Environment(\.calendar) var calendar
	
	var body: some View {
		Picker("", selection: $month) {
			let months = calendar.monthSymbols
			ForEach(months.indices, id: \.self) { i in
				Text(months[i])
					.tag(i + 1)
			}
		}
		.labelsHidden()
		.background(Color.white)
		.cornerRadius(8)
		.overlay(
			RoundedRectangle(cornerRadius: 8)
				.stroke(Color.blue, lineWidth: 1)
		)
	}
}

struct YearPicker: View {
	@Binding var year: Int
	let years: [Int]
	
	init(year: Binding<Int>) {
		let currentYear = Calendar.current.component(.year, from: Date())
		self.years = Array((currentYear - 9)...currentYear)
		self._year = year
	}
	
	var body: some View {
		Picker("", selection: $year) {
			ForEach(years, id: \.self) { year in
				Text("\(year)")
					.tag(year)
			}
		}
		.labelsHidden()
		.background(Color.white)
		.cornerRadius(8)
		.overlay(
			RoundedRectangle(cornerRadius: 8)
				.stroke(Color.blue, lineWidth: 1)
		)
	}
}

//
//struct SomeView: View {
//	
//}
