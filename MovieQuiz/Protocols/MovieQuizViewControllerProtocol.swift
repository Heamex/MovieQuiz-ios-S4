//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 14.03.23.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject, UIViewController {
	func didAlertButtonPressed()
	func toggleButtons ()
	func showQuiz(quiz step: QuizStepViewModel)
	func showNetworkError(message: String)
}
