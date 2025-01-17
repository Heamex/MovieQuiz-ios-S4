//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Nikita Belov on 12.03.23.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
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
	   sleep(2)
	   let indexLabel = app.staticTexts["Index"]
	   XCTAssertEqual(indexLabel.label, "2/10")
   }

   func testGameFinish() {
	   sleep(1)
	   for _ in 1...10 {
		   app.buttons["No"].tap()
		   sleep(2)
	   }

	   let alert = app.alerts["GameResults"]

	   XCTAssertTrue(alert.exists)
	   XCTAssertTrue(alert.label == "Этот раунд окончен!")
	   XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
   }

   func testCorrectQestionsCount() {
	   sleep(2)
	   for _ in 1...10 {
		   app.buttons["No"].tap()
		   sleep(2)
	   }

	   sleep(1)
	   let indexLabel = app.staticTexts["Index"]

	   XCTAssertEqual(indexLabel.label, "10/10")
   }

   func testAlertDismiss() {
	   sleep(2)
	   for _ in 1...10 {
		   app.buttons["No"].tap()
		   sleep(2)
	   }

	   let alert = app.alerts["GameResults"]
	   alert.buttons.firstMatch.tap()

	   sleep(2)

	   let indexLabel = app.staticTexts["Index"]

	   XCTAssertFalse(alert.exists)
	   XCTAssertTrue(indexLabel.label == "1/10")
   }
}
