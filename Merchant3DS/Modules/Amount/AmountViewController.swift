import UIKit
import GlobalPayments_iOS_SDK

final class AmountViewController: UIViewController, StoryboardInstantiable  {
    
    static let storyboardName = "Amount"
    
    @IBOutlet weak var settingsButton: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tokenLabel: UILabel!
    
    var viewModel: MerchantViewInput!
    var currentToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Merchant Amount"
        activityIndicator.startAnimating()
        viewModel.onViewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSettingsAction))
        settingsButton.isUserInteractionEnabled = true
        settingsButton.addGestureRecognizer(tap)
    }
    
    private func showConfigurationModule(_ modalPresentationStyle: UIModalPresentationStyle) {
        let module = ConfigurationGPBuilder.build(with: self)
        module.modalPresentationStyle = modalPresentationStyle
        navigationController?.present(module, animated: true, completion: nil)
    }
    
    @IBAction func onContinueAction(_ sender: Any) {
        let viewController = MerchantBuilder.build(currentToken, delegate: self)
        viewController.modalPresentationStyle = .pageSheet
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func onSettingsAction(){
        showConfigurationModule(.fullScreen)
    }
}

extension AmountViewController: TokenizedCardDataDelegate {
    
    func tokenizedCard(token: String, cardType: String) {
        activityIndicator.startAnimating()
        print("checkEnrollment: \(token) -- \(cardType)")
        viewModel?.checkEnrollment(token) { [weak self] threeDSecure, error in
            guard let threeDSecure = threeDSecure else {
                UI {
                    self?.activityIndicator.stopAnimating()
                }
                print("Error: checkEnrollment")
                return
            }
            self?.viewModel?.do3Auth(secureEcom: threeDSecure)
        }
    }
}

// MARK: - GlobalPayViewOutput

extension AmountViewController: MerchantViewOutput {
    
    func displayConfigModule() {
        showConfigurationModule(.fullScreen)
    }
    
    func showTokenLoaded(_ token: String) {
        tokenLabel.text = "Token Loaded" + "\n" + (tokenLabel.text ?? "")
        currentToken = token
        activityIndicator.stopAnimating()
    }
    
    func showNetceteraLoaded() {
        tokenLabel.text = "Netcetera Loaded"
    }
    
    func displayError(_ error: Error) {
        let message = String(format: NSLocalizedString("globalpay.container.failure", comment: ""), error.localizedDescription)
        showAlert(message: message)
        tokenLabel.text = "Token Error"
        activityIndicator.stopAnimating()
    }
    
    func requestError(_ error: Error) {
        UI {
            if let error = error as? GatewayException {
                self.showAlert(message: error.message ?? "Error")
            } else if let error = error as? ApiException {
                self.showAlert(message: error.message ?? "Error Api")
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    func requestSuccess(_ message: String?) {
        if let message = message {
            showAlert(message: message)
        }
        
        UI {
            self.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - ConfigurationViewDelegate

extension AmountViewController: ConfigurationViewDelegate {
    
    func onUpdateConfiguration() {
        viewModel.onUpdateConfig()
    }
}
