# Real-time Notification System

> Build a multi-channel notification system that delivers events to users
> via email and push notifications. Users control their preferences per
> channel and per event type. The system must handle high throughput
> (10k events/minute) with guaranteed at-least-once delivery.

**Constraints:**
- Must integrate with existing user service (authentication, user profiles)
- Email sending through approved SMTP provider (SendGrid) only
- Push notifications via APNs (iOS) and FCM (Android) — no third-party aggregators
- No SMS channel in this iteration

**Non-goals:**
- In-app notification center (separate project, depends on this foundation)
- Marketing/bulk email campaigns — this is transactional notifications only
- Rich media in push notifications (text only for v1)

**Open questions:**
- Should we support notification batching/digests in v1 or defer?
- Retry policy: how many retries before marking a notification as failed?

---

## Group: Notification Core
> size: L | risk: medium

The backbone of the notification system — event ingestion, routing
logic, and the delivery pipeline that channels plug into. Every
other group depends on this being stable and well-defined.

This group establishes the core abstractions: NotificationEvent,
DeliveryChannel interface, and the routing engine that matches
events to user preferences and dispatches to the correct channel.

### NCO-01: Notification Event Schema
> effort: M | risk: low | type: feature | ai: full
> depends_on: -

Define the core `NotificationEvent` type that flows through the entire
system. This is the foundational data structure — every other component
consumes it. The schema must be extensible (new event types without code
changes) while maintaining type safety for known events.

Use a discriminated union pattern with a `type` field. Each event type
carries a typed payload. The schema should include: event type, recipient
user ID, payload (type-specific), priority (immediate/normal/low),
timestamp, idempotency key, and optional metadata map for channel-specific
overrides.

Include a schema validation function that verifies events at ingestion
time. Invalid events should be rejected with structured errors listing
all validation failures, not just the first one.

**Success conditions:**
- NotificationEvent type covers all required fields with proper typing
- Discriminated union supports at least: `order_confirmed`, `password_reset`, `comment_mention`
- Schema validator catches: missing required fields, invalid priority, malformed payload
- Validator returns all errors, not just the first
- Type is extensible — adding a new event type requires only adding a new payload type

### NCO-02: Delivery Channel Interface
> effort: S | risk: low | type: feature | ai: full
> depends_on: NCO-01

Define the `DeliveryChannel` interface that all notification channels
(email, push, future channels) must implement. This abstraction is what
makes the system extensible — adding a new channel means implementing
this interface, nothing else.

The interface should include: `send(event, recipient)` for single delivery,
`supports(eventType)` to declare which events a channel handles,
and `healthCheck()` for monitoring. The send method returns a
`DeliveryResult` with status (delivered/failed/deferred), channel-specific
metadata, and optional retry guidance.

Design for testability — channels should be injectable and mockable.
The interface should not leak implementation details (no SMTP concepts
in the interface, no APNs concepts).

**Success conditions:**
- DeliveryChannel interface defined with send, supports, and healthCheck methods
- DeliveryResult type covers delivered/failed/deferred states
- Interface is generic enough for email, push, and hypothetical future channels
- At least one mock implementation exists for testing

### NCO-03: Routing Engine
> effort: L | risk: medium | type: feature | ai: assisted
> depends_on: NCO-01, NCO-02

The routing engine is the central dispatcher. It receives a NotificationEvent,
determines which channels should deliver it (based on event type and user
preferences), and dispatches to each channel. This is the highest-throughput
component — it must handle 10k events/minute without blocking.

The engine should: validate the incoming event (using NCO-01's validator),
look up user preferences (which channels are enabled for this event type),
fan out to each enabled channel, and track delivery status per channel.
Failed deliveries should be queued for retry with exponential backoff.

Use an event-driven architecture internally. The routing engine should not
wait for channel delivery to complete — it dispatches and moves on. Delivery
results flow back asynchronously and update the notification status.

**Success conditions:**
- Routes events to correct channels based on user preferences
- Handles 10k events/minute in benchmarks (use synthetic load)
- Failed deliveries are queued for retry with exponential backoff
- Idempotency: duplicate events (same idempotency key) are deduplicated
- Events with no enabled channels are logged but not treated as errors

### NCO-04: Delivery Status Tracker
> effort: M | risk: low | type: feature | ai: full
> depends_on: NCO-03

Track the lifecycle of every notification: queued -> dispatched -> delivered/failed.
This provides observability and enables the retry mechanism. Each notification
gets a unique delivery ID that correlates across all channels.

Store delivery records with: notification ID, channel, status, timestamps
(queued, dispatched, delivered/failed), attempt count, and failure reason
if applicable. Expose a query interface for looking up delivery status
by notification ID or by user.

Use an append-only pattern — status transitions are recorded as events,
not updates. This gives full audit trail and makes concurrent updates safe.

**Success conditions:**
- Every notification has a trackable delivery ID
- Status transitions are recorded with timestamps
- Query by notification ID returns all channel delivery statuses
- Query by user ID returns recent notification history (last 100)
- Append-only storage — no updates, only inserts

---

## Group: Email Channel
> size: M | risk: low

Email delivery channel implementation. Integrates with SendGrid SMTP API,
handles template rendering, and manages bounce/complaint feedback loops.

### EML-01: SendGrid Integration
> effort: M | risk: low | type: feature | ai: assisted
> depends_on: NCO-02

Implement the `DeliveryChannel` interface for email delivery via SendGrid.
Handle API authentication, rate limiting, and error mapping. SendGrid's API
returns detailed error codes — map these to our DeliveryResult status
(transient failures -> deferred for retry, permanent failures -> failed).

Use SendGrid's v3 API with API key authentication. Implement request
batching for high-throughput periods (SendGrid supports up to 1000
recipients per API call). Track SendGrid's rate limit headers and
throttle proactively rather than hitting 429s.

**Success conditions:**
- Implements DeliveryChannel interface fully
- Sends email via SendGrid v3 API with proper authentication
- Maps SendGrid error codes to DeliveryResult statuses correctly
- Respects rate limits using response headers
- Transient errors (5xx, timeout) result in deferred status for retry
- Permanent errors (invalid email, bounced) result in failed status

### EML-02: Email Template Engine
> effort: M | risk: low | type: feature | ai: full
> depends_on: NCO-01

Render notification events into email HTML/text using templates.
Each event type has a corresponding template. Templates receive the
event payload and produce subject line, HTML body, and plain text
fallback.

Use a simple template engine (Handlebars or similar). Templates should
be loadable from the filesystem so they can be updated without code
deploys. Include a template validation step at startup that verifies
all known event types have corresponding templates.

**Success conditions:**
- Each event type maps to an email template (subject + HTML + plain text)
- Templates render correctly with event payload data
- Missing template for an event type is caught at startup, not at send time
- Templates support localization placeholder (locale field in event metadata)

### EML-03: Bounce Handler
> effort: S | risk: medium | type: feature | ai: assisted
> depends_on: EML-01

Process SendGrid webhook callbacks for bounces and spam complaints.
Update user records to suppress future emails to addresses that hard-bounce
or file complaints. This is legally required (CAN-SPAM compliance) and
protects our sender reputation.

Implement a webhook endpoint that validates SendGrid's webhook signature,
processes bounce/complaint events, and updates a suppression list.
The suppression check must be integrated into the email channel's
send path — check before sending, not after.

**Success conditions:**
- Webhook endpoint validates SendGrid event signatures
- Hard bounces add the email to a suppression list
- Spam complaints add the email to a suppression list
- Email channel checks suppression list before attempting delivery
- Suppressed sends return a specific DeliveryResult status (suppressed, not failed)

---

## Group: Push Channel
> size: L | risk: high

Push notification delivery via APNs (iOS) and FCM (Android).
Higher risk due to platform-specific authentication, device token
management, and the need to handle two different APIs with different
reliability characteristics.

### PSH-01: Device Registry
> effort: M | risk: medium | type: feature | ai: full
> depends_on: NCO-01

Manage the mapping between user IDs and device tokens. Users can have
multiple devices (phone + tablet), and tokens can become invalid when
users uninstall the app or reset their device. The registry must handle
token registration, invalidation, and lookup efficiently.

Expose an API for device registration (called by mobile apps on startup),
token refresh (called when the OS rotates tokens), and token removal
(called on logout). Store tokens with platform type (ios/android),
registration timestamp, and last-seen timestamp.

Implement a cleanup job that removes tokens not seen in 90 days.
Invalid tokens reported by APNs/FCM during send should be removed
immediately.

**Success conditions:**
- Register, refresh, and remove device tokens per user
- Support multiple devices per user (up to 10)
- Lookup by user ID returns all active tokens grouped by platform
- Tokens not seen in 90 days are cleaned up automatically
- Invalid tokens reported by APNs/FCM are removed immediately

### PSH-02: APNs Integration
> effort: L | risk: high | type: feature | ai: pair
> depends_on: NCO-02, PSH-01

Implement the `DeliveryChannel` interface for iOS push notifications
via Apple Push Notification service. APNs uses HTTP/2 with JWT-based
authentication and has specific requirements around connection management
and error handling.

Use the token-based (JWT) authentication method, not certificates.
Maintain a persistent HTTP/2 connection pool to APNs servers. Handle
APNs-specific error responses: `BadDeviceToken` (remove from registry),
`Unregistered` (remove), `TooManyRequests` (back off), `ServiceUnavailable`
(retry). Map payload from NotificationEvent format to APNs payload format
(alert, badge, sound, content-available).

**Success conditions:**
- Implements DeliveryChannel interface for iOS
- JWT authentication with automatic token refresh (tokens expire hourly)
- Persistent HTTP/2 connection pool (not new connection per send)
- BadDeviceToken and Unregistered errors trigger token removal in PSH-01
- Maps NotificationEvent to valid APNs payload
- Handles production and sandbox APNs environments via configuration

### PSH-03: FCM Integration
> effort: M | risk: medium | type: feature | ai: assisted
> depends_on: NCO-02, PSH-01

Implement the `DeliveryChannel` interface for Android push notifications
via Firebase Cloud Messaging. FCM uses HTTP/1.1 with OAuth2 service
account authentication. Simpler than APNs but has its own error taxonomy.

Use the FCM v1 API (not legacy). Authenticate with a service account
JSON key file. Handle FCM error responses: `UNREGISTERED` (remove token),
`SENDER_ID_MISMATCH` (configuration error, alert), `QUOTA_EXCEEDED`
(back off). Map NotificationEvent to FCM message format (notification
vs data message — use data messages for more control).

**Success conditions:**
- Implements DeliveryChannel interface for Android
- OAuth2 service account authentication with automatic token refresh
- UNREGISTERED errors trigger token removal in PSH-01
- Maps NotificationEvent to FCM data message format
- Handles both success and partial failure in batch sends

---

## Group: Preferences
> size: M | risk: low

User notification preferences — which channels are enabled for which
event types. This is what makes the routing engine user-aware rather
than just broadcasting everything everywhere.

### PRF-01: Preferences API
> effort: M | risk: low | type: feature | ai: full
> depends_on: NCO-01

REST API for managing user notification preferences. Users can enable/disable
channels per event type, set quiet hours (no notifications between 10pm-8am),
and set a global mute toggle. The routing engine (NCO-03) reads these
preferences to determine where to deliver each notification.

Endpoints: GET /preferences (current settings), PUT /preferences (update),
DELETE /preferences (reset to defaults). Preferences are stored as a
JSON document per user. Default preferences: all channels enabled, no
quiet hours, not muted. The API should validate that referenced event
types and channels actually exist.

**Success conditions:**
- CRUD operations for user notification preferences
- Preferences are per-user, per-event-type, per-channel
- Default preferences enable all channels for all event types
- Quiet hours support with timezone-aware evaluation
- Invalid event types or channel names are rejected with clear errors
- Preferences are cached with short TTL for routing engine performance

### PRF-02: Quiet Hours Engine
> effort: S | risk: low | type: feature | ai: full
> depends_on: PRF-01

Evaluate quiet hours rules at routing time. When a notification arrives
during a user's quiet hours, it should be deferred (queued for delivery
when quiet hours end) rather than silently dropped. Priority=immediate
notifications bypass quiet hours.

Handle timezone conversion — quiet hours are stored in the user's
timezone but evaluated against UTC server time. Edge cases: users
who travel across timezones, quiet hours that span midnight.

**Success conditions:**
- Notifications during quiet hours are deferred, not dropped
- Deferred notifications are delivered when quiet hours end
- Priority=immediate bypasses quiet hours
- Timezone conversion is correct for all UTC offsets
- Quiet hours spanning midnight work correctly (e.g., 22:00-08:00)
