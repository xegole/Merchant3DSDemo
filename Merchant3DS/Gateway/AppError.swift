import Foundation

enum AppError: Error {
    case appError(title: AppErrorMessage, description: String? = nil)
}

enum AppErrorMessage: String {
    case InvalidParsing = "Invalid parsing"
    case ServerError = "Server error"
    case InvalidConfiguration = "Invalid configuration"
    case CannotConvertJsonStringToData = "Cannot convert json string to data"
    case InvalidCard = "Invalid card number"
    case InvalidExpiryDate = "Expiry date must have 4 digits"
}
