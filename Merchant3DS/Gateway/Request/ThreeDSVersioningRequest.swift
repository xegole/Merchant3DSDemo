import Foundation

/// Versioning request model.
struct ThreeDSVersioningRequest: Codable {
    let threeDSServerTransID: String?
    let cardholderAccountNumber: String
    let schemeId: String?
    
    init(cardholderAccountNumber: String) {
        self.cardholderAccountNumber = cardholderAccountNumber
        self.schemeId = nil
        self.threeDSServerTransID = nil
    }
    
    func generateJSON() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(self)
        let jsonDict = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] ?? [:]
        return jsonDict
    }
 }
