//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 13.03.23.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
	
	// MARK: Приватные поля
	
	private var currentQuestionIndex: Int = 0
	private let questionsAmount: Int = 10
	private var currentQuestion: QuizQuestion?
	
	// MARK: Неприватные поля
	
	var correctAnswers: Int = 0
	weak var viewController: MovieQuizViewControllerProtocol? //
	var questionFactory: QuestionFactoryProtocol? //
	var statisticService: StatisticServices?
	
	// MARK: INIT
	
	init(viewController: MovieQuizViewControllerProtocol) {
		self.viewController = viewController
		
		questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
		statisticService = StatisticServicesImplementation()
		questionFactory?.loadData()
	}
	
	// MARK: - QuestionFactoryDelegate
	
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		currentQuestion = question
		let viewModel = convert(model: question)
		DispatchQueue.main.async { [weak viewController] in
			viewController?.showQuiz(quiz: viewModel)
			viewController?.toggleButtons()
		}
	}
	
	func didLoadDataFromServer() { // Данные получены
		viewController?.hideLoadingIndicator()
		questionFactory?.requestNextQuestion()
	}
	
	func didFailToLoadData(with error: Error) { // данные не загрузились
		viewController?.hideLoadingIndicator()
		viewController?.showNetworkError(message: error.localizedDescription)
	}
	
	// MARK: - Приватные методы
	
	private func isLastQuestion() -> Bool { // проверяем на последний вопрос
		currentQuestionIndex == questionsAmount
	}
	
	private func restartGame() { // перезапускаем игру
		currentQuestionIndex = 0
	}
	
	private func showQuizRezult() { // Результат квиза
		statisticService?.store(correct: correctAnswers, total: questionsAmount) // сохраняем статистику
		
		if let statService = statisticService { // создаём объекты всплывающего окна
			let date = statService.bestGame.date
			
			let alertViewModel = QuizResultsViewModel ( // формируем модель данных
				title: "Этот раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
				buttonText: "Сыграть ещё раз"
			)
			viewController?.showAlert(model: alertViewModel)
		} else {
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel ( // формируем модель данных если загрузить статистику не удалось
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
				buttonText: "Сыграть ещё раз"
			)
			viewController?.showAlert(model: alertViewModel)
		}
	}
	
	// MARK: - Публичные методы
	
	// Переход к следующему вопросу или результату квиза
	func showNextQuestionOrResults() {
		if isLastQuestion() {
			showQuizRezult()
		} else {
			questionFactory?.requestNextQuestion()
		}
	}
	
	func convert(model: QuizQuestion) -> QuizStepViewModel { // конвертируем модель вопроса во view модель
		QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}
	
	func didAnswer(isYes: Bool) { // когда пользователь ответил
		viewController?.toggleButtons() // здесь блокируем кнопки
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = isYes
		viewController?.highlightImageBorder(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
	
	func didAlertButtonPressed() { // когда пользователь нажимает "Ещё раз!"
		questionFactory?.loadData()
		restartGame()
	}
	
	func counterOfQuestions() -> String { // текстовое значение счётчика вопросов для полей VC
		"\(currentQuestionIndex + 1)/\(questionsAmount)"
	}
	
	func switchToNextQuestion () { // прибавляем 1 к индексу
		currentQuestionIndex += 1
	}
	
	func yesButtonClicked() { // нажали кнопку Да
		didAnswer(isYes: true)
	}
	
	func noButtonClicked() { // нажали кнопку Нет
		didAnswer(isYes: false)
	}
}
