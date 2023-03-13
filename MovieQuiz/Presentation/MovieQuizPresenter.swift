//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 13.03.23.
//

import UIKit

final class MovieQuizPresenter {
	
	private var currentQuestionIndex: Int = 0
	let questionsAmount: Int = 10
	var currentQuestion: QuizQuestion?
	weak var viewController: MovieQuizViewController?

	/// функция конвертации вопроса в модель
	func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}
	
	func counterOfQuestions() -> String {
		"\(currentQuestionIndex + 1)/\(questionsAmount)"
	}
	
	func isLastQuestion() -> Bool {
		currentQuestionIndex == questionsAmount - 1
	}
	
	func resetQuestionIndex() {
		currentQuestionIndex = 0
	}
	
	func switchToNextQuestion () {
		currentQuestionIndex += 1
	}
	
	
	func yesButtonClicked() {
		viewController?.toggleButtons() // и здесь тоже блокируем
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = true
		viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
	
	func noButtonClicked() {
		viewController?.toggleButtons() // и здесь тоже блокируем
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = false
		viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
}
