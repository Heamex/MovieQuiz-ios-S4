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
		questionFactory?.requestNextQuestion()
	}
	
	func didFailToLoadData(with error: Error) { // данные не загрузились
		viewController?.showNetworkError(message: error.localizedDescription)
	}
	
	// MARK: - Приватные методы

	private func isLastQuestion() -> Bool { // проверяем на последний вопрос
		currentQuestionIndex == questionsAmount - 1
	}
	
	private func restartGame() { // перезапускаем игру
		currentQuestionIndex = 0
	}
	
	private func showQuizRezult() { // Показываем результаты квиза
		// запускаем сохранение данных
		statisticService?.store(correct: correctAnswers, total: questionsAmount)
		
		// создаём объекты всплывающего окна
		if let statService = statisticService {
			let date = statService.bestGame.date
			
			let alertViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
				buttonText: "Сыграть ещё раз"
			)
			viewController?.showAlert(model: alertViewModel)
		} else {
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
				buttonText: "Сыграть ещё раз"
			)
			viewController?.showAlert(model: alertViewModel)
		}
	}
	
	// MARK: - Неприватные методы
	
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
	
	func switchToNextQuestion () { // прибавляем 1 к индексу
		currentQuestionIndex += 1
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
		restartGame()
		questionFactory?.loadData()
		restartGame()
	}
	
	func counterOfQuestions() -> String { // текстовое значение счётчика вопросов для полей VC
		"\(currentQuestionIndex + 1)/\(questionsAmount)"
	}
	
	func yesButtonClicked() { // нажали кнопку Да
		didAnswer(isYes: true)
	}
	
	func noButtonClicked() { // нажали кнопку Нет
		didAnswer(isYes: false)
	}
}
