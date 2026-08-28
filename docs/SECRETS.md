# Secrets

## The pipeline

```
envs/.env.<environment>            git-ignored, you create it
        ↓  scripts/generate_secrets.sh   (run as each scheme's build pre-action)
Configurations/Secrets.xcconfig    git-ignored, generated, never edited by hand
        ↓  #include? from Configurations/App.xcconfig
build settings
```

Each scheme regenerates `Secrets.xcconfig` for its own environment before Xcode evaluates build
settings, so switching from Development to Production never builds against the previous
environment's values.

## There is only one secret

`CCAM_TEAM_ID` — your Apple Developer Team ID, and only needed to sign for a physical device. That
is the whole surface. There is no API key, because there is no backend: the camera is the only
server this app talks to, it lives at a fixed `192.168.0.1`, and that address is in
`Configurations/App.xcconfig` in plain sight because it is the same on every unit.

## A fresh clone works without any of it

`App.xcconfig` includes the generated file with `#include?` — the `?` makes it optional. A clone
with no `envs/` at all still generates, opens, builds and runs on the simulator; it just cannot sign
for a device. `generate_secrets.sh` warns and exits cleanly rather than failing the build when the
`.env` is missing, for the same reason.

CI relies on this. The workflow sets no secrets and passes `CODE_SIGNING_ALLOWED=NO`.

## Setting it up

```sh
cp envs/.env.example envs/.env.development
# then set CCAM_TEAM_ID
ENV_NAME=development ./scripts/generate_secrets.sh
```

Repeat for `.env.staging` and `.env.production` if you archive those schemes.

## Gotcha: the pre-action log

Xcode hides build pre-action output from the build log entirely. The schemes redirect it to
`/tmp/ccam_secrets.log`, and that file is the first thing to check when a build behaves as though a
setting never resolved — a missing `.env`, a typo'd key, or a stale `Secrets.xcconfig` from another
environment all look identical from inside Xcode.

## Never commit

`Configurations/Secrets.xcconfig` and `envs/.env.*` are both git-ignored. `envs/.env.example` is the
one tracked file under `envs/`, kept by a negation in `.gitignore`, and it documents the keys rather
than holding any.
