extension RSNotificationPresentationOption {
    func toUNNotificationPresentationOptions() -> UNNotificationPresentationOptions {
        var result: UNNotificationPresentationOptions = []
        if self.contains(.badge) {
            result.insert(.badge)
        }
        if self.contains(.sound) {
            result.insert(.sound)
        }
        if self.contains(.list) {
            result.insert(.list)
        }
        if self.contains(.banner) {
            result.insert(.banner)
        }

        return result
    }
}
