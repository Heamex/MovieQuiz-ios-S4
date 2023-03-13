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
	private var correctAnswers: Int = 0
	
	// MARK: Неприватные поля
	
	private var currentQuestion: QuizQuestion?
	weak var viewController: MovieQuizViewController?
	var questionFactory: QuestionFactoryProtocol?
	var statisticService: StatisticServices?
	
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
		viewController?.showNetworkError(message: error.localizedDescription)
	}
	
	// MARK: - Неприватные функции
	
	private func convert(model: QuizQuestion) -> QuizStepViewModel { // конвертируем модель вопроса во view модель
		QuizStepViewModel(
			image: UIImage(data: model.image) ?? UIImage(),
			question: model.text,
			questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}
	
	private func switchToNextQuestion () { // прибавляем 1 к индексу
		currentQuestionIndex += 1
	}
	
	private func isLastQuestion() -> Bool { // проверяем на последний вопрос
		currentQuestionIndex == questionsAmount - 1
	}
	
	private func restartGame() { // перезапускаем игру
		currentQuestionIndex = 0
	}
	
	private func highlightImageBorder(isCorrect: Bool) { // Показываем результат ответа пользователю
		switchToNextQuestion()
		switch isCorrect {
		case true:
			correctAnswers += 1
			viewController?.imageView.layer.borderColor = UIColor.ypGreen.cgColor
			viewController?.imageView.layer.borderWidth = 8
		case false:
			viewController?.imageView.layer.borderColor = UIColor.ypRed.cgColor
			viewController?.imageView.layer.borderWidth = 8
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			self.showNextQuestionOrResults()
		}
	}
	
	// Переход к следующему вопросу или результату квиза
	private func showNextQuestionOrResults() {
		viewController?.imageView.layer.borderWidth = 0
		
		if isLastQuestion() {
			showQuizRezult()
		} else {
			questionFactory?.requestNextQuestion()
		}
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
			viewController?.alertPresenter?.showAlert(model: alertViewModel)
		} else {
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
				buttonText: "Сыграть ещё раз"
			)
			viewController?.alertPresenter?.showAlert(model: alertViewModel)
		}
	}
	
	// MARK: - Неприватные функции
	
	func didAnswer(isYes: Bool) { // когда пользователь ответил
		viewController?.toggleButtons() // здесь блокируем кнопки
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = isYes
		highlightImageBorder(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
