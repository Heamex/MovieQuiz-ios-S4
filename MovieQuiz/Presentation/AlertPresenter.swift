//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 03.02.23.
//

import UIKit

class AlertPresenter {
	weak var delegate: AlertPresenterDelegate?
	weak var viewCotnroller: UIViewController?
	
	init(delegate: AlertPresenterDelegate, vc: UIViewController) {
		self.delegate = delegate
		self.viewCotnroller = vc
	}
	
	func showAlert(model:QuizResultsViewModel){
		
		let alert = UIAlertController(title: model.title,
									  message: model.text,
									  preferredStyle: .alert)
		let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.didAlertButtonPressed()
		}
		alert.addAction(action)
		viewCotnroller?.present(alert, animated: true, completion: nil)
	}
}
