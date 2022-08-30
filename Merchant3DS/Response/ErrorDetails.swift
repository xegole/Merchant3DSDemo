import Foundation

/// ThreeDS Protocol Error.
struct ErrorDetails: Codable {
    let threeDSServerTransID: String
    let errorCode: String
    let errorComponent: String
    let errorDescription: String
}
