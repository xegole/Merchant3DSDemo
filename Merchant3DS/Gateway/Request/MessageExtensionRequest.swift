import Foundation

/// A struct that contains the parameters used for message extensions in the authentication request
struct MessageExtensionRequest: Codable {
    var name: String
    var id: String
    var criticalityIndicator: Bool
    var data: String
    
    init(name: String = "", id: String = "", criticalityIndicator: Bool = false, data: String = "") {
        self.name = name
        self.id = id
        self.criticalityIndicator = criticalityIndicator
        self.data = data
    }
    
    init(name: String = "", id: String = "", criticalityIndicator: Bool = false, data: [String : Any] = [String : Any]()) {
        self.name = name
        self.id = id
        self.criticalityIndicator = criticalityIndicator
        self.data = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            self.data = String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            fatalError("Couldn't initialize message extension request object")
        }
    }
    
    /// Returns the data string as a dictionary
    /// - Returns: [String : Any] dictionary representation of the data property
    func getDataDictionary() -> [String : Any]? {
        guard !self.data.isEmpty else {
            return nil
        }
        let data = Data(self.data.utf8)
        
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                return jsonDict
            } else {
                return nil
            }
        } catch let error {
            print("Failed to load data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Updates the value of the data property
    /// - Parameter dataDictionary: [String : Any] dictionary that will be converted into a string and used as a new value for the data property
    mutating func saveData(dataDictionary: [String : Any]?) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataDictionary ?? [:], options: [])
            data = String(data: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print("Failed to save data: \(error.localizedDescription)")
        }
        
    }
    
    /// Generates a JSON String representation of the class
    ///
    /// - Returns: JSON String representation of the class
    /// - Throws: SDK Runtime Error
    func JSONDictionary() throws -> [String : Any] {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(self)
        let jsonDict = (try? JSONSerialization.jsonObject(with: jsonData)) as? [String: Any] ?? [:]
        return jsonDict
    }
}
