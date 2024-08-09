import UserNotifications

protocol RSNotificationCenterSubscriber: Equatable {
    // MARK: - Properties
    var identifier: String { get }

    func canHandle(notification: UNNotification) -> Bool
}

func == (lhs: some RSNotificationCenterSubscriber, rhs: some RSNotificationCenterSubscriber) -> Bool {
    return lhs.identifier == rhs.identifier
}
