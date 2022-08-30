import Foundation
import GlobalPayments_iOS_SDK
import GirdersSwift
import ThreeDS_SDK

typealias ThreeDSecureCompletion = (ThreeDSecure?, Error?) -> Void

protocol MerchantViewInput {
    func onViewDidLoad()
    func onUpdateConfig()
    func checkEnrollment(_ token: String, completion: @escaping ThreeDSecureCompletion)
    func do3Auth(secureEcom: ThreeDSecure)
}

protocol MerchantViewOutput: AnyObject {
    func displayConfigModule()
    func displayError(_ error: Error)
    func showTokenLoaded(_ token: String)
    func showNetceteraLoaded()
    func requestError(_ error: Error)
    func requestSuccess(_ message: String?)
}

final class MerchantViewModel: MerchantViewInput {
    
    private let currency = "GBP"
    private let amount: NSDecimalNumber = 10
    private let ENROLLED: String = "ENROLLED"
    private let CHALLENGE_REQUIRED = "CHALLENGE_REQUIRED"
    private var tokenizedCard = CreditCardData()
    private var transaction: ThreeDS_SDK.Transaction?
    private var cardBrand: String?
    weak var view: AmountViewController?
    lazy var initializationUseCase: InitializationUseCase = Container.resolve()
    lazy var threeDS2Service: ThreeDS2Service = Container.resolve()
    
    private let configuration: ConfigurationGP
    private var currentToken: String = ""
    
    init(configuration: ConfigurationGP) {
        self.configuration = configuration
    }
    
    func onViewDidLoad() {
        checkConfig()
        if initThreeDS2Service() {
            self.view?.showNetceteraLoaded()
        }else {
            print("failure init3DS")
        }
    }
    
    func onUpdateConfig() {
        checkConfig()
    }
    
    func initThreeDS2Service() -> Bool {
        var initializationStatus = false
        initializationUseCase.initializeSDK(succesHandler: {
            initializationStatus = true
        }) { _ in
        }
        return initializationStatus
    }
    
    private func checkConfig() {
        guard let appConfig = configuration.loadConfig() else {
            view?.displayConfigModule()
            return
        }
        configureContainer(with: appConfig)
        generateToken(with: appConfig)
    }
    
    private func configureContainer(with appConfig: Config) {
        do {
            let config = GpApiConfig(
                appId: appConfig.appId,
                appKey: appConfig.appKey,
                secondsToExpire: appConfig.secondsToExpire,
                intervalToExpire: appConfig.intervalToExpire,
                channel: appConfig.channel,
                language: appConfig.language,
                country: appConfig.country,
                challengeNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
                methodNotificationUrl: "https://ensi808o85za.x.pipedream.net/",
                merchantContactUrl: "https://example.com/about"
            )
            config.environment = .test
            try ServicesContainer.configureService(
                config: config
            )
        } catch {
            view?.displayError(error)
        }
    }
    
    func generateToken(with appConfig: Config){
        GpApiService.generateTransactionKey(
            environment: .test,
            appId: appConfig.appId,
            appKey: appConfig.appKey){ [weak self] accessTokenInfo, error in
                
                UI {
                    guard let accessTokenInfo = accessTokenInfo else {
                        self?.view?.displayError(error!)
                        return
                    }
                    
                    self?.currentToken = accessTokenInfo.token ?? ""
                    
                    self?.view?.showTokenLoaded(self?.currentToken ?? "")
                }
            }
    }
    
    //2. Send Cardholder data to server
    func checkEnrollment(_ token: String, completion: @escaping ThreeDSecureCompletion){
        tokenizedCard = CreditCardData()
        tokenizedCard.token = token
        
        Secure3dService
            .checkEnrollment(paymentMethod: tokenizedCard)
            .withCurrency(currency)
            .withAmount(amount)
            .execute(completion: completion)
    }
    
    //5. If 3DS2 proceed
    func do3Auth(secureEcom: ThreeDSecure) {
        if secureEcom.enrolled != ENROLLED {
            guard let serverTransactionId = secureEcom.serverTransactionId else {
                return
            }
            doAuth(serverTransactionId: serverTransactionId)
            return
        }
        createTransaction(secureEcom: secureEcom)
    }
    
    private func createTransaction(secureEcom: ThreeDSecure) {
        do {
            //10. Create transaction
            transaction = try threeDS2Service.createTransaction(directoryServerId: getDsRidCard(), messageVersion: secureEcom.messageVersion
            )
            
            //11. Get authentication Params
            if let netceteraParams = try transaction?.getAuthenticationRequestParameters(){
                authenticateTransaction(secureEcom, netceteraParams: netceteraParams)
            }
        } catch {
            view?.requestError(error)
        }
    }
    
    //12. Send Authentication Parameters to server
    func authenticateTransaction(_ secureEcom: ThreeDSecure, netceteraParams: AuthenticationRequestParameters ) {
        let mobileData = MobileData()
        mobileData.applicationReference = netceteraParams.getSDKAppID()
        mobileData.sdkTransReference = netceteraParams.getSDKTransactionId()
        mobileData.referenceNumber = netceteraParams.getSDKReferenceNumber()
        mobileData.sdkInterface = .both
        mobileData.encodedData = netceteraParams.getDeviceData()
        mobileData.maximumTimeout = 10
        mobileData.ephemeralPublicKey = JsonDoc.parse(netceteraParams.getSDKEphemeralPublicKey())
        mobileData.sdkUiTypes = SdkUiType.allCases
        
        Secure3dService
            .initiateAuthentication(paymentMethod: tokenizedCard, secureEcom: secureEcom)
            .withAuthenticationSource(.mobileSDK)
            .withAmount(amount)
            .withCurrency(currency)
            .withOrderCreateDate(Date.now)
            .withMobileData(mobileData)
            .execute { [weak self] threeDSecure, error in
                guard let threeDSecure = threeDSecure else {
                    if let error = error{
                        self?.view?.requestError(error)
                    }
                    return
                }
                self?.startChallengeFlow(threeDSecure)
            }
    }
    
    //14. Frictionless or Challenge
    private func startChallengeFlow(_ threeDSecure: ThreeDSecure) {
        if (threeDSecure.status != CHALLENGE_REQUIRED) {
            if let serverTransactionId = threeDSecure.serverTransactionId {
                doAuth(serverTransactionId: serverTransactionId)
            }
            return
        }
        let challengeStatusReceiver = AppChallengeStatusReceiver(view: self, dsTransId: threeDSecure.dsTransferReference, transactionId: threeDSecure.serverTransactionId)
        let challengeParameters = prepareChallengeParameters(threeDSecure)
        UI {
            do {
                try self.transaction?.doChallenge(challengeParameters: challengeParameters,
                                             challengeStatusReceiver: challengeStatusReceiver,
                                             timeOut:10,
                                             inViewController: self.view!)
                
            } catch {
                self.view?.requestError(error)
            }
        }
    }
    
    private func prepareChallengeParameters(_ threeDSecure: ThreeDSecure) -> ChallengeParameters {
        let challengeParameters = ChallengeParameters.init(threeDSServerTransactionID:              threeDSecure.providerServerTransRef,
                                                           acsTransactionID: threeDSecure.acsTransactionId,
                                                           acsRefNumber: threeDSecure.acsReferenceNumber,
                                                           acsSignedContent: threeDSecure.payerAuthenticationRequest)
        return challengeParameters
    }
    
    //23.
    func doAuth(serverTransactionId: String) {
        Secure3dService
            .getAuthenticationData()
            .withServerTransactionId(serverTransactionId)
            .execute { [weak self] threeDSecure, error in
                guard let threeDSecure = threeDSecure else {
                    if let error = error{
                        self?.view?.requestError(error)
                    }
                    return
                }
                self?.tokenizedCard.threeDSecure = threeDSecure
                self?.chargeMoney()
            }
    }
    
    private func chargeMoney() {
        tokenizedCard.charge(amount: amount)
            .withCurrency(currency)
            .execute(completion: { [weak self] transaction, error in
                guard let _ = transaction else {
                    if let error = error {
                        self?.view?.requestError(error)
                    }
                    return
                }
                self?.view?.requestSuccess("Transaction Completed")
            })
    }
    
    func getDsRidCard() -> String {
        switch cardBrand?.lowercased() {
        case "visa":
            return DsRidValues.visa
        default:
            return DsRidValues.visa
        }
    }
}

extension MerchantViewModel: StatusView {
    
    func showErrorScreen(with message: String) {
        UI {
            self.view?.requestError(ApiException(message: message))
        }
    }
    
    func showSuccessScreen(with message: String) {
        self.view?.requestSuccess(message)
    }
    
    func showSuccessScreen(by transactionId: String) {
        self.doAuth(serverTransactionId: transactionId)
    }
}
