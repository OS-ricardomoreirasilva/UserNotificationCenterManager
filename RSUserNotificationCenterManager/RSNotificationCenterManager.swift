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
    private func fetchSubscribe(thatHandles notification: UNNotification, _ completionHandler: (any RSNotificationCenterSubscriber) -> Void) {
        self.subscriberArray.forEach {
            guard !$0.canHandle(notification: notification) else { return completionHandler($0) }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        var result: UNNotificationPresentationOptions = []

        self.fetchSubscribe(thatHandles: notification) {
            result = (try? $0.getPresentationOptionSet(forNotification: notification).toUNNotificationPresentationOptions()) ?? []
        }

        return result
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        self.fetchSubscribe(thatHandles: response.notification) {
            $0.handle(receivedNotification: response.notification)
        }
    }
}
