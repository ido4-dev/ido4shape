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

Risk hotspots:
- Platform-specific behavior (iOS vs Android differences)
- Offline/sync complexity (conflict resolution)
- App store review process (can block release)
- Push notification reliability (APNs/FCM quirks)
- Deep linking edge cases (universal links, app links)
