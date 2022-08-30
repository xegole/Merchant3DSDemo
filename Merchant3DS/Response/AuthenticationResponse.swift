import Foundation

/// Defines the value of the Transaction Status
///
/// - AuthenticationSuccessful: Authentication/ Account Verification Successful
/// - TransactionDenied: Not Authenticated /Account Not Verified
/// - TechnicalProblem: Authentication/ Account Verification Could Not Be Performed, Technical or
///   other problem
/// - AttemptsProcessing: Not Authenticated/Verified , but a proof of attempted
///   authentication/verification is provided
/// - ChallengeRequired: Additional authentication is required using the CReq/CRes
/// - AuthenticationRejected: issuer is rejecting authentication/verification and request that
///   authorisation not be attempted
enum TransactionStatus: String, Decodable {
    case AuthenticationSuccessful = "Y"
    case TransactionDenied = "N"
    case TechnicalProblem = "U"
    case AttemptsProcessing = "A"
    case ChallengeRequired = "C"
    case AuthenticationRejected = "R"
    case DecoupledAuthentication = "D"
    case InformationalPurposesOnly = "I"
}

/// Rendering type of the ACS Challenge Data.
struct AcsRenderingType: Decodable {
    let acsInterface: String
    let aacsUiTemplate: String
}


/// Result of the Transaction.
struct TransactionResult: Decodable {
    let threeDSServerTransID: String
    let transStatus: TransactionStatus
    let transStatusReason: String?
    let authenticationValue: String?
    let eci: String?
    let acsTransID: String
    let dsTransID: String?
    let acsReferenceNumber: String
    let cardholderInfo: String?
    let authenticationType: String?
    
    init(threeDSServerTransID: String,
         transStatus: TransactionStatus,
         transStatusReason: String,
         authenticationValue: String,
         eci: String,
         acsTransID: String,
         dsTransID: String,
         acsReferenceNubmer: String,
         cardholderInfo: String,
         authenticationType: String) {
        self.threeDSServerTransID = threeDSServerTransID
        self.transStatus = transStatus
        self.transStatusReason = transStatusReason
        self.authenticationValue = authenticationValue
        self.eci = eci
        self.acsTransID = acsTransID
        self.dsTransID = dsTransID
        self.acsReferenceNumber = acsReferenceNubmer
        self.cardholderInfo = cardholderInfo
        self.authenticationType = authenticationType
    }
}

/// Data needed for challenge proccess.
struct ChallengeData: Decodable {
    let acsSignedContent: String?
    let acsUIType: String?
}


/// Struct that decodes and stores the useful parameters from the json response
struct AuthenticationResponse: Deserialisable, Decodable {

    let indicator: String
    let transactionResult: TransactionResult
    let challengeData: ChallengeData?
    
    init(indicator: String, transactionResult: TransactionResult, challengeData: ChallengeData?) {
        self.indicator = indicator
        self.transactionResult = transactionResult
        self.challengeData = challengeData
    }
    
    static func deserialize<T>(from data: Data?) -> T? {

        guard let dataToDeserialize = data,
            let response = try? JSONDecoder().decode(AuthenticationResponse.self,
                                                     from: dataToDeserialize),
            let authenticationResponse = response as? T else {
                return nil
        }
        return authenticationResponse
    }

}
