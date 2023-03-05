//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Nikita Belov on 04.03.23.
//

import UIKit

protocol MoviesLoading {
	func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MovesLoader: MoviesLoading {
	private let networkClient = NetworkClient()
	
	// MARK: - URL
	private var mostPopularMoviesUrl: URL {
		// Если мы не смогли преобразовать строку в URL, то приложение упадёт с ошибкой
		guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_9q1iv19u") else {
			preconditionFailure("Unable to construct mostPopularMoviesUrl")
		}
		return url
	}
	
	func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
		networkClient.fetch(url: mostPopularMoviesUrl) { result in
			switch result {
			case .success(let data):
				do {
					let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
					handler(.success(mostPopularMovies))
				} catch {
					handler(.failure(error))
				}
			case .failure(let error):
				handler(.failure(error))
			}
		}
	}
}
