import UserNotifications

protocol RSNotificationCenterSubscriber: Equatable {
    // MARK: - Properties
    var identifier: String { get }

    func canHandle(notification: UNNotification) -> Bool
    func getPresentationOptionSet(forNotification: UNNotification) -> RSNotificationPresentationOptionSet
    func handle(receivedNotification: UNNotification) 

}

func == (lhs: some RSNotificationCenterSubscriber, rhs: some RSNotificationCenterSubscriber) -> Bool {
    return lhs.identifier == rhs.identifier
}
