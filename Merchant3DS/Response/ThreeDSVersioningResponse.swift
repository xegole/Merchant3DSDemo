import Foundation

/// Model of the response of the versioning request.
struct ThreeDSVersioningResponse: Codable, Deserialisable {
    
    let schemeId: String?

    let threeDSServerTransID: String?

    let acsStartProtocolVersion: String?

    let acsEndProtocolVersion: String?

    let dsStartProtocolVersion: String?
    
    let dsEndProtocolVersion: String?
    
    let highestCommonSupportedProtocolVersion: String?

    let errorDetails: ErrorDetails?
    
    let acsInfoInd: [String]?
    
    static func deserialize<T>(from data: Data?) -> T? {
        guard let dataToDeserialize = data,
            let response = try? JSONDecoder().decode(ThreeDSVersioningResponse.self,
                                                     from: dataToDeserialize),
            let versioningResponse = response as? T else {
                return nil
        }
        return versioningResponse
    }
    
}
