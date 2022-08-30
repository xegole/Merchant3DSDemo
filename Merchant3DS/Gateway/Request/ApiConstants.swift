import Foundation
import GirdersSwift

/// Constants used in the api gateway
struct ApiConstants {
    
    static let JSONHeader = "application/json"
    static let contentType = "Content-Type"
    
    static let baseURL = Configuration.sharedInstance["baseURL"] as! String
    
}
