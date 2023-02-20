//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 14.02.23.
//

import Foundation

struct GameRecord: Codable {
	let correct: Int
	let total: Int
	let date: Date
}

extension GameRecord: Comparable {
	static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
		if lhs.total == 0 {
			return true
		}
		let lhsRecord  = Double(lhs.correct) / Double(lhs.total)
		let rhsRecord = Double(rhs.correct) / Double(rhs.total)
		return lhsRecord < rhsRecord
	}
}

