import Foundation

struct PaymentDetails {
    
    /// Account number used in the authorisation request for payment transactions.
    var accountNumber: String?
    
    /// Purchase amount in minor units of currency with al puctuation removed.
    var purchaseAmount: String?
    
    /// Minor units of currency as specified in the ISO 4217 currency exponent.
    var purchaseExponent: String?
    
    /// Currency in which purchase amount is expressed.
    var purchaseCurrency: String?
    
    /// Cards Expiration Date in YYMM String format.
    var cardExpiringDate: String?
    
    /// Name of the Cardholder.
    var cardHolderName: String?
    
    /// The category of the message for a specific use case.
    var messageCategory: String?
    
    /// Protocol version identifier.
    var messageVersion: String?
    
    /// The Ui interface which the device supports, as picked by the user.
    var sdkInterface: String?
    
    /// Merchant name assigned by the Acquirer or Payment System.
    var merchantName: String?
    
    /// Country code of the merchant's country
    var merchantCountryCode: String?
    
    /// Message extensions
    var messageExtensions: [MessageExtension]?
    
    // Fields used for delegated authentication
    ///   - threeDSRequestorChallengeInd: Challenge indicator
    var threeDSRequestorChallengeInd: String?
    
    ///   - threeDSRequestorAuthenticationInd: Authentication indicator
    var threeDSRequestorAuthenticationInd: String?
    
    ///   - threeDSReqAuthMethod: Mechanism used by the Cardholder to authenticate to the 3DS Requestor
    var threeDSReqAuthMethod: String?
    
    ///   - threeDSReqAuthTimestamp: Date and time in UTC of the cardholder authentication (YYYYMMDDHHMM)
    var threeDSReqAuthTimestamp: String?
    
    ///   - threeDSReqPriorAuthData: Authentication data received from FIDO authenticator registration
    var threeDSReqPriorAuthData: String?
    
    ///   - threeDSReqPriorAuthMethod: 3-DS Requestor Prior Transaction Authentication Method
    var threeDSReqPriorAuthMethod: String?
    
    ///   - threeDSReqPriorAuthTimestamp: Date and time in UTC of the prior ID&V authentication request (YYYYMMDDHHMM)
    var threeDSReqPriorAuthTimestamp: String?
    
    ///   - threeDSReqPriorRef: Provides additional information to the ACS to determine the best approach for handling a request
    var threeDSReqPriorRef: String?
    
    ///   - threeDSRequestorID: A unique 8-digit identifier assigned by Visa to identify each merchant brand business entity
    var threeDSRequestorID: String?
    
    ///   - threeDSReqAuthData: Authentication data received from FIDO authenticator registration
    var threeDSReqAuthData: String?
    
    init(accountNumber: String? = nil,
         purchaseAmount: String? = nil,
         purchaseExponent: String? = nil,
         purchaseCurrency: String? = nil,
         cardExpiringDate: String? = nil,
         cardHolderName: String? = nil,
         messageCategory: String? = nil,
         messageVersion: String? = nil,
         sdkInterface: String? = nil,
         merchantName: String? = nil,
         merchantCountryCode: String? = nil,
         messageExtensions: [MessageExtension] = [MessageExtension](),
         threeDSRequestorChallengeInd: String? = nil,
         threeDSRequestorAuthenticationInd: String? = nil,
         threeDSReqAuthMethod: String? = nil,
         threeDSReqAuthTimestamp: String? = nil,
         threeDSReqPriorAuthData: String? = nil,
         threeDSReqPriorAuthMethod: String? = nil,
         threeDSReqPriorAuthTimestamp: String? = nil,
         threeDSReqPriorRef: String? = nil,
         threeDSRequestorID: String? = nil,
         threeDSReqAuthData: String? = nil) {
        self.accountNumber = accountNumber
        self.purchaseAmount = purchaseAmount
        self.purchaseExponent = purchaseExponent
        self.purchaseCurrency = purchaseCurrency
        self.cardExpiringDate = cardExpiringDate
        self.cardHolderName = cardHolderName
        self.messageCategory = messageCategory
        self.messageVersion = messageVersion
        self.sdkInterface = sdkInterface
        self.merchantName = merchantName
        self.merchantCountryCode = merchantCountryCode
        self.messageExtensions = messageExtensions
        self.threeDSRequestorChallengeInd = threeDSRequestorChallengeInd
        self.threeDSRequestorAuthenticationInd = threeDSRequestorAuthenticationInd
        self.threeDSReqAuthMethod = threeDSReqAuthMethod
        self.threeDSReqAuthTimestamp = threeDSReqAuthTimestamp
        self.threeDSReqPriorAuthData = threeDSReqPriorAuthData
        self.threeDSReqPriorAuthMethod = threeDSReqPriorAuthMethod
        self.threeDSReqPriorAuthTimestamp = threeDSReqPriorAuthTimestamp
        self.threeDSReqPriorRef = threeDSReqPriorRef
        self.threeDSRequestorID = threeDSRequestorID
        self.threeDSReqAuthData = threeDSReqAuthData
    }
}
