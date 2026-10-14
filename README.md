# Worker career kit (prototype)

A clickable prototype of career-record ideas for craft workers (trades). Live demo: https://kunaxar.github.io/worker-career-kit/

**This is a demo, not a product.** Everything is fictional: the worker "Marcus", the employer, the credentials, the company code (`DEMO-1234`), the phone and email. State lives in memory only. Nothing is saved, sent, or checked against any real system.

## The 5 options in the app

1. **Task record (Profile tab)**: pick a trade, tap tasks you have done. Each task is labelled self-described until a supervisor confirms. "Ask supervisor" is simulated and sends nothing. Tasks are never shown as issuer-verified.
2. **Pathway view (Path tab)**: levels shown are illustrative placeholders. A real pathway needs the credential issuer's own mapping, which is not checked.
3. **Job-change kit (Job change tab)**: open-to-work note, share, a decorative sample QR (does not scan), and a one-page summary preview. Print/PDF is a stub.
4. **Funding finder (Funding tab)**: link-outs only to public sites (CareerOneStop, Apprenticeship.gov). No money handling, no applications, no state-level accuracy.
5. **New-job checklist (New job tab)**: link the demo code, get a week-one checklist. It stays on the device and reports nothing to an employer.

Also on the Profile tab: owner controls for which fields a shared profile shows (phone hidden by default, message button instead) and a preview of what a foreman would see.

## Limits

- Hypothesis-led: no worker interviews, no usage data, demand not validated.
- Employer and publisher screens of any real product were not inspected.
- Credential levels, unlocks and the QR are placeholders.
- Link-outs open public sites; costs and eligibility depend on state and employer.

## Privacy

No real customer, payroll, or private product data. No login, no tokens, no analytics, no backend.

## Build

Flutter web. `.github/workflows/pages.yml` builds and publishes to the `gh-pages` branch.
