//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 28.01.23.
//

import Foundation

/// Модель, хранящая структуру вопроса
struct QuizQuestion {
	let image: Data
	let text: String
	let correctAnswer: Bool
}
