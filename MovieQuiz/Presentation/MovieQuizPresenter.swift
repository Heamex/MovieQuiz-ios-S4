//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 13.03.23.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
	
	func didLoadDataFromServer() {
		viewController?.didLoadDataFromServer()
	}
	
	func didFailToLoadData(with error: Error) {
		viewController?.didLoadDataFromServer()
	}
	
	
	private var currentQuestionIndex: Int = 0
	let questionsAmount: Int = 10
	var currentQuestion: QuizQuestion?
	weak var viewController: MovieQuizViewController?
	var questionFactory: QuestionFactoryProtocol?

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
		didAnswer(isYes: true)
	}
	
	func noButtonClicked() {
		didAnswer(isYes: false)
	}
	
	func toggleButtons () {
		viewController?.noButton.isEnabled.toggle()
		viewController?.yesButton.isEnabled.toggle()
	}
	
	private func didAnswer(isYes: Bool) {
		toggleButtons() // и здесь тоже блокируем
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = isYes
		viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
	
	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		currentQuestion = question
		let viewModel = convert(model: question)
		DispatchQueue.main.async { [weak viewController] in
			viewController?.showQuiz(quiz: viewModel)
		}
	}
	/// Функция для перехода к следующему вопросу или результату квиза
	func showNextQuestionOrResults() {
		viewController?.imageView.layer.borderWidth = 0
		if isLastQuestion() {
			viewController?.showRezult()
		} else {
			questionFactory?.requestNextQuestion()
		}
	}
}
