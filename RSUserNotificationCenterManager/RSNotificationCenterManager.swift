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

// MARK: - UNUserNotificationCenter Adapter Methods
extension RSNotificationCenterManager {
    func getNotificationSettings() async -> UNNotificationSettings {
        await self.notificationCenter.notificationSettings()
    }

    func requestAuthorization(withOptions options: UNAuthorizationOptions) async throws -> Bool {
        try await self.notificationCenter.requestAuthorization(options: options)
    }

    func getDeliveredNotificationArray() async -> [UNNotification] {
        await self.notificationCenter.deliveredNotifications()
    }

    func clearDeliveredNotificationArray() {
        self.notificationCenter.removeAllDeliveredNotifications()
    }

    func clearDeliveredNotificationArray(for identifiers: [String]) {
        self.notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func getPendingNotificationArray() async -> [UNNotificationRequest] {
        await self.notificationCenter.pendingNotificationRequests()
    }

    func clearPendingNotificationArray() {
        self.notificationCenter.removeAllPendingNotificationRequests()
    }

    func clearPendingNotificationArray(for identifiers: [String]) {
        self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func addRequest(
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

    func getNotificationCategorySet() async -> Set<UNNotificationCategory> {
        await self.notificationCenter.notificationCategories()
    }

    func set(notificationCategorySet categorySet: Set<UNNotificationCategory>) {
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

    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        var result: UNNotificationPresentationOptions = []

        self.fetchSubscribe(thatHandles: notification) { subscriber in
            let presentationOptionsSet = subscriber.getPresentationOptionSet(for: notification)
            do {
                result = try presentationOptionsSet.toUNNotificationPresentationOptions()
            } catch {
                print("Error while converting 'presentationOptionsSet': \(error)")
            }
        }

        return result
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        self.fetchSubscribe(thatHandles: response.notification) {
            $0.handle(received: response.notification)
        }
    }
}
