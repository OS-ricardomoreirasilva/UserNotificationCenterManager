import UserNotifications

class RSNotificationCenterManager: NSObject {
    // MARK: - Properties

    // It uses `UNUserNotificationCenter`'s `current` singleton.
    public static let `default`: RSNotificationCenterManager = .init(notificationCenter: .current())

    private let notificationCenter: UNUserNotificationCenter
    private var subscriberArray: [any RSNotificationCenterSubscriber]

    // MARK: - Constructor

    private init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
        self.subscriberArray = []
        super.init()
    }

    // MARK: - Methods

    public func add(subscriber: any RSNotificationCenterSubscriber) {
        self.subscriberArray.append(subscriber)
    }

    public func remove(subscriber: any RSNotificationCenterSubscriber) {
        if let index = self.subscriberArray.firstIndex(where: { $0 == subscriber }) {
            self.subscriberArray.remove(at: index)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate Implementation
extension RSNotificationCenterManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        var result: UNNotificationPresentationOptions = []

        self.subscriberArray.forEach { subscriber in
            if subscriber.canHandle(notification: notification) {
                result = (try? subscriber.getPresentationOptionSet(forNotification: notification).toUNNotificationPresentationOptions()) ?? []
                return
            }
        }

        return result
    }
}
