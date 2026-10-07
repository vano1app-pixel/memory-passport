# Provider connections — checked 2026-10-07

No account authentication is implemented yet. This is a remaining product requirement, not a completed connection.

- OpenAI: Sign in with ChatGPT commercial identity access is limited to selected partners. Identity and plan-usage scopes explicitly do not grant conversation-history access. https://developers.openai.com/siwc/quickstart
- Claude: official guidance directs developers to Claude Console API authentication or supported cloud providers. No generic Claude-account history login has been established. https://support.claude.com/en/articles/13189465-log-in-to-your-claude-account
- GitHub: OAuth/GitHub Apps are supported. A registered client, redirect flow and explicit user permissions are needed. Prefer a GitHub App with selected repositories and read-only contents; no broad repo OAuth scope. https://docs.github.com/en/apps/oauth-apps/using-oauth-apps/authorizing-oauth-apps
- Gemini/Grok: account-history connectors have not been verified or implemented.

Current UI offers explicit manual source imports and labels every AI source Import only / account not connected. No paid model requests, server, usage credits, or subscriptions have been enabled. Do not replace these labels with Connected until a real authorization and data retrieval succeeds.
