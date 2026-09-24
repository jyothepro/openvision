# Meta Connect 2026: opportunities for OpenVision

Research date: 2026-09-24

## Bottom line

Yes. The useful announcement is **Wearables Device Access Toolkit (DAT) 1.0**, not the broader VR/Horizon news. OpenVision is already a native iOS DAT app, so it can keep its existing app, AI backends, and App Store identity while adopting new glasses capabilities. The highest-value work is to (1) evaluate the 0.9.0 → 1.0 SDK upgrade, (2) replace or complement the app-owned wake-word path with system-level **“Hey Meta” invocation and DAT speech/ASR**, and (3) add an optional display experience for Meta Ray-Ban Display. Motion/gesture input and Meta's upcoming discovery surfaces are good follow-ons.

Do **not** pivot OpenVision into a web app or Meta AI Connector. Those are complementary distribution paths, but they would give up much of the app's differentiator: user-selectable cloud/on-device models, private local vision and TTS, Apple-native tools, and a mature iOS orchestration layer.

## What Meta announced

Meta says DAT 1.0 is now a stable, supported release after a year in developer preview, with rollout beginning **September 30, 2026**. A single integration spans display and displayless AI glasses and adds or highlights:

- hands-free **“Hey Meta” invocation**;
- automatic speech recognition and voice streaming;
- camera capture;
- motion tracking for head movement/orientation;
- display and input support on compatible glasses, including Meta Neural Band swipes.

Meta also announced two alternative paths: web apps for Meta Ray-Ban Display (including WebMCP in developer preview) and Meta AI Connectors, which expose an API or MCP service inside Meta AI. Apps built with DAT and web apps are expected to become discoverable on-device and in a curated Meta AI app section; submission details are still forthcoming.

Sources: [Meta Connect 2026 recap](https://developers.meta.com/blog/meta-connect-recap/), [DAT product page](https://developers.meta.com/wearables/device-access-toolkit/), [official Wearables FAQ](https://developers.meta.com/wearables/faq/).

## Why this maps directly to OpenVision

OpenVision already uses Meta's iOS DAT SDK for registration, device sessions, camera streaming, and photo capture. It is pinned to `meta-wearables-dat-ios` **0.9.0** and currently links only `MWDATCore` and `MWDATCamera` (`project.yml`; `OpenVision/Managers/GlassesManager.swift`). Its own feature set already covers the main AI-assistant loop—camera context, voice, multiple cloud and on-device models, native tools, TTS, memory, and face recognition (`README.md`; `docs/architecture.md`).

That makes the Connect news an incremental platform upgrade rather than a new product direction.

## Recommended opportunities, in order

### 1. Audit and adopt DAT 1.0

**Priority: immediate / prerequisite**

Create a short-lived upgrade branch and compile against DAT 1.0 before designing new features. OpenVision is already on the 0.9 camera lifecycle (`DeviceSession` → `Camera` → `Camera.stream`), so the migration should be narrower than earlier DAT jumps, but the 1.0 API surface and firmware compatibility still need device verification.

Acceptance checks should cover registration/unregistration, permission prompts, session start/stop, raw frame delivery, photo capture, reconnect behavior, background/foreground transitions, audio routing, and the supported hardware families: Ray-Ban Meta Gen 1/Gen 2, Ray-Ban Meta Display, Oakley Meta HSTN, and Oakley Meta Vanguard. Capabilities vary by device. Keep the current explicit SDK pin until those checks pass.

Why first: the public iOS repository's latest indexed changelog documents the 0.9 lifecycle OpenVision uses, while Meta's Connect post announces 1.0. The gap means implementation details should be verified against the 1.0 package/docs rather than inferred from the marketing recap. MockDeviceKit can simulate media streaming, permissions, and device state without glasses, but Meta says it currently does **not** simulate display glasses, so the display path still needs physical-hardware testing.

Sources: [official iOS DAT repository](https://github.com/facebook/meta-wearables-dat-ios), [official DAT changelog](https://github.com/facebook/meta-wearables-dat-ios/blob/main/CHANGELOG.md), [Meta's DAT integration examples](https://developers.meta.com/blog/explore-whats-possible-with-wearables-device-access-toolkit/), [official Wearables FAQ](https://developers.meta.com/wearables/faq/).

### 2. Add system “Hey Meta” launch and DAT speech as an optional input path

**Priority: highest user impact**

OpenVision currently owns activation with “Hi Maya,” iOS speech recognition, and its audio-session lifecycle. DAT 1.0's “Hey Meta” invocation plus automatic speech recognition could remove the requirement that OpenVision already be foregrounded/listening and reduce the fragility of a continuously managed wake-word loop.

Recommended product behavior:

1. “Hey Meta, open/talk to Maya” launches or focuses OpenVision.
2. DAT-provided speech supplies the initial intent where supported.
3. OpenVision preserves its own conversation mode, backend selection, tool execution, and local/cloud privacy choices after handoff.
4. “Hi Maya” remains available as a fallback and for users who prefer the existing identity.

This needs an explicit privacy and latency comparison before replacing any existing path. The recap confirms the capability but does not specify whether raw audio, transcripts, invocation payloads, background duration, or locale coverage meet OpenVision's requirements.

Source: [Meta Connect 2026 recap, AI glasses section](https://developers.meta.com/blog/meta-connect-recap/#ai-glasses-new-ways-to-build-and-new-surfaces-where-people-can-find-what-you-ship).

### 3. Build a thin display companion for Meta Ray-Ban Display

**Priority: high, hardware-gated**

OpenVision currently has no display module. A display surface would materially improve its strongest workflows without changing the AI architecture:

- live transcript and short answer cards;
- translation text while keeping audio responses;
- tool confirmations (timer created, reminder time, calendar event);
- navigation-style step cards for cooking, repair, and instructions;
- a privacy/status indicator showing whether inference is local or cloud;
- compact choices/confirmations before consequential tool actions.

Keep the display renderer as a capability adapter driven by the existing `VoiceAgentViewModel`/backend events; do not put AI or tool logic in the display layer. On displayless glasses, retain the current audio behavior unchanged.

The official 0.9 changelog already includes display components such as `ButtonGroup`, and Meta says DAT spans display and displayless devices. OpenVision would likely need the SDK's display product/module plus capability checks, but exact 1.0 APIs should be taken from the current reference at implementation time.

Sources: [DAT capabilities page](https://developers.meta.com/wearables/device-access-toolkit/), [official iOS DAT changelog](https://github.com/facebook/meta-wearables-dat-ios/blob/main/CHANGELOG.md).

### 4. Use motion and gestures for low-friction control

**Priority: medium; prototype after voice/display**

Useful mappings include nod to confirm, shake to cancel, head-stillness to pause frame sampling, and Neural Band swipe to move between concise answer cards. These are especially valuable when speech is socially awkward or noisy.

Treat these as explicit, reversible shortcuts—not silent inference. Add calibration, accessibility toggles, debounce/cooldown logic, and audio confirmation. The recap confirms head orientation/movement and Neural Band navigation but does not establish precision, sampling rates, supported devices, or accessibility behavior, so validate those before committing UX.

Sources: [Meta Connect 2026 recap](https://developers.meta.com/blog/meta-connect-recap/), [DAT capabilities page](https://developers.meta.com/wearables/device-access-toolkit/).

### 5. Prepare for Meta's discovery/submission channel

**Priority: medium, low engineering cost now**

Meta says compatible DAT apps will soon be discoverable on Meta Ray-Ban Display and in the Meta AI app, but submission details are not yet published. OpenVision should create a Wearables Developer Center organization/project, ensure its production registration and privacy disclosures are ready, collect a short hands-free demo, and track the approval announcement. This could be a more important growth channel than building a separate web surface.

Do not promise availability yet: Meta explicitly says details are coming soon.

Source: [Meta Connect 2026 recap, discovery section](https://developers.meta.com/blog/meta-connect-recap/#ai-glasses-new-ways-to-build-and-new-surfaces-where-people-can-find-what-you-ship).

## Lower-priority announcements

### Web apps and WebMCP

Useful for a lightweight public demo or a narrow companion experience on Display, but not a replacement for the iOS app. OpenVision relies on native Bluetooth/DAT integration, Apple frameworks, MLX models, audio routing, local storage, and on-device vision/TTS. Rebuilding those advantages as a web app would fragment the product. WebMCP is worth watching as a future adapter for exposing a small, safe subset of OpenVision tools, not as the core architecture.

### Meta AI Connectors

A connector could expose an OpenVision-hosted service or MCP tool inside Meta AI and create a new acquisition path. However, it would place Meta AI—not OpenVision's user-selected backend and local inference—as the conversational shell. Consider it only if there is a specific server-side OpenVision service worth exposing. The current app is primarily device- and phone-local, so there is no obvious first connector.

### Meta Model API / Muse models

Potential future backend, but not uniquely useful to the glasses experience. OpenVision already has a clean `AIBackend` seam and multiple local/cloud choices. Evaluate only when official model/API documentation shows a compelling combination of vision, realtime voice, tool calling, latency, and price. The Connect recap alone is insufficient reason to add a sixth backend.

### VR and Horizon announcements

Not relevant to OpenVision's current iOS AI-glasses scope. They target VR/Quest-style apps, game creation, and separate hardware/workflows.

## Proposed roadmap

1. **One spike:** compile and run OpenVision against DAT 1.0, record API changes and device/firmware matrix.
2. **One user-facing win:** prototype “Hey Meta → Maya” invocation while retaining the current wake word.
3. **One hardware-gated prototype:** render transcript, answer, and tool-confirmation cards on Meta Ray-Ban Display.
4. **Then:** test motion/gesture shortcuts and prepare the discovery submission package.

## Unknowns to verify before implementation

- DAT 1.0's exact iOS package version/tag and module names.
- Whether “Hey Meta” can launch a third-party app with a passed utterance, and its review/configuration requirements.
- Whether DAT ASR returns transcripts, audio frames, or both; supported locales; background behavior; and privacy/data processing terms.
- Motion sample types, rates, device coverage, and power cost.
- Display layout limits, supported interactive components, focus behavior, and fallback rules.
- Production distribution eligibility, review criteria, and timeline for Meta AI/on-device discovery.

Until the 1.0 API reference answers these, treat the recap's capability list as product direction, not an implementation contract.
