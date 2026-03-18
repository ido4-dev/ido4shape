# Project Template: Mobile App

Typical group patterns for mobile application projects:

- **Core Experience** — primary user flows, main screens, navigation
- **Data & Sync** — local storage, API client, offline support, sync engine
- **Platform Integration** — push notifications, deep links, permissions, native APIs
- **Authentication** — login, registration, session management, social auth
- **Polish & UX** — animations, loading states, error handling, accessibility
- **Release** — app store assets, build configuration, beta distribution

Common dependency patterns:
- Authentication is foundational (most features need it)
- Data & Sync depends on Authentication
- Core Experience depends on Data & Sync
- Platform Integration depends on Core Experience
- Polish & UX depends on Core Experience being functional
- Release depends on everything

Priority patterns:
- Authentication and Core Experience are must-have
- Data & Sync is must-have if offline support is required, should-have otherwise
- Platform Integration varies — push notifications may be must-have, deep links nice-to-have
- Polish & UX is should-have (users notice, but core function comes first)
- Release is must-have but naturally last

Typical cross-cutting concerns:
- **Performance:** App startup time, screen transition smoothness, memory footprint, battery impact
- **Accessibility:** WCAG level, VoiceOver/TalkBack support, dynamic type/font scaling, contrast ratios
- **Security:** Secure storage for tokens/credentials, certificate pinning, biometric auth, session handling
- **Device support:** OS version matrix, screen size range, tablet support, landscape orientation

Risk hotspots:
- Platform-specific behavior (iOS vs Android differences)
- Offline/sync complexity (conflict resolution is strategically high risk)
- App store review process (external dependency, outside team control)
- Push notification reliability (APNs/FCM have different reliability characteristics)
- Deep linking edge cases (universal links, app links)
