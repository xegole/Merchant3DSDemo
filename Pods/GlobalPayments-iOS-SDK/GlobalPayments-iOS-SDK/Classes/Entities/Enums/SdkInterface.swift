import Foundation

public enum SdkInterface: String, Mappable {
    case native
    case browser
    case both
    
    public init?(value: String?) {
        guard let value = value,
              let method = SdkInterface(rawValue: value) else { return nil }
        self = method
    }

    public func mapped(for target: Target) -> String? {
        switch target {
        case .gpApi:
            return self.rawValue.uppercased()
        default:
            return nil
        }
    }
}
