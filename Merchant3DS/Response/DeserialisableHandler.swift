import Foundation
import GirdersSwift

/// Response handler class for the deserialization
class DeserialisableHandler: ResponseHandler {
    func canHandle<T>(responseType type: T) -> Bool {
        guard type is Deserialisable.Type else {
            return false
        }
        return true
    }
    
    func process<T>(responseData: Data) -> T? {
        guard let typeToUse = T.self as? Deserialisable.Type else {
            return nil
        }
        
        let result: T? = typeToUse.deserialize(from: responseData)
        return result
    }
}
