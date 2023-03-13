//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 03.02.23.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {             
	func didReceiveNextQuestion(question: QuizQuestion?)
	func didLoadDataFromServer() // сообщение об успешной загрузке
	func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
