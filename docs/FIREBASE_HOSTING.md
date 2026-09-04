# Firebase Hosting — Flutter Web (this repository)

Firebase project: `swapstash-49199`

## Sites

| URL / role | Firebase Hosting site | Owned by |
|---|---|---|
| `swapstash.net` — marketing website | default site `swapstash-49199` | **separate** marketing / website source tree |
| `app.swapstash.net` — Flutter Web app | `swapstash-app-49199` (target `app`) | **this** Flutter repository |

This Flutter repo must **never** deploy the marketing site.

## Safe Flutter Web deploy

```bash
firebase deploy --only hosting:app
```

Always use the explicit target. Do **not** use:

```bash
firebase deploy --only hosting
```

even if the current `firebase.json` only lists the `app` target. The explicit
`:app` form is the required standard and prevents accidental default-site
deploys if configuration drifts later.

## Local config check (no credentials)

```bash
node scripts/verify-firebase-hosting-config.js
```

## Related Firebase surfaces in this repo

- Firestore rules / indexes
- Cloud Storage rules
- Cloud Functions

Those are separate from Hosting. Participant-only `/trades` rules from P22A2B
are **not** production-ready for cutover until the client cutover gate is done.
Do not treat a Hosting deploy as permission to deploy Firestore rules.
