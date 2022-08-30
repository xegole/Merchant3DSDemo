import Foundation

protocol ConfigurationViewInput {
    func onViewDidLoad()
    func saveConfig(_ config: Config)
}

protocol ConfigurationViewOutput: AnyObject {
    func displayConfig(_ config: Config)
    func displayError(_ error: Error)
    func closeModule()
}

final class ConfigurationViewModel: ConfigurationViewInput {

    weak var view: ConfigurationViewOutput?

    private let configuration: ConfigurationGP

    init(configuration: ConfigurationGP) {
        self.configuration = configuration
    }

    func onViewDidLoad() {
        if let config = configuration.loadConfig() {
            view?.displayConfig(config)
        }
    }

    func saveConfig(_ config: Config) {
        do {
            try configuration.saveConfig(config)
            view?.closeModule()
        } catch {
            view?.displayError(error)
        }
    }
}

