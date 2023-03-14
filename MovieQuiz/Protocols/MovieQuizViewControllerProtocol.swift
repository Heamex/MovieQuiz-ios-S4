//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 14.03.23.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
	
	func hideLoadingIndicator()
	func showLoadingIndicator()
	func showQuiz(quiz step: QuizStepViewModel)
	func showNetworkError(message: String)
	func highlightImageBorder(isCorrect: Bool)
	func showAlert(model:QuizResultsViewModel)
	func toggleButtons ()
	
}
