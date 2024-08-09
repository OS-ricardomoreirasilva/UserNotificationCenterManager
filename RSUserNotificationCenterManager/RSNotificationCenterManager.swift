import UserNotifications

@objc public class RSNotificationCenterManager: NSObject {
    // MARK: - Properties

    // It uses `UNUserNotificationCenter`'s `current` singleton.
    @objc public static let `default`: RSNotificationCenterManager = .init(notificationCenter: .current())

    private let notificationCenter: UNUserNotificationCenter
    private var subscriberArray: [any RSNotificationCenterSubscriber]

    // MARK: - Constructor

    private init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
        self.subscriberArray = []
        super.init()

        self.notificationCenter.delegate = self
    }

    // MARK: - Methods

    @objc public func add(subscriber: any RSNotificationCenterSubscriber) {
        self.subscriberArray.append(subscriber)
    }

    public func remove(subscriber: any RSNotificationCenterSubscriber) {
        if let index = self.subscriberArray.firstIndex(where: { $0 == subscriber }) {
            self.subscriberArray.remove(at: index)
        }
    }
}

// MARK: - UNUserNotificationCenter Adapter Methods
public extension RSNotificationCenterManager {
    @objc func getNotificationSettings() async -> UNNotificationSettings {
        await self.notificationCenter.notificationSettings()
    }

    @objc func requestAuthorization(withOptions options: UNAuthorizationOptions) async throws -> Bool {
        try await self.notificationCenter.requestAuthorization(options: options)
    }

    @objc func getDeliveredNotificationArray() async -> [UNNotification] {
        await self.notificationCenter.deliveredNotifications()
    }

    @objc func clearDeliveredNotificationArray() {
        self.notificationCenter.removeAllDeliveredNotifications()
    }

    @objc func clearDeliveredNotificationArray(for identifiers: [String]) {
        self.notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    @objc func getPendingNotificationArray() async -> [UNNotificationRequest] {
        await self.notificationCenter.pendingNotificationRequests()
    }

    @objc func clearPendingNotificationArray() {
        self.notificationCenter.removeAllPendingNotificationRequests()
    }

    @objc func clearPendingNotificationArray(for identifiers: [String]) {
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    @objc func addRequest(
        fromSubscriberId subscriberId: String,
        withIdentifier identifier: String,
        notificationContent: UNMutableNotificationContent,
        trigger: UNNotificationTrigger? = nil
    ) async throws {
        notificationContent.userInfo["subscriberId"] = subscriberId
        try await self.notificationCenter.add(
            .init(identifier: identifier, content: notificationContent, trigger: trigger)
        )
    }

    @objc func getNotificationCategorySet() async -> Set<UNNotificationCategory> {
        await self.notificationCenter.notificationCategories()
    }

    @objc func set(notificationCategorySet categorySet: Set<UNNotificationCategory>) {
        self.notificationCenter.setNotificationCategories(categorySet)
    }
}

// MARK: - UNUserNotificationCenterDelegate Implementation
extension RSNotificationCenterManager: UNUserNotificationCenterDelegate {
    private func fetchSubscribe(
        thatHandles notification: UNNotification, _ completionHandler: (any RSNotificationCenterSubscriber) -> Void
    ) {
        self.subscriberArray.forEach {
            guard !$0.canHandle(notification) else { return completionHandler($0) }
        }
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        var result: UNNotificationPresentationOptions = []

        self.fetchSubscribe(thatHandles: notification) { subscriber in
            let presentationOptionsSet = subscriber.getPresentationOptionSet(for: notification)
            result = presentationOptionsSet.toUNNotificationPresentationOptions()
        }

        return result
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
    ) async {
        self.fetchSubscribe(thatHandles: response.notification) {
            $0.handle(received: response)
        }
    }
}
