import Foundation


struct DevelopmentParameters: DevelopmentParametersProtocol {
    let film: FilmProtocol
    let developer: DeveloperProtocol
    let dilution: String
    let temperature: Int
    let iso: Int
    let time: Int
}
