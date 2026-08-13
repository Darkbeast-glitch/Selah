# Selah — Scripture Companion

> Pause. Reflect. Return to Scripture.

Flutter (iOS + Android) Christian Scripture companion. Users bring a real-life situation ("I'm worried I'm falling behind"), and the app uses conversational AI grounded in a retrieved Bible corpus to surface relevant Scripture, explain it, and lead into reflection and a prayer starter.

**Source of truth:** `docs/Selah_Product_Requirements_Document.docx` (PRD v1.0). Read it with `textutil -convert txt -stdout <path>` when you need detail beyond this file. UI designs: `selah_scripture_companion/<screen>/screen.png` + `code.html` (Tailwind reference implementations), design tokens in `selah_scripture_companion/selah/DESIGN.md`.

## Repo layout

```
Selah/
├── selah-backend/              # Cloudflare Worker: AI backend (own README)
└── selah/                      # the Flutter project — this file, run flutter commands here
    ├── lib/
    ├── android/  ios/          # the only platforms
    ├── assets/images/          # logo + splash source art (see below)
    ├── docs/                   # PRD (.docx)
    └── selah_scripture_companion/   # design reference: HTML + PNG per screen
```

**Target platforms: iOS and Android only.** The `linux/`, `windows/`, `macos/`, and `web/` folders were deleted and dropped from `.metadata`'s migration list — only `root`, `android`, and `ios` remain. Do not re-add them, and never choose a package for desktop or web compatibility. If a target is ever genuinely needed: `fvm flutter create --platforms=web .`

A consequence worth knowing: `flutter run -d chrome` no longer works, so UI can only be previewed on a simulator/emulator or device. The design references in `selah_scripture_companion/` are plain HTML and open directly in a browser for side-by-side comparison.

## Toolchain — FVM

The Flutter version is pinned with [FVM](https://fvm.app). `.fvmrc` is committed; the SDK itself lives in `~/fvm/versions/` and `.fvm/` is gitignored.

**Prefix every Flutter and Dart command with `fvm`:**

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run
fvm dart run build_runner build --delete-conflicting-outputs
```

A bare `flutter` uses whatever the machine has globally, which will not match the pin. New machine: `dart pub global activate fvm` then `fvm install` in this directory.

Pinned to **Flutter 3.44.4** (Dart 3.12.2) because `pubspec.yaml` requires `sdk: ^3.12.2`. Anything below Flutter 3.44 fails `pub get`. VS Code is pointed at the pinned SDK via `.vscode/settings.json` (`dart.flutterSdkPath`).

## Firebase

Project **`selah-12065`**, apps registered under bundle ID **`com.selah.app`** (both platforms — set this in any new platform config, never `com.example.*`).

| App | ID |
|---|---|
| android | `1:752801573203:android:a80f5704540ed6a0df99a6` |
| ios | `1:752801573203:ios:e2a13c139fe60cdddf99a6` |

`firestore.rules` enforces PRD §22: default deny, every allowance scoped to the owning uid, server-generated timestamps required, no cross-user read path, and no public read path at all (the Scripture corpus ships with the app rather than living in Firestore). Deploy with `firebase deploy --only firestore:rules`.

Backend is live and verified: `(default)` Firestore database created, rules and the composite index **deployed**, anonymous sign-in **enabled** (confirmed by a real Identity Toolkit `signUp` returning `sign_in_provider: anonymous`).

Note on `firestore.indexes.json`: only **composite** indexes belong there. Firestore maintains single-field indexes automatically and the API rejects declaring them (`400 this index is not necessary`), so plain `orderBy(createdAt DESC)` queries need no entry.

## Current state

**Milestone 1 complete** — `flutter analyze` clean, 3 shell smoke tests passing, Firebase initialised and silent anonymous auth wired.

Built:
- Full token layer (`app/theme/`) → light + dark `ThemeData` in `app/app_theme.dart`
- `go_router` with a `StatefulShellRoute` for the four nav branches; conversation, reader, reflection, and prayer push over the shell
- `app/app_shell.dart` — glassmorphic bottom nav
- `core/` — constants, strings, sealed `AppException`, date utils, preferences service, shared widgets
- `features/auth/data/` — `AuthDataSource` (owns `firebase_auth`; nothing above it imports FirebaseAuth) + `AuthRepository` exposing plain uid strings. Read the session via `currentUidProvider`, which throws rather than returning null so a Firestore path can never be built with a missing uid.
- `bootstrap()` — prefs → `Firebase.initializeApp` → `ensureSignedIn()` → `runApp`. Sign-in failure is **deliberately non-fatal**: auth needs network, and an offline user must still reach saved Scriptures and reflections (§37), so the app starts anyway and retries next launch.
- All nine screens exist and are navigable. **Onboarding and Appearance are fully functional** (both device-local). Home, Explore, Library, Profile, Conversation, Scripture detail, Reflection, and Prayer are structural scaffolds with placeholder content and `TODO(milestone-N)` markers where the real data goes.

**Milestones 1, 2, and 4 are complete.** Working end to end: corpus search and reader, curated topics, bookmarking, reflections, prayer starters, and conversation history — all persisted per-user in Firestore, with live counts on Profile.

## AI backend (`../selah-backend/`)

A **Cloudflare Worker**, not Firebase Functions — Functions require the Blaze plan and a billing account, which this project doesn't have. Read `../selah-backend/README.md` before touching it.

- **The app supplies the Scripture; the model never generates it.** `POST /v1/reflect` takes locally-retrieved passages and returns only commentary on them. This makes PRD 24's "never invent verses" structural rather than a prompt instruction.
- **Provider is swappable** (`src/providers/`): Groq on the free tier now, Claude Haiku 4.5 (~$0.0036/turn) by changing one var — no Flutter release needed.
- **Responses are gated, not trusted.** Four safety checks reject divine-authority claims, clinical claims, harmful steering, and *any chapter-and-verse citation the app didn't supply*. A violation returns `response_rejected`; the app must show its error state, not a partial reflection.
- **`safetyNotice` in the response is mandatory UI when non-null** — it's PRD §25's crisis requirement, computed from the user's message independently of what the model returns.
- **`provider_busy` (503) means the free tier's project-wide quota is exhausted** — the whole app's AI is down, not one user's. The app should fall back to offline behaviour (saved Scriptures, reflections, local search) rather than implying user error.

Never put an API key in the Flutter app (§22/§23). The app sends its Firebase ID token; the Worker holds the key.

### App side (`features/conversation/data/`)

`AiDataSource` is the only file that knows the backend's wire format; `AiRepository` retrieves passages locally **then** calls it. `conversationTurnProvider` is keyed by message so a turn already answered is never re-requested — each call costs money or free-tier quota.

**The backend URL is a `--dart-define`, not a constant:**

```bash
# iOS simulator
fvm flutter run --dart-define=SELAH_AI_BASE_URL=http://localhost:8787
# Android emulator (10.0.2.2 = host machine)
fvm flutter run --dart-define=SELAH_AI_BASE_URL=http://10.0.2.2:8787
# Physical device — Mac's LAN IP, and run: npx wrangler dev --ip 0.0.0.0
fvm flutter run --dart-define=SELAH_AI_BASE_URL=http://192.168.1.42:8787
```

**iOS blocks LAN development traffic twice, and both failures are silent.** `ios/Runner/Info.plist` therefore carries:

- `NSAppTransportSecurity → NSAllowsLocalNetworking` — ATS blocks cleartext `http://` by default. Scoped to local addresses deliberately; **do not** replace it with `NSAllowsArbitraryLoads`, which disables ATS globally and needs justification at App Store review.
- `NSLocalNetworkUsageDescription` — since iOS 14 an app may not touch a `192.168.x.x` address without declaring why. Missing it makes the request *hang* rather than fail, so the UI sits on "Finding relevant Scripture…" with nothing in the console and nothing in `wrangler tail`.

iOS prompts for local-network permission on the first request — **tap Allow**, or every call fails afterwards. In production the URL is HTTPS to `*.workers.dev`, so neither key is exercised and no prompt appears.

Info.plist changes need a **full rebuild** — hot restart won't pick them up.

`AiDataSource` logs every request in debug (`[ai] POST …`, status, timing, and failure reason). If you see no `[ai]` line at all, the call never happened: check `AppConfig.isAiConfigured` (i.e. that `--dart-define` was passed).

**A build with no `SELAH_AI_BASE_URL` is a valid build**, not a broken one: `AppConfig.isAiConfigured` is false, the AI sections are simply absent, and Scripture search, the reader, saving, and reflections all still work. Every AI failure degrades the same way — the passages still render and the reason is shown with a retry, because the Scripture is the point and the commentary is the addition (§37).

`core/widgets/safety_notice.dart` renders `safetyNotice`. It is deliberately non-dismissible and uses the error container rather than the calm palette — it should interrupt the app's unhurried rhythm. Do not restyle it into the background.

Next: **Milestone 3** — the backend and RAG. This is the piece that replaces the curated topic catalog with real semantic retrieval, fills the deliberately-empty "why this passage" section in the conversation, and makes prayer starters genuinely generated. It needs two decisions first: where the backend lives (Firebase Functions vs. standalone) and an LLM API key — which must never reach the Flutter app (PRD §22/§23).

**"Delete my data" (§36) is implemented** — `features/profile/data/data_deletion_service.dart`. **Order is load-bearing:** conversations → library → user doc → auth account. `firestore.rules` scopes every operation to `request.auth.uid`, so deleting the account first would leave the data permanently unreachable *and* undeleted. It is deliberately not best-effort: a failure leaves the account intact so the user can retry, because half-deleting someone's reflections and orphaning the rest is worse than not starting. A fresh anonymous session is created afterwards, since §20 means an app with no identity can't save anything.

**Every Profile row responds to a tap.** Rows for unbuilt features (notifications, language) say *why* rather than "coming soon" — a user who learns only one translation is licensed understands the app; "coming soon" just reads as unfinished. Journey rows deep-link into Library tabs via `?tab=`. About/Privacy/Terms/Sources open `InfoSheet` with content from `core/constants/app_info_text.dart` — **that copy describes what the app actually does, so change it in the same commit as any change to data handling or the AI path.**

Still outstanding for release: reviewed Privacy and Terms documents at public URLs (both stores require them — Cloudflare Pages would host them free), notifications (§34), analytics (§35), and bundling the fonts.

### Deviations from the PRD's file list — keep or revisit deliberately

- `app/theme/{app_colors,app_typography,app_spacing}.dart` — the PRD lists only `app_theme.dart`; tokens were split out because there are ~70 of them. `app_theme.dart` re-exports all three, so importing it is enough.
- `app/app_shell.dart` — the bottom-nav scaffold had no home in the PRD's list.
- `features/onboarding/` — required by the §7 launch flow but missing from the §29 folder list.
- **No Dart splash screen.** `bootstrap()` completes its (bounded, local) init before `runApp`, so the **native** launch screen covers startup and no splash widget or loading gate is needed.

**Never add an unbounded `await` to `bootstrap()`.** Only local, fast work may block the first frame. Awaiting anonymous sign-in — a network round-trip — once caused a startup bug that looked like a Flutter quirk: with no Flutter UI produced for seconds, Android displayed the *previous run's task snapshot*, so the app appeared to open frozen on Home, flash the splash, then start. Sign-in is now started, given an 800 ms head start (`_sessionWarmupBudget`), and left to finish in the background; `uidChangesProvider` delivers the uid when it lands and the Firestore providers rebuild. Anything slow or network-bound belongs behind a provider with a loading state, not in `bootstrap()`. It's branded via the `flutter_native_splash` block in `pubspec.yaml` — regenerate with `fvm dart run flutter_native_splash:create` after any change there, and never hand-edit the generated `LaunchImage.imageset` / `drawable*/` / `styles.xml` files.
- `core/widgets/app_button.dart` and `app_text_field.dart` were **not** created — the theme's `filledButtonTheme` / `inputDecorationTheme` already produce the design's pill shapes, so wrappers would add indirection with no behavior. Real custom components live there instead: `scripture_card.dart`, `conversation_input.dart`, `section_label.dart`, `state_views.dart`.
- Fonts come from `google_fonts` (network fetch, then cached). Before release, bundle the EB Garamond and Manrope TTFs so a first launch offline still renders correctly (both are OFL).

### Brand assets

`assets/images/` — all derived from `selah_logo.png` (the supplied 1024² lockup: sun rising over an open book, matching the PRD §33 concept). The source is RGB with a **white background and no alpha**, which is why the derivatives exist:

| File | Purpose |
|---|---|
| `selah_logo.png` | original, untouched — white background, no alpha |
| `selah_logo_transparent.png` | white → alpha; light-mode splash |
| `selah_logo_dark.png` | inks remapped to `#BBCBB9` / `#E9C176`; dark-mode splash |
| `selah_emblem.png` | emblem only, re-centred; Android 12+ light |
| `selah_emblem_dark.png` | emblem only, recoloured; Android 12+ dark |

Two things to know before regenerating any of these: the brand green `#405E44` is **too dark to read on the charcoal dark surface**, so any dark-mode use needs the recoloured variant; and the usual min-channel "white to alpha" trick desaturates that green badly, so alpha was derived from luminance with colours preserved instead. The generator scripts are throwaway (they lived in the session scratchpad, not the repo) — if the logo is ever replaced, the conversions need redoing, and PIL/ImageMagick are not installed on this machine.

### Conventions established

- Read colors via `context.colors` / text via `context.text` / non-Material tokens via `context.selahColors` (extensions in `app_theme.dart`). Never hardcode a hex value in a widget.
- Navigate by name: `context.pushNamed(AppRoute.conversation.name, ...)`. Paths live only in `AppRoute`.
- All user-facing copy goes in `core/constants/app_strings.dart` — the wording is constrained by PRD §2/§18/§25/§34, so changing a string means re-checking those rules.
- Data-layer failures surface as the sealed `AppException` subtypes; `message` is user-safe, `cause` is for logs.
- Scrollable screens inside the shell pad their bottom with `AppShell.bottomInset(context)` to clear the translucent nav bar.

## Stack (do not substitute)

- **State:** Riverpod. Never introduce another state management framework.
- **Architecture:** feature-first MVVM — `VIEW → VIEWMODEL → REPOSITORY → DATA SOURCE`.
- **Backend:** Firebase (Anonymous Auth + Firestore).
- **Models:** Freezed + `json_serializable`. Skip codegen for trivial classes.
- **AI:** LLM via a secure backend with RAG over the Bible corpus. **Never** put AI API keys or any secret in the Flutter app.

## Folder structure

```
lib/
├── main.dart
├── bootstrap.dart
├── app/            app.dart, app_router.dart, app_theme.dart
├── core/           constants/, errors/, services/, utils/, widgets/
└── features/       home/ conversation/ scripture/ explore/ library/
                    reflection/ prayer/ profile/
                      ├── data/       models/, *_repository.dart,
                      │               *_repository_impl.dart, *_datasource.dart
                      ├── view/
                      └── viewmodel/
```

Generated Freezed/json files live beside their sources. Do **not** add a domain layer unless a feature genuinely needs one.

### Layer rules (hard boundaries)

| Layer | Owns | Must never contain |
|---|---|---|
| View | rendering, user interaction | Firebase/AI calls, business logic |
| ViewModel | UI state, orchestration, loading/error/success | widget code, Firebase details, credentials |
| Repository | coordinates data sources, app-friendly API | UI concerns |
| Data source | Firebase, Firestore, backend API, local storage | — |

Models are data only — never responsible for DB operations.

## Screens & flows (MVP)

First launch: `Splash → Onboarding → silent anonymous auth → Home`. **No login wall.** Firebase UID is the app identity.

Bottom nav: **Home · Explore · Library · Profile** (translucent blur, 0.5px top border, forest-green active state).

- **Home** — greeting (Good morning/evening), "What are you carrying today?", input "Share what's on your mind...", topic shortcuts (Fear, Purpose, Faith, Relationships, Forgiveness, Hope, Wisdom, Prayer), Today's Scripture card, reflection prompt.
- **Conversation** — the primary flow: user message → intent extraction → semantic retrieval → grounded LLM response. Rendered as **structured editorial sections**, not chat bubbles: Introduction → SCRIPTURE → WHY THIS PASSAGE → REFLECT → Continue. Each passage shows translation, text, book/chapter/verse, save, and "read context".
- **Explore** — search Scripture/topics/questions; category groups Emotions / Life / Spiritual Life; popular passages.
- **Scripture detail** — distraction-free reader: reference, translation, text, bookmark/share/copy/highlight, related passages, "Reflect on this passage".
- **Library** — tabs Saved | History (conversations with short titles like "Feeling behind in life").
- **Reflection** — Scripture + "What is this passage making you think about?" → save, or "Turn this into a prayer". Private by default.
- **Prayer starter** — labeled exactly "Prayer starter" (never "God's prayer" / "what God wants you to pray"); editable, savable, regenerable.
- **Profile** — Your Journey (saved, reflections, prayers, history), Preferences (translation, notifications, appearance, language), About (about, privacy, terms, Scripture sources), delete my data.

## AI behavior — non-negotiable

Selah does not replace God, the Holy Spirit, Scripture, pastors, churches, mentors, or professional care. The AI is a **Scripture discovery and reflection assistant** and must never imply divine authority.

**Never** generate: "God told me…", "The Holy Spirit told me…", "God wants you to…", "This is God's plan for your life…", invented verses or fabricated references, mental-health/medical diagnoses, instructions to stop treatment, encouragement toward isolation, or claims that the user should obey the AI.

**Use** framing like: "Scripture speaks about…", "Several passages address…", "The Bible describes…", "This passage may invite you to reflect on…"

Ground every biblical claim in retrieved Scripture only ("Only make biblical claims supported by the provided context"). Distinguish Scripture from interpretation. For severe distress or immediate danger, encourage trusted people and appropriate emergency/professional help — never imply Scripture alone suffices.

### RAG pipeline

`user message → intent/topic extraction → semantic search → passage selection → LLM with Scripture context → grounded response`. Never just ask the LLM for verses.

Structured response contract (rendered as independent sections, never one text blob):

```json
{ "acknowledgement": "...", "scriptures": [{"reference": "...", "reason": "..."}],
  "explanation": "...", "reflectionQuestion": "...", "followUpPrompt": "..." }
```

## Scripture corpus

Ships as a **bundled SQLite asset**: `assets/scripture/kjv.db` — 66 books, 1189 chapters, **31,102 verses**, 6.9 MB. Public-domain KJV, so no licensing risk (PRD §12).

Built by `tool/build_kjv_db.py` (committed, reproducible: `python3 tool/build_kjv_db.py`). Read that file's docstring before regenerating. It **refuses to emit a database** unless the corpus is exactly 66/1189/31102 with contiguous verse numbering and passes versification assertions — a Scripture app that silently drops verses is worse than one that fails loudly.

Decisions baked in, each with a reason worth keeping:

- **Source is `aruljohn/Bible-kjv`** (explicit verse numbers, so versification is verified not assumed). `thiagobodruk/bible` was **rejected** — it splits 3 John 1:14 and Revelation 12:17, which is Portuguese versification, not KJV. Any future source swap must pass the same assertions.
- **No FTS5.** Absent from Android's bundled SQLite below API 26. Search uses `LIKE`, which SQLite evaluates case-insensitively for ASCII, and the KJV text is pure ASCII — so there's no lowercased duplicate column either. ~33 ms full scan at this size.
- **Read-only, copied once.** sqflite needs a file path, so the asset is copied to the database dir on first launch, stamped with `ScriptureDatabase.schemaVersion` (bump it when the corpus changes). Fully offline, satisfying §37, and queries stay in SQLite rather than memory per §39.
- **Verse ids** are `{book_slug}_{chapter}_{verse}` → `psalms_23_1` (note: `psalms`, not the PRD's illustrative `psalm`). Bookmarks/reflections/prayers reference verses by this id, so it must stay stable across rebuilds.
- **`contextAround` is not semantic.** It returns adjacent verses. Real thematic relatedness needs embeddings, which arrive server-side in Milestone 3 — so the reader never implies a link the app can't justify.
- **Today's Scripture** draws from a curated 40-verse pool (`ScriptureDataSource.dailyPool`), rotating deterministically by date. Not random across all 31,102: an arbitrary verse (a genealogy, an imprecation) makes a poor daily invitation.
- **Topics are curated, not searched** (`topic_catalog.dart`, 20 topics × 5 verses). The words users think in are often absent from the KJV — "Relationships" appears nowhere, "Anxiety" only as "anxious"/"careful", "Decisions" not at all — so searching a topic name returns nothing for several of the app's own advertised topics. These are editorial choices the app owns, superseded by semantic retrieval in Milestone 3.

**Curated ids are verified, not trusted:** run `python3 tool/verify_topics.py` after editing `topic_catalog.dart` or `dailyPool` (140 ids currently). A bad id fails *silently* at runtime — the topic just shows nothing. This can't live in `flutter test` (opening the SQLite asset needs a platform); `test/topic_catalog_test.dart` covers structure and UI coverage instead.

User data (below) is separate and lives in Firestore. The corpus is app content, which is why `firestore.rules` grants no public read path at all.

### Firestore

Firestore (user data):

```
users/{uid}                          createdAt, updatedAt, selectedTranslation
  conversations/{id}                 title, createdAt, updatedAt
    messages/{id}                    role, content, createdAt
  bookmarks/{id}                     scriptureId, translation, createdAt
  reflections/{id}                   scriptureId, content, createdAt, updatedAt
  prayers/{id}                       scriptureId, content, createdAt
```

Security rules: a user reads/writes only their own data. Never allow cross-UID access. Conversations are sensitive personal data — don't ship conversation content into analytics.

Models: `Bookmark, Reflection, Prayer, Conversation, Message, Scripture`. `UserProfile` has no model — the user document is written directly by `LibraryDataSource.ensureProfile` and nothing reads it back yet.

**Only user messages are persisted.** The Scripture shown in reply is re-derived on replay, because retrieval is deterministic (same message + same corpus → same passages), so storing it would duplicate derivable data. This changes in Milestone 3: LLM responses are not reproducible, so assistant messages must be persisted then — `MessageRole.assistant` already exists for it.

**Deleting a conversation deletes its messages first, in a batch.** Firestore does not cascade: subcollections outlive a deleted parent, leaving orphaned messages the user can neither see nor remove.

**Conversation titles truncate the user's own words** rather than paraphrasing. The PRD's examples ("Finding direction", "Learning to forgive") are summaries only an LLM can write honestly; until then, truncation never misrepresents what someone said.

**Firestore models are hand-mapped, not `json_serializable`.** A Firestore document is not JSON: timestamps arrive as `Timestamp` and are written as `FieldValue.serverTimestamp()` sentinels, which a generated codec cannot round-trip. `fromDoc`/`toMap`/`newDoc` live on each model in `library_models.dart`. This is a deliberate deviation from the PRD's "use json_serializable for serialization" — `Scripture` still uses it, since it maps plain SQLite rows.

**Saved items store only `scriptureId`, never verse text.** The text is resolved from the local corpus in `FirestoreLibraryRepository`, so Scripture has one source of truth and saved items stay correct if the translation changes. The trade-off: an id absent from the current corpus renders a "not in the current Scripture library" card rather than a blank one.

**Bookmarks are keyed by `scriptureId`**, not an auto-id — so "is this saved?" is a single document read and saving is idempotent (double-tap can't duplicate).

## Design system

Tokens live in `selah/selah_scripture_companion/selah/DESIGN.md` — mirror them into `lib/app/app_theme.dart` rather than hardcoding colors in widgets.

- **Palette:** primary muted forest green `#283528`, surface warm ivory `#fcf9f8`, on-surface deep charcoal `#1c1b1b`, tertiary/accent gold (`#5f4402` / `#e9c176`), error `#ba1a1a`. Dark mode: deep charcoal-green surfaces, warm light text, slightly desaturated green.
- **Type:** **EB Garamond** (serif) for Scripture, headings, quotes — Scripture always gets maximum hierarchy (`display-scripture` 32/44). **Manrope** (sans) for nav, labels, body, settings. Scripture must feel visually distinct from AI text.
- **Spacing:** 8px unit, 24px container margin, 16px gutter, 40px+ section gaps between content types (Scripture vs. AI reflection).
- **Shape:** cards 16px (`rounded-lg`); buttons/inputs 24px or full pill. Thin monolinear icons with rounded terminals.
- **Depth:** tonal layers, not hard shadows. Ambient shadows only — 20–40px blur, 5–8% opacity, tinted with the primary green.
- **Feel:** sophisticated minimalism, heavy whitespace, center-aligned Scripture cards, left-aligned functional lists. Prayer/reflection cards use a light forest-green background with ivory text to separate "God's Word" from "My Prayer".

## Out of scope for MVP

Social/public profiles, user messaging, church or pastor accounts, donations, subscriptions, ads, leaderboards, gamification, badges, **streaks**, reading plans, voice, AI avatars, AI "prophecies". Also out: multiple translations, cross-references, study mode, group studies.

## Cross-cutting requirements

- **Every async operation** needs loading, success, error, and empty states. Never a blank screen. Design reference: `states_feedbacks/`.
- **Offline:** saved Scriptures, reflections, prayers, and history remain readable. AI requires network — show "You're offline. You can still read your saved Scriptures and reflections."
- **Performance:** paginate history and search, cache hot Scripture, never load the whole Bible into memory, efficient Firestore queries, handle AI streaming efficiently, avoid needless rebuilds.
- **Notifications:** optional gentle daily reminder ("A moment to pause."). Never guilt-based, never streak language.
- **Analytics:** privacy-conscious events only (`app_opened, conversation_started, scripture_viewed, scripture_saved, reflection_created, prayer_created, search_performed`).
- **Testing:** unit (Scripture search, repositories, ViewModel state, AI response parsing, bookmarks, reflections); widget (Home, Conversation, reader, Library); integration (launch → auth → conversation → retrieval → response → save → Library).

## Milestones

1. Flutter → Firebase → anonymous auth → Home
2. Scripture DB → search → reader
3. Question → backend → retrieval → AI → response
4. History → bookmarks → reflections → prayer
5. Testing → security → privacy → performance → store release

## Working agreements

- Don't change the architecture without explaining why first.
- Don't add packages unnecessarily; prefer stdlib Flutter/Dart.
- Keep all Firebase code in data/services layers; no Firebase calls in ViewModels; no business logic in widgets.
- No hardcoded secrets, ever.
- Every new file has a clear location and purpose. When delivering code, state the exact file path, give the **complete** file (no "rest of implementation…" placeholders), and explain how it connects to existing files.
- Run `fvm flutter analyze` / `fvm flutter test` from `selah/` — always via `fvm`, never a bare `flutter`.

## Final principle

Selah is not "ask AI anything" — it is "bring your questions to Scripture." The AI is the bridge; Scripture is the destination. Optimize for `conversation → Scripture → reflection`, not time in app.
