import UserNotifications

@objc public protocol RSNotificationCenterSubscriber {
    // MARK: - Properties
    var identifier: String { get }

    func getPresentationOptionSet(for notification: UNNotification) -> RSNotificationPresentationOption
    func handle(received notificationResponse: UNNotificationResponse)
}

func == (lhs: some RSNotificationCenterSubscriber, rhs: some RSNotificationCenterSubscriber) -> Bool {
    return lhs.identifier == rhs.identifier
}

extension RSNotificationCenterSubscriber {
    func canHandle(_ notification: UNNotification) -> Bool {
        notification.request.content.userInfo["subscriberId"] as? String == self.identifier
    }
}
