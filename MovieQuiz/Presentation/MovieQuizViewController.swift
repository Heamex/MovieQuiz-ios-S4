import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
	
	
	
	// MARK: - Private functions
	private var correctAnswers: Int = 0
	
	private var questionFactory: QuestionFactoryProtocol?
	private var currentQuestion: QuizQuestion?
	private	var alertPresenter: AlertPresenter?
	private var statisticService: StatisticServices?
	private var presenter = MovieQuizPresenter()
	
	@IBOutlet private var imageView: UIImageView!
	@IBOutlet private var textLabel: UILabel!
	@IBOutlet private var counterLabel: UILabel!
	@IBOutlet private var noButton: UIButton! // тут оутлеты
	@IBOutlet private var yesButton: UIButton! // на две кнопки
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		statisticService = StatisticServicesImplementation()
		presenter.viewController = self
		questionFactory = QuestionFactory(moviesLoader: MovesLoader(), delegate: self)
		showLoadingIndicator()
		questionFactory?.loadData()
		alertPresenter = AlertPresenter(delegate: self)
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 20
	}
	
	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		currentQuestion = question
		let viewModel = presenter.convert(model: question)
		DispatchQueue.main.async { [weak self] in
			self?.showQuiz(quiz: viewModel)
		}
	}
	
	func didLoadDataFromServer() {
		hideLoadingIndicator()
		questionFactory?.requestNextQuestion()
	}
	
	func didFailToLoadData(with error: Error) {
		showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
	}
	
	// MARK: - AlertPresenterDelegate
	func didAlertButtonPressed() {
		presenter.resetQuestionIndex()
		questionFactory?.loadData()
		correctAnswers = 0
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	// Запускаем индикатор загрузки
	private func showLoadingIndicator() {
		activityIndicator.startAnimating()
	}
	
	private func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}
	
	/// Включение / выключение кнопок
	func toggleButtons () {
		noButton.isEnabled.toggle()
		yesButton.isEnabled.toggle()
	}
	

	/// здесь мы заполняем нашу картинку, текст и счётчик данными
	private func showQuiz(quiz step: QuizStepViewModel) {
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = presenter.counterOfQuestions()
	}
	/// Функция, показывающая реакцию квиза на правильный / неправильный ответ
	func showAnswerResult(isCorrect: Bool) {
		presenter.switchToNextQuestion()
		switch isCorrect {
		case true:
			correctAnswers += 1
			imageView.layer.borderColor = UIColor.ypGreen.cgColor
			imageView.layer.borderWidth = 8
		case false:
			imageView.layer.borderColor = UIColor.ypRed.cgColor
			imageView.layer.borderWidth = 8
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self = self else { return }
			self.showNextQuestionOrResults()
			self.toggleButtons() // а здесь разблокируем
		}
	}
	/// Функция для перехода к следующему вопросу или результату квиза
	private func showNextQuestionOrResults() {
		self.imageView.layer.borderWidth = 0
		if presenter.isLastQuestion() {
			showRezult()
		} else {
			questionFactory?.requestNextQuestion()
		}
	}
	
	private func showNetworkError(message: String) {
		hideLoadingIndicator() // скрываем индикатор загрузки
		
		let model = QuizResultsViewModel(title: "Ошибка",
										 text: message,
										 buttonText: "Попробовать ещё раз")
		
		alertPresenter?.showAlert(model: model)
	}
	
	private func showRezult() {
		// запускаем сохранение данных
		
		statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
		
		// создаём объекты всплывающего окна
		if let statService = statisticService {
			let date = statService.bestGame.date
			
			let alertViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
				buttonText: "Сыграть ещё раз"
			)
			alertPresenter?.showAlert(model: alertViewModel)
		} else {
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)",
				buttonText: "Сыграть ещё раз"
			)
			alertPresenter?.showAlert(model: alertViewModel)
		}
	}
	
	
	// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter.currentQuestion = currentQuestion
		presenter.noButtonClicked()
	}
	
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter.currentQuestion = currentQuestion
		presenter.yesButtonClicked()
	}
}
