# Later

Work that is parked, not dropped. Each item says what it gives, what you do and what an agent does.
Move an item into a PR when you pick it up, and delete it here when it is merged.

## 1. Android builds on your phone: Firebase App Distribution

**Gives:** every merge to `main` sends the debug APK to the Firebase App Tester app on your Android phone, with a
notification. Free (Firebase Spark plan).

**You do (once, about 10 minutes, on firebase.google.com):**

1. Create a Firebase project (Google Analytics: off).
2. Add an Android app with the package name `com.myapp`. Skip the `google-services.json` and SDK steps: App
   Distribution doesn't need them.
3. App Distribution → Testers & Groups: create the group `testers` and add your Google account's email.
4. Project settings → Service accounts → Google Cloud: create a service account with the role
   **Firebase App Distribution Admin**, then create a JSON key for it.
5. Save the secret and the app id yourself, so neither passes through an agent:

   ```bash
   gh secret set FIREBASE_SERVICE_ACCOUNT --repo medhasharmait-arch/myapp < path/to/key.json
   gh variable set FIREBASE_APP_ID --repo medhasharmait-arch/myapp --body "1:1234567890:android:abc123"
   ```

   The app id is in Project settings → General → Your apps. Then delete the JSON key file from your computer.

**Agent does:** a `distribute` job in `android.yml` that runs only on pushes to `main`, after `android-build`.
It downloads the `app-debug` artifact and uploads it with the Firebase CLI to the `testers` group, using the merged
commit's message as the release notes. It has a timeout, skips cleanly when the secret is missing, and is not a
required check.

**Then:** install Firebase App Tester from the Play Store and accept the email invite.

## 2. Codex code review (README step 5)

**Gives:** a second reviewer (OpenAI Codex) on every PR, alongside Claude. It reads `AGENTS.md`.

**You do:** in ChatGPT → Codex → Settings → Code review, connect GitHub, pick `medhasharmait-arch/myapp` and turn on
automatic reviews. Nothing in the repo changes.

## 3. Phone apps (README step 7)

**Gives:** the whole loop from your phone: start a cloud session, watch CI, read the walk-through comment, merge.

**You do:** install GitHub, Claude, ChatGPT and (after item 1) Firebase App Tester. Sign in to each with the same
accounts as on your computer. In the GitHub app, turn on notifications for pull requests and Actions.

## 4. Delete the duplicate Appetize app

The first walk-through run with the variable set created a second app, `ca4lyoc6lqjrf3l5fij5pjzh3q`, before
`APPETIZE_PUBLIC_KEY` took effect. Delete it in the Appetize dashboard (Apps → that key → Delete). Keep
`xl2c3ojeyoga4dy46hbhlhwymm`: the README and the PR comments link to it.

## 5. Only if the repo goes private: Codemagic for macOS

Private repos pay for GitHub's macOS minutes (counted 10x). Codemagic's free tier then gives 500 macOS minutes a month
for the iOS walk-through and Mac runs. While the repo is public, GitHub's macOS runners are free and unlimited, so
this stays parked.

## 6. When you are ready to ship to the stores

Not free, so parked until the app is worth publishing:

- **Google Play:** a one-off $25 developer account, a release keystore saved as GitHub secrets, a signed `bundleRelease`
  job, and an upload to the internal testing track.
- **App Store / TestFlight:** the Apple Developer Program ($99 a year), signing certificates and an App Store Connect
  API key saved as GitHub secrets, and an archive + upload job on the Mac runner.
