import UIKit

final class MovieQuizViewController: UIViewController {
	
	// MARK: - Приватные поля
	// предварительная настройка статусбара
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	@IBOutlet private var activityIndicator: UIActivityIndicatorView!
	private var presenter: MovieQuizPresenter?
	
	// MARK: - Публичные поля
	
	@IBOutlet private  var imageView: UIImageView! // картинка
	@IBOutlet private var textLabel: UILabel! // лейбл вопроса
	@IBOutlet private var counterLabel: UILabel! // лейбл счётчика
	@IBOutlet private var noButton: UIButton! // тут оутлеты
	@IBOutlet private var yesButton: UIButton! // на две кнопки
	
	// MARK: - При запуске приложения:
	
	override func viewDidLoad() {
		super.viewDidLoad()
		presenter = MovieQuizPresenter(viewController: self)
		
		showLoadingIndicator()
		toggleButtons()
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 20
	}
	
	// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		presenter?.noButtonClicked()
	}
	
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		presenter?.yesButtonClicked()
	}
}

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
	// Запускаем индикатор загрузки
	func showLoadingIndicator() {
		activityIndicator.startAnimating()
	}
	
	// Выключаем индикатор загрузки
	func hideLoadingIndicator() {
		activityIndicator.stopAnimating()
	}
	
	// Обновляем UI получив данные из модели
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
	
	// Показываем результат ответа пользователя
	func highlightImageBorder(isCorrect: Bool) {
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
	
	func showAlert(model:QuizResultsViewModel) { // Показ алерта
		
		let alert = UIAlertController(title: model.title,
									  message: model.text,
									  preferredStyle: .alert)
		let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.presenter?.didAlertButtonPressed()
		}
		alert.addAction(action)
		alert.view.accessibilityIdentifier = "GameResults" //ДЛЯ ТЕСТОВ__
		present(alert, animated: true, completion: nil)
	}

	func toggleButtons () { // выключатель кнопок
		noButton.isEnabled.toggle()
		yesButton.isEnabled.toggle()
	}
}
