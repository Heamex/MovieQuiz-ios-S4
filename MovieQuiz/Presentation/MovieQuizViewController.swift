import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
	
	// MARK: - Приватные поля
	
	// предварительная настройка статусбара
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	private var presenter: MovieQuizPresenter?
		
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var textLabel: UILabel!
	@IBOutlet var counterLabel: UILabel!
	@IBOutlet var noButton: UIButton! // тут оутлеты
	@IBOutlet var yesButton: UIButton! // на две кнопки
	
	// MARK: - Запуск
	
	override func viewDidLoad() {
		super.viewDidLoad()
		presenter = MovieQuizPresenter(viewController: self)
		
		showLoadingIndicator()
		toggleButtons()
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 20
	}
	
	// MARK: - AlertPresenterDelegate
	
	func didAlertButtonPressed() {
		presenter?.didAlertButtonPressed()
	}
	// из презентера
	func showAlert(model:QuizResultsViewModel) {
		
		let alert = UIAlertController(title: model.title,
									  message: model.text,
									  preferredStyle: .alert)
		alert.view.accessibilityIdentifier = "Game results" //ДЛЯ ТЕСТОВ__
		let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.didAlertButtonPressed()
		}
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
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
		counterLabel.text = presenter?.counterOfQuestions()
	}
	
	// Показываем сетевую ошибку
	func showNetworkError(message: String) {
		hideLoadingIndicator() // скрываем индикатор загрузки
		
		let model = QuizResultsViewModel(title: "Ошибка",
										 text: message,
										 buttonText: "Попробовать ещё раз")
		showAlert(model: model)
	}
	
	func highlightImageBorder(isCorrect: Bool) { // Показываем результат ответа пользователю
		presenter?.switchToNextQuestion()
		switch isCorrect {
		case true:
			presenter?.correctAnswers += 1
			imageView.layer.borderColor = UIColor.ypGreen.cgColor
			imageView.layer.borderWidth = 8
		case false:
			imageView.layer.borderColor = UIColor.ypRed.cgColor
			imageView.layer.borderWidth = 8
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak presenter] in
			guard let presenter = presenter else { return }
			self.imageView.layer.borderWidth = 0
			presenter.showNextQuestionOrResults()
		}
	}
	
//	hideLoadingIndicator()
	
	// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter?.noButtonClicked()
	}
	
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter?.yesButtonClicked()
	}
}

// .hideLoadingIndicator()
