//
//  StatisticServicesProtocol.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 14.03.23.
//

import Foundation

protocol StatisticServices {
	var totalAccurancy: Double {get}
	var gamesCount: Int {get}
	var bestGame: GameRecord {get}
	func store(correct count: Int, total amount: Int)
}
