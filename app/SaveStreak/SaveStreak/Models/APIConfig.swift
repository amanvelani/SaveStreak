//
//  APIResponse.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/29/24.
//

import Foundation

class ApiConfig: ObservableObject {
	@Published var baseUrl = "http://save-streak.live/"
}


struct ApiResponse: Codable {
	var status: String
	var error: String?
	
	enum CodingKeys: String, CodingKey {
		case status = "Status"
		case error = "Error"
	}
}
