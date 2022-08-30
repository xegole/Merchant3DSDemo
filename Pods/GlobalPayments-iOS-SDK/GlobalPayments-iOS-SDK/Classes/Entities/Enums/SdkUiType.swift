import Foundation

public enum SdkUiType: String, Encodable, CaseIterable {
    case text
    case singleSelect = "single_select"
    case multiSelect = "multi_select"
    case oob
    case htmlOther = "html_other"
}
