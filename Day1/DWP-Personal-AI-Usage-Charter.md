# Personal AI Usage Charter (DWP Desktop/Endpoint Engineering)

## Scope and intent
I use public AI assistants only as a productivity aid for low-risk technical work. I remain accountable for every output I use, every script I run, and every system change I make. This charter applies to my day-to-day desktop and endpoint engineering tasks.

## 1) Tasks appropriate for public LLM help
I may use public AI assistants for:

- Drafting and improving generic PowerShell syntax and code structure.
- Creating boilerplate scripts for endpoint hygiene tasks (for example: file cleanup logic, logging wrappers, retry loops, error handling patterns).
- Explaining Windows endpoint concepts (services, scheduled tasks, registry structure, event logs, BitLocker basics, patching concepts).
- Translating technical notes into clearer runbooks, handover notes, and change descriptions.
- Generating test ideas and validation checklists for desktop deployments.
- Summarizing public vendor documentation and suggesting implementation options.
- Producing command examples that do not contain DWP data, hostnames, tenant details, or credentials.

Condition: all prompts must stay data-minimal and sanitized.

## 2) Tasks not appropriate for public LLM help
I will not use public AI assistants for:

- Any task requiring DWP internal data, architecture details, or security-sensitive context.
- Incident response details, live vulnerabilities, privileged troubleshooting, or security event analysis using real internal evidence.
- Sharing device inventories, user lists, ticket extracts, screenshots, logs, or configuration exports that contain identifiable DWP information.
- Uploading scripts, configs, or outputs that expose tenant identifiers, internal network details, server names, OU structures, or policy objects.
- Decision-making that requires authoritative DWP policy interpretation without checking official DWP guidance.

If the work needs real internal context, I will use approved internal tooling and channels only.

## 3) Data-handling rule (PII and credentials)
Non-negotiable rule: I never paste end-user PII, secrets, or access material into a public AI assistant.

This includes:

- Names, addresses, NI numbers, phone numbers, personal email addresses, case details, or any user-identifying record.
- Passwords, passphrases, API keys, tokens, certificates, private keys, connection strings, recovery keys, and MFA seed details.
- Screenshots or logs containing usernames, machine names tied to users, internal IDs, or authentication traces.

Minimum safe practice before prompting:

- Remove or mask identifiers with realistic placeholders.
- Generalize hostnames, domains, tenant labels, and paths.
- Strip metadata from logs and snippets to only what is technically necessary.
- If unsure whether data is sensitive, treat it as sensitive and do not submit it.

## 4) Personal "generate then verify" rule (scripts and system changes)
I follow a strict two-step approach:

Step 1: Generate
- Use AI to draft code, command sequences, rollout steps, and rollback ideas.

Step 2: Verify (mandatory before use)
- Read every line and confirm I understand intent and impact.
- Validate commands against official Microsoft/DWP guidance where relevant.
- Test in a safe environment first (lab/test device) with least privilege.
- Add safeguards: logging, error handling, idempotency checks, and explicit scope limits.
- Perform peer sense-check for high-impact changes.
- Confirm rollback path before production execution.
- Record what was AI-generated and what was manually verified in change notes.

No verification, no execution.

## Personal commitment
I use public AI assistants to improve speed and quality, not to bypass governance. I keep sensitive data out, verify all technical outputs, and keep responsibility for final engineering decisions.
