# Real-time Notification System
> format: strategic-spec | version: 1.0

Our mobile app has grown to 50K active users but has no systematic way to reach them about things that matter — order confirmations, password resets, mentions from teammates. Users currently find out about events by manually checking the app, which means time-sensitive information (like a teammate mentioning them in a comment) goes unseen for hours. Customer support tickets about "I never got notified" have tripled in the last quarter.

We need a multi-channel notification system that delivers the right events to the right users through the right channels. Users must have control — not everyone wants push notifications at 2am, and not every event deserves an email.

**Stakeholders:**
- Sarah (Product Manager): Shaped problem understanding, user pain points, priority decisions. Emphasized user control as non-negotiable — "users who feel spammed will turn off everything."
- Marcus (Technical Architect): Defined throughput requirements, channel integration constraints, delivery guarantee approach. Flagged push notification complexity as the highest risk area.
- Aisha (UX Designer): Defined preference model (per-event, per-channel), quiet hours concept, and the principle that notifications should feel personal, not broadcast.
- James (Business/Compliance): Identified CAN-SPAM requirements for email, data retention implications, and the strategic importance of not damaging sender reputation.

**Constraints:**
- Must integrate with existing user service — authentication and user profiles are already there, no separate user management
- Email delivery through SendGrid only — approved vendor, contract in place, ops team knows how to monitor it
- Push notifications through APNs (iOS) and FCM (Android) directly — no third-party aggregators, per Marcus's recommendation on latency and control
- No SMS channel in this iteration — deferred to a future project based on cost analysis

**Non-goals:**
- In-app notification center — separate project that will consume this system's data, but not in scope here
- Marketing/bulk email campaigns — this is transactional notifications only; marketing has their own tooling
- Rich media in push notifications — text only for v1; rich media adds complexity in payload handling and rendering across devices

**Open questions:**
- Should we support notification batching/digests in v1 or defer? Aisha sees value ("daily summary email"), Marcus flags complexity ("batching needs a scheduler and aggregation logic"). Sarah leans toward deferring.
- Retry policy: how many retries before marking failed? Marcus suggests 3 retries with exponential backoff, but we haven't validated this against SendGrid's own retry behavior.

---

## Cross-Cutting Concerns

### Performance
Throughput target: 10,000 notification events per minute at peak. This number comes from Marcus's analysis of current event volume (2K/min) with 5x growth headroom. Individual notification delivery latency is less critical than throughput — users won't notice a 2-second delay, but the system must not fall behind under sustained load.

### Security
- Email suppression list is legally required (CAN-SPAM) — James flagged this as non-negotiable
- Push notification device tokens are user-linked PII — must be stored encrypted, cleaned up on account deletion
- Webhook endpoints (for bounce processing) must validate sender signatures — open webhook endpoints are an abuse vector
- API key and service account credentials for SendGrid/APNs/FCM must never appear in logs or error messages

### Observability
- Every notification must be traceable end-to-end: received → routed → dispatched → delivered/failed
- Delivery success rates per channel must be dashboardable — Marcus wants this for operational health
- Failed deliveries must include enough context for debugging without exposing user content

---

## Group: Notification Core
> priority: must-have

The backbone of the notification system — event intake, routing logic, and the delivery pipeline that channels plug into. Everything else depends on this being stable and well-defined. This group establishes the core abstractions: what a notification event looks like, how channels are plugged in, and how events get matched to users and dispatched. Delivering this group alone doesn't reach users yet, but it creates the foundation that makes all channel implementations possible.

### NCO-01: Notification Event Model
> priority: must-have | risk: low
> depends_on: -

Define what a notification event IS — the core data structure that flows through the entire system. Every other capability consumes this. The model must handle different event types (order confirmations feel different from comment mentions) while being extensible — the team should be able to add new event types without rebuilding the system.

Per Marcus: needs an idempotency key to prevent duplicate deliveries in retry scenarios. Per Aisha: needs a priority signal so quiet hours can be bypassed for truly urgent events. Per Sarah: must support at least order_confirmed, password_reset, and comment_mention at launch — these are the three highest-volume support ticket categories.

**Success conditions:**
- Covers all required fields: event type, recipient, payload, priority, timestamp, idempotency key
- Supports at least three event types at launch: order_confirmed, password_reset, comment_mention
- Extensible — adding a new event type doesn't require changes to the routing or delivery layers
- Priority levels exist (immediate/normal/low) for quiet hours and future batching decisions
- Invalid events are rejected with clear, structured errors listing all problems

### NCO-02: Channel Abstraction
> priority: must-have | risk: low
> depends_on: NCO-01

Define how delivery channels plug into the system — a clean contract that email, push, and any future channel implements. This is what makes the system extensible beyond the two channels we're building now. Per Marcus: adding a new channel (like SMS later) should mean implementing this contract and nothing else — no routing engine changes, no preference model changes.

The abstraction needs to answer: how does a channel send a notification, how does it report whether it supports a given event type, and how does it report its own health for monitoring.

**Success conditions:**
- Channel contract is implemented by email and push channels without leaking platform specifics
- Adding a new channel requires only implementing the contract — no changes to routing or preferences
- Health reporting enables monitoring dashboards to show per-channel status
- Failed delivery returns enough information for the retry mechanism to make smart decisions

### NCO-03: Routing & Dispatch
> priority: must-have | risk: medium
> depends_on: NCO-01, NCO-02

The central dispatcher — receives an event, figures out which channels should deliver it (based on event type + user preferences), and dispatches to each. This is the highest-throughput component and the most complex coordination point. Per Marcus: must handle the 10K events/minute target without blocking. The routing engine should dispatch and move on — don't wait for channels to finish.

Per Sarah: events where a user has no enabled channels should be logged but not treated as errors — the user made a choice. Per Aisha: quiet hours evaluation happens here, before dispatch.

**Success conditions:**
- Routes events to correct channels based on user preferences
- Handles 10K events/minute target under sustained load
- Duplicate events (same idempotency key) are caught and deduplicated
- Failed channel deliveries are queued for retry, not lost
- Events with no enabled channels are logged, not errored
- Dispatch is non-blocking — routing engine doesn't wait for delivery completion

### NCO-04: Delivery Tracking
> priority: must-have | risk: low
> depends_on: NCO-03

Track every notification through its lifecycle: received → dispatched → delivered/failed per channel. This provides the observability Marcus requires and enables the retry mechanism. Per James: delivery records also serve as an audit trail if a user disputes whether they were notified.

Must be queryable by notification ID (for debugging) and by user (for support). Per Marcus: use an append-only pattern — record status transitions as events, don't update in place. This makes concurrent updates safe and gives full history.

**Success conditions:**
- Every notification has a unique, trackable delivery ID
- Status transitions are recorded with timestamps per channel
- Queryable by notification ID (returns all channel statuses)
- Queryable by user ID (returns recent notification history)
- Append-only — no in-place updates, full transition history preserved

---

## Group: Email Channel
> priority: must-have

Email delivery — SendGrid integration, template rendering, and bounce/complaint handling. Lower risk than push because SendGrid is a mature, well-documented API and the team has existing SendGrid experience. But bounce handling is legally required (CAN-SPAM) and protects sender reputation, so it can't be skipped.

### EML-01: SendGrid Delivery
> priority: must-have | risk: low
> depends_on: NCO-02

Implement email delivery through SendGrid's API. Handle the specifics of SendGrid's authentication, rate limiting, and error taxonomy. Per Marcus: SendGrid returns detailed error codes that need to be mapped into our system's language — transient failures (retry) vs permanent failures (stop trying, the email is bad).

Per James: must respect rate limits proactively — hitting SendGrid's rate limit repeatedly will trigger account review and potentially damage our sender reputation.

**Success conditions:**
- Sends email via SendGrid API with proper authentication
- Maps SendGrid error codes correctly — transient vs permanent failures
- Respects rate limits using SendGrid's response headers, throttles proactively
- Permanent failures (invalid email, hard bounce) are distinguishable from transient failures (timeout, server error)

### EML-02: Email Templates
> priority: must-have | risk: low
> depends_on: NCO-01

Render notification events into email content — subject line, HTML body, plain text fallback. Each event type needs its own template. Per Aisha: emails should feel personal and contextual, not generic. Per Sarah: templates must be updateable without code deployments — marketing will want to iterate on wording.

Templates should be validated at startup — discovering a missing template when trying to send a password reset email is unacceptable.

**Success conditions:**
- Each event type maps to an email template with subject, HTML, and plain text
- Templates render correctly with event-specific data
- Missing templates are caught at startup, not at send time
- Templates are updateable without code deployment
- Localization placeholder exists for future i18n support

### EML-03: Bounce & Complaint Processing
> priority: must-have | risk: medium
> depends_on: EML-01

Process bounce and spam complaint feedback from SendGrid to maintain sender reputation and legal compliance. Per James: this is CAN-SPAM required — if someone marks us as spam or their email bounces permanently, we must stop emailing them.

The suppression check must happen BEFORE attempting delivery, not after — sending to a known-bad address damages reputation even if the email bounces again. Per Marcus: the webhook that receives bounce/complaint data must validate that it's actually from SendGrid — open webhook endpoints are an abuse vector.

**Success conditions:**
- Hard bounces add the email address to a suppression list
- Spam complaints add the email address to a suppression list
- Suppression list is checked before every email delivery attempt
- Webhook endpoint validates sender signatures — rejects unsigned events
- Suppressed deliveries are tracked with a specific status (suppressed, not failed)

---

## Group: Push Channel
> priority: must-have

Push notification delivery via APNs (iOS) and FCM (Android). Per Marcus: this is the highest-risk group — two different platform APIs with different authentication models, different error taxonomies, and different reliability characteristics. Device token management adds complexity — tokens expire, users switch devices, apps get uninstalled.

### PSH-01: Device Token Management
> priority: must-have | risk: medium
> depends_on: NCO-01

Manage the mapping between users and their device tokens. Users have multiple devices (phone + tablet), tokens become invalid over time, and platforms rotate tokens periodically. Per Marcus: stale tokens are a performance drain — sending to invalid tokens wastes API calls and can trigger platform throttling.

Per James: device tokens are user-linked PII and must be handled accordingly — encrypted storage, cleanup on account deletion.

**Success conditions:**
- Register, refresh, and remove device tokens per user
- Support multiple devices per user
- Tokens not used within a reasonable window are cleaned up automatically
- Invalid tokens reported by APNs/FCM during delivery are removed immediately
- Lookup by user returns all active tokens grouped by platform

### PSH-02: iOS Push (APNs)
> priority: must-have | risk: high
> depends_on: NCO-02, PSH-01

Deliver push notifications to iOS devices via Apple Push Notification service. Per Marcus: APNs is the trickier of the two platforms — HTTP/2 protocol, JWT authentication with hourly token rotation, and specific connection management requirements. Getting this wrong means silent delivery failures that are hard to diagnose.

Marcus flagged: APNs has separate production and sandbox environments, and using the wrong one is a common and confusing failure mode.

**Success conditions:**
- Delivers push notifications to iOS devices reliably
- Authentication handles token refresh without delivery interruption
- Invalid device token errors trigger token removal in PSH-01
- Maps notification events to valid APNs payload format
- Works correctly in both production and sandbox environments

### PSH-03: Android Push (FCM)
> priority: must-have | risk: medium
> depends_on: NCO-02, PSH-01

Deliver push notifications to Android devices via Firebase Cloud Messaging. Per Marcus: simpler than APNs (HTTP/1.1, OAuth2 auth) but has its own error handling patterns. FCM distinguishes between notification messages (platform handles display) and data messages (app handles display) — per Aisha: use data messages for more control over the user experience.

**Success conditions:**
- Delivers push notifications to Android devices reliably
- Authentication with service account handles token refresh
- Invalid device token errors trigger token removal in PSH-01
- Maps notification events to FCM message format
- Handles both individual and batch delivery scenarios

---

## Group: Preferences
> priority: must-have

User notification preferences — which channels are enabled for which event types, and when. This is what makes the system user-respecting rather than broadcast-everything. Per Sarah: this is non-negotiable — "users who feel spammed will turn off everything." Per Aisha: preferences should feel granular but not overwhelming — per-event per-channel is the right level.

### PRF-01: Preference Management
> priority: must-have | risk: low
> depends_on: NCO-01

API for users to manage their notification preferences. Per Aisha: the model is per-event-type, per-channel — a user might want email for order_confirmed but only push for comment_mention. Default should be all channels enabled — opt-out, not opt-in.

Per Sarah: the API should validate that referenced event types and channels actually exist — if we remove an event type, preferences referencing it should be cleaned up, not left orphaned.

**Success conditions:**
- Users can set preferences per event type, per channel
- Default preferences enable all channels for all event types
- Invalid event types or channel names are rejected with clear errors
- Preferences are readable by the routing engine with minimal latency

### PRF-02: Quiet Hours
> priority: should-have | risk: low
> depends_on: PRF-01

Per Aisha's design: users can set a window when notifications should be held, not dropped. Notifications during quiet hours are deferred until the window ends. Per Sarah: priority=immediate notifications (like password resets) should bypass quiet hours — a user who just clicked "reset my password" needs that email NOW.

Per Marcus: timezone handling is the subtle complexity here — quiet hours are set in the user's timezone but evaluated against server time. Users who travel across timezones introduce edge cases.

**Success conditions:**
- Notifications during quiet hours are deferred, not dropped
- Deferred notifications are delivered when quiet hours end
- Priority=immediate bypasses quiet hours
- Timezone conversion handles all UTC offsets correctly
- Quiet hours spanning midnight work correctly (e.g., 22:00-08:00)
