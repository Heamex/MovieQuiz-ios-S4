//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 02.03.23.
//

import UIKit

struct MostPopularMovies: Codable {
	let errorMessage: String
	let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
	let title: String
	let rating: String
	let imageURL: URL
	
	var resizedImageURL: URL {
		let urlString = imageURL.absoluteString
		let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
		if let newURL = URL(string: imageUrlString) {
			return newURL
		} else {
			return imageURL
		}
		
	}
	
	private enum CodingKeys: String, CodingKey {
		case title = "fullTitle"
		case rating = "imDbRating"
		case imageURL = "image"
	}
}

/// Отвечает за загрузку данных по URL
struct NetworkClient {
	
	private enum NetworkError: Error {
		case codeError
	}
	
	func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
		let request = URLRequest(url: url)
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			// Проверяем, пришла ли ошибка
			if let error = error {
				handler(.failure(error))
				return
			}
			
			// Проверяем, что нам пришёл успешный код ответа
			if let response = response as? HTTPURLResponse,
			   response.statusCode < 200 || response.statusCode >= 300 {
				handler(.failure(NetworkError.codeError))
				return
			}
			
			// Возвращаем данные
			guard let data = data else { return }
			handler(.success(data))
		}
		
		task.resume()
	}
}
