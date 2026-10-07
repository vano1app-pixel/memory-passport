# Revenue status — 2026-10-07

Fresh App Store Connect API read:

| App | App state | Subscription state |
| --- | --- | --- |
| Shrink Photos & PDFs | WAITING_FOR_REVIEW | monthly: WAITING_FOR_REVIEW |
| Larpy: Focus Companion | WAITING_FOR_REVIEW | weekly: READY_TO_SUBMIT |
| Tap STACK | READY_FOR_SALE | No auto-renewable subscriptions found |
| Memory Passport | No app record found | Not configured |

These states do not establish revenue, subscriber counts, IAP availability, public regional listing or completed bank/tax setup. Larpy subscription inclusion should be inspected before changing a pending app submission. No existing app pricing/review state was changed.

Memory Passport now has StoreKit 2 product loading, purchase verification, transaction updates, restore, expiry/refund access removal, pending approval messaging and a Pro screen. Local target is EUR 7.50 monthly. Price is not yet configured in App Store Connect and must be selected from available price points. Existing content stays accessible after cancellation. No account connections are sold.

Website session expired at App Store Connect. Apple does not expose creation of a new app record through its public Apps API. User login is pending; app record/product configuration cannot yet be completed.

Local purchase tests initially failed because StoreKitTest service rejected disableDialogs configuration and returned no products. These failures are not real customer purchases. Test retry and UI verification are tracked in VERIFICATION.md.

Recurring value risk: unlimited local note capacity alone is a weak monthly offer. The desired differentiation is useful supported source integration and context retrieval; those are unfinished. More apps and paywalls do not establish demand. Closest next revenue checks are Shrink approval/purchase availability, Larpy subscription inclusion and a paid user test after release.
