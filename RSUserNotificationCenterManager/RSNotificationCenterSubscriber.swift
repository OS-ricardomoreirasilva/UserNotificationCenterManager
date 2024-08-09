import UserNotifications

protocol RSNotificationCenterSubscriber: Equatable {
    // MARK: - Properties
    var identifier: String { get }

    func canHandle(_ notification: UNNotification) -> Bool
    func getPresentationOptionSet(for notification: UNNotification) -> RSNotificationPresentationOptionSet
    func handle(received notification: UNNotification)
}

func == (lhs: some RSNotificationCenterSubscriber, rhs: some RSNotificationCenterSubscriber) -> Bool {
    return lhs.identifier == rhs.identifier
}
