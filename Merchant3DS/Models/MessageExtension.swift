import Foundation

/// A struct that contains a messageExtensionRequest object and its id and messageExtensionType
struct MessageExtension {
    var id: String
    var messageExtensionRequest: MessageExtensionRequest
    var messageExtensionType: MessageExtensionType
    
    init(messageExtension: MessageExtensionRequest, messageExtensionType: MessageExtensionType){
        self.id = NSUUID().uuidString
        self.messageExtensionType = messageExtensionType
        self.messageExtensionRequest = messageExtension
    }
}

/// Defines the message extension types
enum MessageExtensionType : String {
    case mastercardPSD2 = "Mastercard PSD2 Message Extension"
    case visaPSD2 = "Visa PSD2 Acquirer Country Code Extension"
    case custom = "Custom Extension"
}
