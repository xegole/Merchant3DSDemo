import UIKit
import ThreeDS_SDK
import GirdersSwift
import PromiseKit

/// Protocol defining methods for the PaymentDetailsUseCase.
protocol PaymentDetailsUseCase {
    
    /// Creates a Transaction
    ///
    /// - Parameters:
    ///   - directoryServerId: The ID of the directory server, based on which DS logo
    ///   - protocolVersion: Protocol version according to which the transaction shall be created.
    /// and DS public key for encription will be used
    /// - Returns: Transaction object.
    /// - Throws: Throws an errro if the transaction cannot be created for any reason
    func createTransaction(directoryServerId: String, protocolVersion: String) throws -> Transaction
    
    /// Sends Authentication Request.
    ///
    /// - Parameters:
    ///   - transaction: Transaction object which contains data for the Authentication Request.
    ///   - paymentDetails: PaymentDetails object which contains data for the Authentication Request.
    /// - Returns: Promise of type AuthenticationResponse.
    func sendAuthenticationRequest(transaction: Transaction,
                                   paymentDetails: PaymentDetails)
    -> Promise<AuthenticationResponse>
    
    func sendAuthenticationRequest(_ request: [String: Any]) -> Promise<AuthenticationResponse>
    
    func sendThreeRIAuthenticationRequest(paymentDetails: PaymentDetails, threeRIInd: String) -> Promise<AuthenticationResponse>
    
    /// Validate message version name in all three ds components.
    /// - Parameter accountNumber: Card number.
    func validateMessageVersion(for accountNumber: String) -> Promise<ThreeDSVersioningResponse>
    
}

class PaymentDetailsUseCaseImplementation: PaymentDetailsUseCase {
    
    lazy var apiGateway: ApiGateway = Container.resolve()
    lazy var threeDS2Service: ThreeDS2Service = Container.resolve()
    
    func sendAuthenticationRequest(transaction: Transaction,
                                   paymentDetails: PaymentDetails)
    -> Promise<AuthenticationResponse> {
        
        do {
            let authenticationRequestJSON =
                try AuthenticationRequestJsonGenerator.generateAppAResJson(transaction: transaction,
                                                                    paymentDetails: paymentDetails)
            return sendAuthenticationRequest(authenticationRequestJSON)
        } catch {
            return Promise(error: error)
        }
    }
    
    func sendThreeRIAuthenticationRequest(paymentDetails: PaymentDetails, threeRIInd: String) -> Promise<AuthenticationResponse> {
        do {
            let authenticationRequestJSON =
                try AuthenticationRequestJsonGenerator.generateThreeRiAResJson(paymentDetails: paymentDetails, threeRIInd: threeRIInd)
            return sendAuthenticationRequest(authenticationRequestJSON)
        } catch {
            return Promise(error: error)
        }
    }
    
    func sendAuthenticationRequest(_ request: [String : Any]) -> Promise<AuthenticationResponse> {
        return apiGateway.sendAuthenticationRequest(json: request)
    }
    
    func createTransaction(directoryServerId: String, protocolVersion: String) throws -> Transaction {
        return try threeDS2Service.createTransaction(directoryServerId: directoryServerId,
                                                     messageVersion: protocolVersion)
    }
    
    func validateMessageVersion(for accountNumber: String) -> Promise<ThreeDSVersioningResponse> {
        
        let versioningRequest = ThreeDSVersioningRequest(cardholderAccountNumber: accountNumber)
        
        do {
            let versioningRequestJSON = try versioningRequest.generateJSON()
            return apiGateway.sendVersioningRequest(json: versioningRequestJSON)
        } catch {
            return Promise(error: error)
        }

    }
}
