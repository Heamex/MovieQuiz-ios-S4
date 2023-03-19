////
////  MovieQuizTests.swift
////  MovieQuizTests
////
////  Created by Nikita Belov on 10.03.23.
////
//
//import XCTest
//
//struct ArithmeticOperations {
//	func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//			handler (num1 + num2)
//		}
//	}
//
//	func substruction(num1: Int, num2:Int, handler: @escaping(Int) -> Void){
//		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//			handler (num1 - num2)
//		}
//
//		func multiplication2(num1: Int, num2: Int) -> Int {
//			return num1 * num2
//		}
//		func multiplicatin(num1: Int, num2: Int, hendler: @escaping (Int) -> Void) {
//			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//				hendler (num1 * num2)
//			}
//		}
//	}
//}
//
//final class MovieQuizTests: XCTestCase {
//
//	func testAddition() throws {
//		// Given
//		let arithmeticOperations = ArithmeticOperations()
//		let num1 = 1
//		let num2 = 2
//
//		// When
//		let expectation = expectation(description: "Addition function expectation")
//		arithmeticOperations.addition(num1: num1, num2: num2) { result in
//			// Then
//			XCTAssertEqual(result, 3)
//			expectation.fulfill()
//		}
//		waitForExpectations(timeout: 2)
//	}
//
//}
