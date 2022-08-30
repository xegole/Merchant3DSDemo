import Foundation
import GirdersSwift
import PromiseKit

/// ApiGateway protocol used for comunication with the backend
protocol ApiGateway {
    /// Sends authentication request
    ///
    /// - Parameter json: The json body of the request
    /// - Returns: Promise with Authentication response
    func sendAuthenticationRequest(json: [String : Any]) -> Promise<AuthenticationResponse>
    
    /// Send a versioning request to the server.
    /// - Parameter json: The versioning request json.
    /// - Returns: Promise with the Versioning response.
    func sendVersioningRequest(json: [String: Any]) -> Promise<ThreeDSVersioningResponse>
}

class AppApiGateway: ApiGateway {
    
    var httpClient: HTTPClient
    
    init(sessionWithCredentials: Bool = false) {
        let configuration = URLSessionConfiguration.default
        let handlers = [DeserialisableHandler()]
        
        if sessionWithCredentials {
            let sessionDelegate = DefaultSessionDelegate()
            let urlSession = URLSession(configuration: configuration,
                                         delegate: sessionDelegate,
                                         delegateQueue: nil)
            httpClient = HTTPClient(urlSession: urlSession, handlers: handlers)
            sessionDelegate.httpClient = httpClient
        } else {
            let urlSession = URLSession(configuration: configuration,
                                         delegate: AppSessionDelegate(),
                                         delegateQueue: nil)
            httpClient = HTTPClient(urlSession: urlSession, handlers: handlers)
        }
    }
    
    func sendAuthenticationRequest(json: [String : Any]) -> Promise<AuthenticationResponse> {
        
        let endpoint = RequestorBackendEndpoint.AuthenticationRequestEndpoint(json)
        let request = Request(endpoint: endpoint)
        
        return Promise { seal in
            httpClient.executeRequest(
                request: request,
                completionHandler: {
                    (result: GirdersSwift.Result<Response<AuthenticationResponse>, Error?>) in
                    switch result {
                    case .Failure(let error):
                        if error!.isCancelled {
                            seal.reject(AppError.appError(title: .ServerError, description: error?.authenticationErrorDescription()))
                        } else {
                            seal.reject(error!)
                        }
                    case .Success(let response):
                        if let authenticationResponse = response.bodyObject {
                            seal.fulfill(authenticationResponse)
                        } else {
                            seal.reject(AppError.appError(title: .InvalidParsing, description: "Failed to parse the body of the response."))
                        }
                    }
            })
        }
    }
    
    func sendVersioningRequest(json: [String: Any]) -> Promise<ThreeDSVersioningResponse> {
        
        let endpoint = RequestorBackendEndpoint.VersioningRequestEndpoint(json)
        let request = Request(endpoint: endpoint)
        
        return Promise { seal in
            httpClient.executeRequest(
                request: request,
                completionHandler: {
                    (result: GirdersSwift.Result<Response<ThreeDSVersioningResponse>, Error?>) in
                    switch result {
                    case .Failure(let error):
                        if error!.isCancelled {
                            seal.reject(AppError.appError(title: .ServerError, description: error?.authenticationErrorDescription()))
                        } else {
                            seal.reject(error!)
                        }
                    case .Success(let response):
                        if let versioningResponse = response.bodyObject {
                            seal.fulfill(versioningResponse)
                        } else {
                            seal.reject(AppError.appError(title: .InvalidParsing, description: "Failed to parse the body of the response."))
                        }
                    }
            })
        }
    }
}
