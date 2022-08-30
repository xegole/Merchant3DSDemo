import UIKit

struct AmountBuilder {

    static func build() -> UIViewController {
        let module = AmountViewController.instantiate()
        let configuration = ConfigutationService()
        let viewModel = MerchantViewModel(configuration: configuration)
        module.viewModel = viewModel
        viewModel.view = module

        return UINavigationController(rootViewController: module)
    }
}
