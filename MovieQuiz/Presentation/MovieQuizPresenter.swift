//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 13.03.23.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
		
	private var currentQuestionIndex: Int = 0
	let questionsAmount: Int = 10
	var currentQuestion: QuizQuestion?
	weak var viewController: MovieQuizViewController?
	var questionFactory: QuestionFactoryProtocol?
	var statisticService: StatisticServices?
	var alertPresenter: AlertPresenter?
	
	
	
	
	
	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		currentQuestion = question
		let viewModel = convert(model: question)
		DispatchQueue.main.async { [weak viewController] in
			viewController?.showQuiz(quiz: viewModel)
		}
	}
	
	func didLoadDataFromServer() {
		viewController?.didLoadDataFromServer()
	}
	
	func didFailToLoadData(with error: Error) {
		viewController?.didLoadDataFromServer()
	}

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
	
	func didAlertButtonPressed() {
		resetQuestionIndex()
		questionFactory?.loadData()
		viewController?.correctAnswers = 0
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
	
	func showRezult() {
		// запускаем сохранение данных
		guard let viewController = viewController else { return }
		statisticService?.store(correct: viewController.correctAnswers, total: questionsAmount)
		
		// создаём объекты всплывающего окна
		if let statService = statisticService {
			let date = statService.bestGame.date
			
			let alertViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(viewController.correctAnswers)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
				buttonText: "Сыграть ещё раз"
			)
			alertPresenter?.showAlert(model: alertViewModel)
		} else {
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(viewController.correctAnswers)/\(questionsAmount)",
				buttonText: "Сыграть ещё раз"
			)
			alertPresenter?.showAlert(model: alertViewModel)
		}
	}
}
