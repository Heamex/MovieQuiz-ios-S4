//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Nikita Belov on 14.03.23.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
	func highlightImageBorder(isCorrect: Bool) {
	}
	
	func showAlert(model: MovieQuiz.QuizResultsViewModel) {
	}
	
	func showQuiz(quiz step: MovieQuiz.QuizStepViewModel) {
	}
	
	func showNetworkError(message: String) {
	}
	
	func didAlertButtonPressed() {
	}
	
	func toggleButtons() {
	}
}
final class MovieQuizPresenterTests: XCTestCase {
	func testPresenterConvertModel() throws {
		let viewControllerMock = MovieQuizViewControllerMock()
		let sut = MovieQuizPresenter(viewController: viewControllerMock)
		
		let emptyData = Data()
		let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
		let viewModel = sut.convert(model: question)
		
		 XCTAssertNotNil(viewModel.image)
		XCTAssertEqual(viewModel.question, "Question Text")
		XCTAssertEqual(viewModel.questionNumber, "1/10")
	}
} 
