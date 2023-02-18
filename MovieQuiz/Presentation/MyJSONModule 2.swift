//
//  JSON experiments.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 08.02.23.
//

import Foundation

class MyJSONModule {
	// MARK: - JSON TASKS
	
	func jsonFunc() {
		var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let fileName = "inception.json"
		documentsURL.appendPathComponent(fileName)
		let jsonString = try? String(contentsOf: documentsURL)
		let data = jsonString!.data(using: .utf8)!
		
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
			let actorList = json?["actorList"] as! [Any]
			for actor in actorList {
				if let actor = actor as? [String: Any] {
					print(actor["asCharacter"])
				}
			}
		} catch {
			print("Failed to parse: \(jsonString)")
		}
	}
}

// MARK: Structs
extension MyJSONModule {
	struct Actor {
		let id: String
		let image: String
		let name: String
		let asCharacter: String
	}
	struct Movie {
		let id: String
		let title: String
		let year: Int
		let image: String
		let releaseDate: String
		let runtimeMins: Int
		let directors: String
		let actorList: [Actor]
	}
}
