import UIKit

protocol StatisticServices {
	var totalAccurancy: Double {get}
	var gamesCount: Int {get}
	var bestGame: GameRecord {get}
	func store(correct count: Int, total amount: Int)
}


final class StatisticServicesImplementation: StatisticServices {
	private let userDefaults = UserDefaults.standard // тут мы немного упрощаем себе синтаксис
	
	private enum Keys: String { // перечисляем все поля структуры чтобы быстро и без ошибок к ним обращаться
		case correct, total, bestGame, gamesCount
	}
	
	var totalAccurancy: Double { // точность
		get { // при попытке получить запрашивает из хранилища данные по ключу "total"
			userDefaults.double(forKey: Keys.total.rawValue)
		}
		set { // при попытке установить сохраняет в хранилище данные по ключу "total"
			userDefaults.set(newValue, forKey: Keys.total.rawValue)
		}
	}
	
	var gamesCount: Int { // количество игр
		get { // получаем
			userDefaults.integer(forKey: Keys.gamesCount.rawValue)
		}
		set { // сохраняем
			userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
		}
	}
	
	var bestGame: GameRecord {
		get { // получение рекордной игры
			guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
				  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
				return .init(correct: 0, total: 0, date: Date()) // если не получилось, возвращаем дефолтную структуру
			}
			return record
		}
		set { // сохраняем новый рекорд
			guard let data = try? JSONEncoder().encode(newValue) else {
				print("Невозможно сохранить результат")
				return
			}
			userDefaults.set(data, forKey: Keys.bestGame.rawValue) // тут
		}
	}
	
	func store(correct count: Int, total amount: Int) { // функия записи нового рекорда
		
		let newGame = GameRecord(correct: count, total: amount, date: Date())
		// принимает к-во правильных, общее к-во ответов, текущую дату
		if bestGame < newGame {
			bestGame = newGame
		}
		if gamesCount != 0 { // если игры уже есть в памяти, то получаем срзнач между старой точностью и новой
			totalAccurancy = (totalAccurancy + Double(newGame.correct) / Double(newGame.total))/2.0
		} else { // если не играли, просто записываем текущую точность
			totalAccurancy = (Double(newGame.correct) / Double(newGame.total))
		} // и обязательно увеличиваем к-во игр
		gamesCount += 1
	}
}
