//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 28.01.23.
//

import Foundation

struct randomQuestion{
	let question: String
	let answer: Bool
}

enum QuestionFactoryError: String, Error {
	case failureLoadImage
}

extension QuestionFactoryError: LocalizedError {
	
	var errorDescription: String? {
		switch self {
		case .failureLoadImage:
			return NSLocalizedString("Ошибка загрузки картинки", comment: "RU")
		}
	}
}

final class QuestionFactory: QuestionFactoryProtocol {
	private let moviesLoader: MoviesLoading
	private weak var delegate: QuestionFactoryDelegate?
	private var movies: [MostPopularMovie] = []
	
	init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
		self.moviesLoader = moviesLoader
		self.delegate = delegate
	}
	
	func loadData() {
		moviesLoader.loadMovies { [weak self] result in
			DispatchQueue.main.async {
				guard let self = self else { return }
				switch result {
				case .success(let mostPopularMovies):
					self.movies = mostPopularMovies.items
					self.delegate?.didLoadDataFromServer()
				case .failure(let error):
					self.delegate?.didFailToLoadData(with: error)
				}
			}
		}
	}
	
	func requestNextQuestion() {
		DispatchQueue.global().async { [weak self] in
			guard let self = self else { return }
			let index = (0..<self.movies.count).randomElement() ?? 0
			
			guard let movie = self.movies[safe: index] else { return }
			
			var imageData = Data()
			
			do {
				imageData = try Data(contentsOf: movie.resizedImageURL)
			} catch {
				DispatchQueue.main.async {
					print("Failed to load image")
					self.delegate?.didFailToLoadData(with: QuestionFactoryError.failureLoadImage)
				}
			}
			
			let rating = Float(movie.rating) ?? 0
			
			let generated = generateQuestionWith(raiting: rating)
			let text = generated.question
			let correctAnswer = generated.answer
			
			
			
			let question = QuizQuestion(image: imageData,
										text: text,
										correctAnswer: correctAnswer)
			
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.delegate?.didReceiveNextQuestion(question: question)
			}
		}
	}
}

private func generateQuestionWith(raiting:Float) -> randomQuestion {
	
	let answers = [
		"Рейтинг этого фильма меньше 8?": raiting < 8,
		"Рейтинг этого фильма больше 8?": raiting > 8,
		"Рейтинг этого фильма меньше 9?": raiting < 9 ]
	let r = answers.randomElement()!.key
	
	return randomQuestion(question: r, answer: answers[r]!)
}
