//
//  APIResponse.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/29/24.
//

import Foundation

class ApiConfig: ObservableObject {
	@Published var baseUrl = "http://save-streak.live/"
//	 @Published var baseUrl = "http://0.0.0.0:5000/"
}


struct ApiResponse: Codable {
	var status: String
	var error: String?
	
	enum CodingKeys: String, CodingKey {
		case status = "Status"
		case error = "Error"
	}
}
