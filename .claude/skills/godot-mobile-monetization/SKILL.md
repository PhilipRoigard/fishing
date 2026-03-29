---
name: godot-mobile-monetization
description: Mobile game patterns for Godot including IAP with mock fallback, ad integration, premium manager, virtual joystick, safe zone handling, haptics, and GDPR consent. Use when implementing monetization, touch controls, or mobile platform features.
user-invokable: false
---

For full implementation details, see [reference.md](reference.md).

## Key Patterns

- **IAP**: Resource-based Product catalog, PurchaseManager with native/mock fallback, async await flow
- **Ads**: LevelPlayManager with rewarded video, daily limits via AdRewardTracker
- **Premium**: Simple boolean flag with persistence and signal
- **Virtual Joystick**: Touch input with dead zone, auto-shoot detection, auto-hide
- **Safe Zones**: SafeZoneManager autoload + SafeZoneContainer for notch handling
- **Haptics**: Platform-gated haptic feedback (iOS HapticFeedback singleton)
- **GDPR Consent**: ConsentManager with consent_required signal flow
- **Store UI**: Dynamic card grid with width equalization, carousel for bundles
