//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 03.02.23.
//

import UIKit

final class AlertPresenter {
	private weak var delegate: AlertPresenterDelegate?
	
	init(delegate: AlertPresenterDelegate) {
		self.delegate = delegate
	}
	
	func showAlert(model:QuizResultsViewModel) {
		
		let alert = UIAlertController(title: model.title,
									  message: model.text,
									  preferredStyle: .alert)
		let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
			guard let self = self else { return }
			self.delegate?.didAlertButtonPressed()
		}
		alert.addAction(action)
		delegate?.present(alert, animated: true, completion: nil)
	}
}
