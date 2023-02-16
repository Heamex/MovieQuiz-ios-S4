import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
	
	
	
// MARK: - Private functions
	private var currentQuestionIndex: Int = 0
	private var correctAnswers: Int = 0
	
	private let questionsAmount: Int = 10
	private var questionFactory: QuestionFactoryProtocol?
	private var currentQuestion: QuizQuestion?
	private	var alertPresenter: AlertPresenter?
	private var statService: StatisticServices?
	
	@IBOutlet private var imageView: UIImageView!
	@IBOutlet private var textLabel: UILabel!
	@IBOutlet private var counterLabel: UILabel!
	@IBOutlet private var noButton: UIButton! // тут оутлеты
	@IBOutlet private var yesButton: UIButton! // на две кнопки
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		statService = StatisticServicesImplementation()
		questionFactory = QuestionFactory(delegate: self)
		questionFactory?.requestNextQuestion()
		alertPresenter = AlertPresenter(delegate: self, vc: self)
		imageView.layer.masksToBounds = true
		imageView.layer.cornerRadius = 20
	}
	
	// MARK: - QuestionFactoryDelegate
	func didReceiveNextQuestion(question: QuizQuestion?) {
		guard let question = question else { return }
		currentQuestion = question
		let viewModel = convert(model: question)
		DispatchQueue.main.async { [weak self] in
			self?.showQuiz(quiz: viewModel)
		}
	}
	// MARK: - AlertPresenterDelegate
	func didAlertButtonPressed() {
		currentQuestionIndex = 0
		questionFactory?.requestNextQuestion()
		correctAnswers = 0
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	/// Включение / выключение кнопок
	private func toggleButtons () {
		noButton.isEnabled.toggle()
		yesButton.isEnabled.toggle()
	}

	/// функция конвертации вопроса в модель
	private func convert(model: QuizQuestion) -> QuizStepViewModel {
		return QuizStepViewModel(
			image: UIImage(named: model.image) ?? UIImage(),
   question: model.text,
   questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
	}
	/// здесь мы заполняем нашу картинку, текст и счётчик данными
	private func showQuiz(quiz step: QuizStepViewModel) {
		imageView.image = step.image
		textLabel.text = step.question
		counterLabel.text = "\(currentQuestionIndex+1)/\(questionsAmount)"
	}
	/// Функция, показывающая реакцию квиза на правильный / неправильный ответ
	private func showAnswerResult(isCorrect: Bool) {
		currentQuestionIndex += 1
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
		if currentQuestionIndex >= questionsAmount {
			showRezult()
		} else {
			questionFactory?.requestNextQuestion()
		}
	}
	
	private func showRezult() {
		// запускаем сохранение данных
		
		statService?.store(correct: correctAnswers, total: questionsAmount)
		
		// создаём объекты всплывающего окна
		if let statService = statService {
			let date = statService.bestGame.date
			
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount) \nколичество сыгранных квизов: \(statService.gamesCount)\nРекорд: \(statService.bestGame.correct)/\(statService.bestGame.total) (\(date.dateTimeString))\nСредняя точность: \(String(format: "%.2f", statService.totalAccurancy*100))%",
				buttonText: "Сыграть ещё раз"
			)
			alertPresenter?.showAlert(model: alertViewModel)
		} else {
			let alertViewModel: QuizResultsViewModel = QuizResultsViewModel (
				title: "Раунд окончен!",
				text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
				buttonText: "Сыграть ещё раз"
			)
			alertPresenter?.showAlert(model: alertViewModel)
		}
	}
	
	
// MARK: - Actions
	@IBAction private func noButtonClicked(_ sender: UIButton) {
		toggleButtons() // тут блокируем кнопки
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = false
		showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
	@IBAction private func yesButtonClicked(_ sender: UIButton) {
		toggleButtons() // и здесь тоже блокируем
		guard let currentQuestion = currentQuestion else {
			return
		}
		let givenAnswer = true
		showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
	}
}
