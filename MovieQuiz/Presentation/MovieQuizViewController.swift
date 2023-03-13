import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
	
	// MARK: - Приватные поля
	
	// предварительная настройка статусбара
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	private var presenter = MovieQuizPresenter()
	
	var alertPresenter: AlertPresenter?
	
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var textLabel: UILabel!
	@IBOutlet var counterLabel: UILabel!
	@IBOutlet var noButton: UIButton! // тут оутлеты
	@IBOutlet var yesButton: UIButton! // на две кнопки
	
	// MARK: - Запуск
	
	override func viewDidLoad() {
		super.viewDidLoad()
		alertPresenter = AlertPresenter(delegate: self)
		
		presenter.statisticService = StatisticServicesImplementation()
		presenter.viewController = self 
		presenter.questionFactory = QuestionFactory(moviesLoader: MovesLoader(), delegate: presenter)
		presenter.questionFactory?.loadData()
		
		showLoadingIndicator()
		toggleButtons()
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 20
	}
	
	// MARK: - AlertPresenterDelegate
	
	func didAlertButtonPressed() {
		presenter.didAlertButtonPressed()
	}
	
	// Запускаем индикатор загрузки
	func showLoadingIndicator() {
		activityIndicator.startAnimating()
	}
	
	// Выключаем индикатор загрузки
	func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}
	
	func toggleButtons () { // выключатель кнопок
		noButton.isEnabled.toggle()
		yesButton.isEnabled.toggle()
	}
	
	func showQuiz(quiz step: QuizStepViewModel) { 	// здесь мы заполняем view модель данными
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = presenter.counterOfQuestions()
	}
	
	// Показываем сетевую ошибку
	func showNetworkError(message: String) {
		hideLoadingIndicator() // скрываем индикатор загрузки
		
		let model = QuizResultsViewModel(title: "Ошибка",
										 text: message,
										 buttonText: "Попробовать ещё раз")
		alertPresenter?.showAlert(model: model)
	}
	
	// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter.noButtonClicked()
	}
	
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter.yesButtonClicked()
	}
}
