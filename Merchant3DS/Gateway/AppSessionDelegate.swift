import Foundation

/// URL seesion delegate that handles request authentication challenges
class AppSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition,
        URLCredential?) -> Swift.Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust{
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential,credential);
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }
}
