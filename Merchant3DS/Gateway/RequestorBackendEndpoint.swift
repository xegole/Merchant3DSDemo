import Foundation
import GirdersSwift


/// Determines the type of the endpoint used.
///
/// - AuthenticationRequestEndpoint: The request endpoint for the transaction verification.
enum RequestorBackendEndpoint {
    case AuthenticationRequestEndpoint([String : Any])
    case VersioningRequestEndpoint([String: Any])
}

/// Endpoint used for creating requests that communicate with the requestor backend.
extension RequestorBackendEndpoint : ServiceEndpoint {
    var path: String {
        return ""
    }
    
    var method: HTTPMethod {
        get {
            return .POST
        }
    }
    
    var parameters: Any? {
        switch self {
        case .AuthenticationRequestEndpoint(let json), .VersioningRequestEndpoint(let json):
            return json
        }
    }
    
    var requestGenerator: RequestGenerator {
        get {
            return RequestorBackendRequestsGenerator()
        }
    }
    
    var baseURL: URL {
        get {
            switch self {
            case .AuthenticationRequestEndpoint:
                guard let url = URL(string: "Backend URL") else {
                    return URL(string: "no-url")!
                }
                return url
            case .VersioningRequestEndpoint:
                guard let url = URL(string: "Backend URL") else {
                    return URL(string: "no-url")!
                }
                let versioningUrlString = url.absoluteString.replacingOccurrences(of: "/buy", with: "/versioning")
                guard let versioningUrl = URL(string: versioningUrlString) else {
                    return URL(string: "no-url")!
                }
                return versioningUrl
            }
        }
    }
}
