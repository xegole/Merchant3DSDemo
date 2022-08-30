import Foundation
import GirdersSwift

/// Generator for the Requestor Backend request
struct RequestorBackendRequestsGenerator: RequestGenerator {
    public func generateRequest(withMethod method: HTTPMethod) -> MutableRequest {
        return request(withMethod: method) |> withJsonSupport |> withBasicAuth
    }

    public func withJsonSupport(request: MutableRequest) -> MutableRequest {
        var request = request
        let jsonHeader = [ApiConstants.contentType : ApiConstants.JSONHeader]
        request.updateHTTPHeaderFields(headerFields: jsonHeader)
        return request
    }
    
    public func withBasicAuth(request: MutableRequest) -> MutableRequest {
        let usernameOptional: String? = "user"
        let passwordOptional: String? = "pass"
        
        guard let username = usernameOptional,
            let password = passwordOptional else {
                return request
        }
        
        if username.isEmpty || password.isEmpty {
            return request
        }
        
        var mutableRrequest = request
        guard let authorization = String(format: "%@:%@", username, password).data(using: .utf8) else {
            return request
        }
        let basicAuthorization = String(format: "Basic %@", authorization.base64EncodedString())
        mutableRrequest.updateHTTPHeaderFields(headerFields: ["Authorization": basicAuthorization])
        return mutableRrequest
    }
}
