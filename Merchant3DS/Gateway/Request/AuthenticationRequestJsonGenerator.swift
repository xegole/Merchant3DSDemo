import Foundation
import ThreeDS_SDK

/// A class which prepares all the parameters needed for the Authentication Request
class AuthenticationRequestJsonGenerator {
    
    static func aresModelFrom(transaction: Transaction?,
                              paymentDetails: PaymentDetails,
                              deviceChannel: String,
                              threeRIInd: String? = nil) throws -> AuthenticationRequest {
        let deviceChannel = deviceChannel
        let messageType = "AReq"
        let sdkMaxTimeout = "05"
        
        let appConfiguration = AppConfiguration.instance
        
        var deviceRender: DeviceRenderOptions?
        if let interfaceValue = paymentDetails.sdkInterface {
            let sdkInterface = apiValueOf(index: interfaceValue)
            let sdkUiTypeValues = sdkUiType(renderUI: sdkInterface)
            deviceRender = DeviceRenderOptions(sdkInterface: sdkInterface,
                                               sdkUiType: sdkUiTypeValues)
        }
        
        let mcc = try appConfiguration.mcc()
        
        var cardExpiryDate = paymentDetails.cardExpiringDate?.replacingOccurrences(of: "/", with: "")

        if let cardExpDate = cardExpiryDate, cardExpDate.count == 4 {
            cardExpiryDate = String(cardExpDate.suffix(2)) + String(cardExpDate.prefix(2))
        }
        
        let acctNumber = paymentDetails.accountNumber
        let cardholderName = paymentDetails.cardHolderName
        
        var messageCategory: String?
        if let categoryValue = paymentDetails.messageCategory {
            messageCategory = apiValueOf(index: categoryValue)
        }
            
        let purchaseAmount = paymentDetails.purchaseAmount?.replacingOccurrences(of: ".", with: "")
        let purchaseCurrency = paymentDetails.purchaseCurrency
        let purchaseExponent = paymentDetails.purchaseExponent
        let merchantName = paymentDetails.merchantName
        let merchantCountryCode = paymentDetails.merchantCountryCode
        let purchaseDate = getPurchaseDate()
        
        var messageVersion: String?
        var sdkAppID: String?
        var sdkTransID: String?
        var sdkReferenceNumber: String?
        var sdkEncData: String?
        var sdkEphemPubKeyString: String?
        var sdkEphemPubKeyJSON: SDKEphemPubKey?
        
        if let transaction = transaction {
            let transactionParameters = try transaction.getAuthenticationRequestParameters()
            messageVersion = transactionParameters.getMessageVersion()
            sdkAppID = transactionParameters.getSDKAppID()
            sdkTransID = transactionParameters.getSDKTransactionId()
            sdkReferenceNumber = transactionParameters.getSDKReferenceNumber()
            sdkEncData = transactionParameters.getDeviceData()
            sdkEphemPubKeyString = transactionParameters.getSDKEphemeralPublicKey()
            if let sdkEphemPubKeyString = sdkEphemPubKeyString,
               let ephemData = sdkEphemPubKeyString.data(using: .utf8) {
                sdkEphemPubKeyJSON = try JSONDecoder().decode(SDKEphemPubKey.self, from: ephemData)
            } else {
                throw AppError.appError(title: .CannotConvertJsonStringToData, description: "Failed to decode SDK Ephemeral Public Key Data.")
            }
        } else {
            messageVersion = paymentDetails.messageVersion
        }
        
        let threeDSRequestorChallengeInd = paymentDetails.threeDSRequestorChallengeInd
        let threeDSRequestorAuthenticationInd = paymentDetails.threeDSRequestorAuthenticationInd
        let threeDSReqAuthMethod = paymentDetails.threeDSReqAuthMethod
        let threeDSReqAuthTimestamp = paymentDetails.threeDSReqAuthTimestamp
        let threeDSReqPriorAuthData = paymentDetails.threeDSReqPriorAuthData
        let threeDSReqPriorAuthMethod = paymentDetails.threeDSReqPriorAuthMethod
        let threeDSReqPriorAuthTimestamp = paymentDetails.threeDSReqPriorAuthTimestamp
        let threeDSReqPriorRef = paymentDetails.threeDSReqPriorRef
        let threeDSRequestorID = paymentDetails.threeDSRequestorID
        let threeDSReqAuthData = paymentDetails.threeDSReqAuthData
        
        let model = AuthenticationRequest(cardExpiryDate: cardExpiryDate,
                                          acctNumber: acctNumber,
                                          cardholderName: cardholderName,
                                          deviceChannel: deviceChannel,
                                          deviceRenderOptions: deviceRender,
                                          mcc: mcc,
                                          merchantCountryCode: merchantCountryCode,
                                          merchantName: merchantName,
                                          messageCategory: messageCategory,
                                          messageType: messageType,
                                          messageVersion: messageVersion,
                                          purchaseAmount: purchaseAmount,
                                          purchaseCurrency: purchaseCurrency,
                                          purchaseExponent: purchaseExponent,
                                          purchaseDate: purchaseDate,
                                          sdkAppID: sdkAppID,
                                          sdkMaxTimeout: sdkMaxTimeout,
                                          sdkEphemPubKey: sdkEphemPubKeyJSON,
                                          sdkReferenceNumber: sdkReferenceNumber,
                                          sdkTransID: sdkTransID,
                                          sdkEncData: sdkEncData,
                                          threeRIInd: threeRIInd,
                                          threeDSReqAuthData: threeDSReqAuthData,
                                          threeDSRequestorChallengeInd: threeDSRequestorChallengeInd,
                                          threeDSRequestorAuthenticationInd: threeDSRequestorAuthenticationInd,
                                          threeDSReqAuthMethod: threeDSReqAuthMethod,
                                          threeDSReqAuthTimestamp: threeDSReqAuthTimestamp,
                                          threeDSReqPriorAuthData: threeDSReqPriorAuthData,
                                          threeDSReqPriorAuthMethod: threeDSReqPriorAuthMethod,
                                          threeDSReqPriorAuthTimestamp: threeDSReqPriorAuthTimestamp,
                                          threeDSReqPriorRef: threeDSReqPriorRef,
                                          threeDSRequestorID: threeDSRequestorID)
        return model
    }
    
    /// Prepares and assignes the parameters needed for the  Authentication Request
    ///
    /// - Parameters:
    ///   - transaction: Transaction object which contains needed parameters.
    ///   - paymentDetails: PaymentDetails which contains needed parameters.
    /// - Returns: JSON String of the AuthenticationRequestModel
    /// - Throws: SDK Runtime
    static func generateAppAResJson(transaction: Transaction,
                             paymentDetails: PaymentDetails) throws -> [String : Any] {
    
        let model = try aresModelFrom(transaction: transaction, paymentDetails: paymentDetails, deviceChannel: "01")
        
        var json = try model.JSONDictionary()
        if let messageExtensions = paymentDetails.messageExtensions, messageExtensions.count > 0 {
            json = appendMessageExtensionsToJson(aResJson: json, messageExtensions: messageExtensions)
        }
        return json
    }
    
    static func generateThreeRiAResJson(paymentDetails: PaymentDetails, threeRIInd: String) throws -> [String : Any] {
    
        let model = try aresModelFrom(transaction: nil,
                                      paymentDetails: paymentDetails,
                                      deviceChannel: "03",
                                      threeRIInd: threeRIInd)
        var json = try model.JSONDictionary()
        if let messageExtensions = paymentDetails.messageExtensions, messageExtensions.count > 0 {
            json = appendMessageExtensionsToJson(aResJson: json, messageExtensions: messageExtensions)
        }
        return json
    }
    
    private static func appendMessageExtensionsToJson(aResJson: [String : Any], messageExtensions: [MessageExtension]) -> [String : Any] {
        var json = aResJson
        var messageExtensionRequests = [[String:Any]]()
        
        messageExtensions.forEach({ messageExtension in
            var messageExtensionRequest = messageExtension.messageExtensionRequest
            if messageExtension.messageExtensionType == .custom {
                messageExtensionRequest.data = messageExtensionRequest.data.replacingOccurrences(of: "\n", with: "")
                messageExtensionRequest.data = messageExtensionRequest.data.replacingOccurrences(of: "\t", with: "")
            }
            do {
                var jsonDict = try messageExtensionRequest.JSONDictionary()
                jsonDict["data"] = messageExtensionRequest.getDataDictionary()
                messageExtensionRequests.append(jsonDict)
            } catch {
                print("Error parsing data to JSON")
            }
            
        })
        
        json["messageExtension"] = messageExtensionRequests
        return json
    }
    
    /// Time and Date when the transaction was made.
    ///
    /// - Returns: The time and date when that transaction was made expressed in UTC.
    static func getPurchaseDate() -> String {
        let date = Date()
        return date.toUTCString()
    }
    
    static func sdkUiType(renderUI: String) -> [String] {
        switch renderUI {
        case "01":
            return ["01", "02", "03", "04"]
        case "02":
            return ["01", "02", "03", "04", "05"]
        default:
            return ["01", "02", "03", "04", "05"]
        }
    }
    
    static func apiValueOf(index: String) -> String {
        switch index {
        case "0":
            return "01"
        case "1":
            return "02"
        default:
            return "03"
        }
    }
}
