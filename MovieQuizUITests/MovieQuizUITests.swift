//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Nikita Belov on 12.03.23.
//

import XCTest

class MovieQuizUITests: XCTestCase {
	// swiftlint:disable:next implicitly_unwrapped_optional
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		app = XCUIApplication()
		app.launch()
		
		// это специальная настройка для тестов: если один тест не прошёл,
		// то следующие тесты запускаться не будут; и правда, зачем ждать?
		continueAfterFailure = false
	}
	override func tearDownWithError() throws {
		try super.tearDownWithError()
		
		app.terminate()
		app = nil
	}
	
	func testYesButton() {
		sleep(3)
		let firstPoster = app.images["Poster"]
		let firstPosterData = firstPoster.screenshot().pngRepresentation
		app.buttons["Yes"].tap()
		
		sleep(3)
		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation
		
		XCTAssertNotEqual(firstPosterData, secondPosterData)
	}
	func testNoButton() {
		sleep(3)
		let firstPoster = app.images["Poster"]
		let firstPosterData = firstPoster.screenshot().pngRepresentation
		app.buttons["No"].tap()
		
		sleep(3)
		let secondPoster = app.images["Poster"]
		let secondPosterData = secondPoster.screenshot().pngRepresentation
		
		XCTAssertNotEqual(firstPosterData, secondPosterData)
	}
	
	func testTextLabel() {
		app.buttons["Yes"].tap()
		sleep(1)
		let indexLabel = app.staticTexts["Index"]
		XCTAssertEqual(indexLabel.label, "2/10")
	}

	func testGameFinish() {
		for _ in 1...10 {
			app.buttons["No"].tap()
					sleep(1)
		}
		sleep(1)
		let alert = app.alerts["Game results"]
		XCTAssertEqual(alert.label, "Раунд окончен!")
		XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
		XCTAssertTrue(alert.exists)
	}
}
