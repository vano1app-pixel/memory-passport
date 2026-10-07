# Memory Passport — local edition

Native iPhone/iPad visual memory map for carrying user-approved context between AI conversations. Map nodes connect memories to their projects and sources; tap a node to inspect or export its context. Notebook handles text import, project filtering, search and edit/delete. Sources labels distinguish manual imports from account connections. No external dependencies, backend, analytics, account connection or model calls. StoreKit 2 purchase/restore implementation added; production product is not configured or approved. Atomic protected-file persistence, context copy and export.

Generate: `xcodegen generate`. Build the MemoryPassport scheme for iOS Simulator. Bundle identifier is provisional and unregistered.

This is a local prototype, not a submitted App Store product. Automatic extraction, cross-device sync and provider integrations are not implemented. Pro target: €7.50/month, 30 free memories then unlimited additions. Existing notes remain readable/editable/exportable after cancellation. The limit only applies when StoreKit successfully loads a product; unavailable purchase setup must not block adding notes. Storefront pricing comes from StoreKit, never a hard-coded production price. The `.storekit` file is local test data, not Apple configuration.

Native subscriptions require App Store Connect configuration and review. A release also needs app icon, public privacy-policy URL, metadata, physical-device checks and signing. Commercial value and recurring subscription eligibility remain unvalidated. No new paid services may be enabled.
