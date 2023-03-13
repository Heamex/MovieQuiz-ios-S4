import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
	
	
	
	// MARK: - Private functions
	private var correctAnswers: Int = 0
	
	private	var alertPresenter: AlertPresenter?
	private var statisticService: StatisticServices?
	private var presenter = MovieQuizPresenter()
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet private var textLabel: UILabel!
	@IBOutlet private var counterLabel: UILabel!
	@IBOutlet var noButton: UIButton! // тут оутлеты
	@IBOutlet var yesButton: UIButton! // на две кнопки
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		statisticService = StatisticServicesImplementation()
		presenter.viewController = self
		presenter.questionFactory = QuestionFactory(moviesLoader: MovesLoader(), delegate: presenter)
		showLoadingIndicator()
		presenter.questionFactory?.loadData()
		alertPresenter = AlertPresenter(delegate: self)
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 20
	}
	
	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		presenter.didReceiveNextQuestion(question: question)
	}
	
	func didLoadDataFromServer() {
		hideLoadingIndicator()
		presenter.questionFactory?.requestNextQuestion()
	}
	
	func didFailToLoadData(with error: Error) {
		showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
	}
	
	// MARK: - AlertPresenterDelegate
	func didAlertButtonPressed() {
		presenter.resetQuestionIndex()
		presenter.questionFactory?.loadData()
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
	

	/// здесь мы заполняем нашу картинку, текст и счётчик данными
		func showQuiz(quiz step: QuizStepViewModel) {
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak presenter] in
			guard let presenter = presenter else { return }
			presenter.showNextQuestionOrResults()
			presenter.toggleButtons() // а здесь разблокируем
		}
	}
	
	
	private func showNetworkError(message: String) {
		hideLoadingIndicator() // скрываем индикатор загрузки
		
		let model = QuizResultsViewModel(title: "Ошибка",
										 text: message,
										 buttonText: "Попробовать ещё раз")
		
		alertPresenter?.showAlert(model: model)
	}
	
	func showRezult() {
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
		presenter.noButtonClicked()
	}
	
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter.yesButtonClicked()
	}
}
