
import Foundation

protocol DataService {
    associatedtype Film: FilmProtocol
    associatedtype Developer: DeveloperProtocol
    associatedtype Fixer: FixerProtocol

    var films: [Film] { get }
    var developers: [Developer] { get }
    var fixers: [Fixer] { get }

    func getAvailableDilutions(filmId: String, developerId: String) -> [String]
    func getAvailableISOs(filmId: String, developerId: String, dilution: String) -> [Int]
    func calculateDevelopmentTime(parameters: DevelopmentParameters) -> Int?
    func refreshData()
}
