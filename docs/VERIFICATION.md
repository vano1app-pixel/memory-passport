# Verification — 2026-10-07

Native simulator build passed on Xcode 26.6. Final XCTest result: one end-to-end UI test passed, zero failures. Evidence: local `build/QA-verified.xcresult`.

Verified by the UI test: add memory, select its project node in Map, show selected-context action, terminate/relaunch and retain memory, prepare context, copy success feedback, confirm deletion, terminate/relaunch and confirm removal. Earlier failed runs led to a clearer delete confirmation and a test correction: an empty notebook uses the first-memory state rather than the no-search-results state.

Inspected iPhone populated map and iPad empty map renders. Screenshots: `map-iphone.png`, `map-ipad.png`, `context-iphone.png`. These include a synthetic QA note, not a connected account or real personal data.

Unverified: physical device, large graphs, import file picker, share destination, VoiceOver, provider authentication, repository sync, payments and App Store release. No paid services enabled. No automatic AI semantic extraction. Graph edges reflect explicit project/source fields.

## Subscription implementation

Subscription build passed. Two UI tests passed in `build/QA-paywall.xcresult`: core memory/map/export/delete flow and Pro screen availability/restore visibility. Actual Pro screenshot inspected at `pro-iphone.png`. The three StoreKit transaction tests failed before purchase because the local StoreKit test service rejected configuration; iPhone and iPad retries returned the same failure. Purchase, restore, expiry and refund handling are implemented but remain unverified. No production subscription exists and no real charges occurred. Free memory limit is not enforced when no StoreKit product is available. Latest limit guard change was compiled by the subsequent iPad test build; transaction verification is still blocked.
