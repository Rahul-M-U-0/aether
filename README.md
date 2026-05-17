# aether

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Firebase Cost Optimization (Read Bill & Sharding Strategy)

To avoid excessive Firestore read costs in a high-scale scenario (e.g., 10,000 concurrent users in a real-time engagement chat), the system avoids a single global realtime listener. Instead, data is partitioned into smaller, context-specific collections (such as raid-based or session-based chat rooms) so each user only listens to a limited subset of data relevant to their current activity.

All chat queries use pagination with `.limit()` to ensure only recent messages are streamed, preventing full history reads on every listener update. Additionally, inactive listeners are disposed when the chat UI is not visible to reduce unnecessary realtime subscriptions and read operations.

This combination of sharding, pagination, and listener lifecycle management ensures predictable Firestore usage and prevents exponential read amplification in large-scale multiplayer environments.
