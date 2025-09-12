import Foundation

protocol DevelopmentParametersProtocol {
    var film: FilmProtocol { get }
    var developer: DeveloperProtocol { get }
    var iso: Int { get }
    var dilution: String { get }
    var temperature: Int { get }
    var time: Int { get }
}