#ifndef RSNotificationPresentationOption_h
#define RSNotificationPresentationOption_h

typedef NS_OPTIONS(NSUInteger, RSNotificationPresentationOption) {
    RSNotificationPresentationOptionNone    = 0,
    RSNotificationPresentationOptionBadge   = (1 << 0),
    RSNotificationPresentationOptionSound   = (1 << 1),
    RSNotificationPresentationOptionList    = (1 << 2),
    RSNotificationPresentationOptionBanner  = (1 << 3)
};

#endif /* RSNotificationPresentationOption_h */
