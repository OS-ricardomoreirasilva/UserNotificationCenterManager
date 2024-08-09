import UserNotifications

struct RSNotificationPresentationOptionSet: OptionSet {
    enum RSNotificationPresentationOptionSetError: Error {
        case unexpectedValue
    }

    var rawValue: UInt

    static let badge = Self(rawValue: 1 << 0)
    static let sound = Self(rawValue: 1 << 1)
    static let list = Self(rawValue: 1 << 2)
    static let banner = Self(rawValue: 1 << 3)

    func toUNNotificationPresentationOptions() throws -> UNNotificationPresentationOptions {
        return switch self {
        case .badge: .badge
        case .sound: .sound
        case .list: .list
        case .banner: .banner
        default: throw RSNotificationPresentationOptionSetError.unexpectedValue
        }
    }
}
