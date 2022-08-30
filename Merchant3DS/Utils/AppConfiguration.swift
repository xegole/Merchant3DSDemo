import Foundation
import GirdersSwift
import ThreeDS_SDK

class AppConfiguration {
    
    let configuration: Configuration
    
    static let instance = AppConfiguration()
    
    private init() {
        let bundle = Bundle(for: type(of: self))
        self.configuration = Configuration(bundle: bundle)
    }
    
    /// Returns the value for a given key from the configuration
    ///
    /// - Parameter key: The key of the value
    /// - Returns: retuns the value as Any
    func value(for key: String) -> Any? {
        let value = configuration.get(key: key)
        return value
    }
    
    /// Returns the Merchant name assigned by the Acquirer or Payment System
    ///
    /// - Returns: String representation of the Merchant name
    /// - Throws: InvalidConfiguration
    func merchantName() throws -> String {
        let tempMerchantName = value(for: "merchantName")
        if let merchantName = tempMerchantName as? String {
            return merchantName
        }
        throw AppError.appError(title: .InvalidConfiguration, description: "Couldn't find a value for key merchantName in the provided configuration.")
    }
    
    /// Returns the Country Code of the Merchant
    ///
    /// - Returns: String representation of the Merchant Country Code
    /// - Throws: AppError.InvalidConfiguration
    func merchantCountryCode() throws -> String {
        let tempMerchantCountryCode = value(for: "merchantCountryCode")
        if let merchantCountryCode = tempMerchantCountryCode as? String {
            return merchantCountryCode
        }
        throw AppError.appError(title: .InvalidConfiguration, description: "Couldn't find a value for key merchantCountryCode in the provided configuration.")
    }
    
    /// Returns the Merchant Category Code
    ///
    /// - Returns: String representation of the Merchant Category Code
    /// - Throws: AppError.InvalidConfiguration
    func mcc() throws -> String {
        let tempMcc = value(for: "mcc")
        if let mcc = tempMcc as? String {
            return mcc
        }
        throw AppError.appError(title: .InvalidConfiguration, description: "Couldn't find a value for key mcc in the provided configuration.")
    }
}
