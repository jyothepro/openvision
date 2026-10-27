# Glasses tap control and Ready mode

## Locked-phone workflow

1. Select a configured **OpenAI** backend and **Apple (system voice)** in Settings.
2. Open Voice and allow speech recognition and microphone access.
3. Connect the glasses as a Bluetooth audio device, then tap **Enable Ready Mode**.
4. Wait for **Ready — lock your phone and tap your glasses**, then lock the phone.
5. Tap to start a conversation, hear the chime, and ask questions or follow-ups.
   Tap again to end the conversation. Maya returns to local standby for the next tap.
6. Tap **Turn Off** or leave the Voice screen to release Ready mode.

Ready mode is explicit and is not restored automatically after relaunch. It holds
a real recording audio engine between conversations. Standby buffers are discarded:
they are not saved, transcribed, or sent to a provider. The microphone stays active,
with the system microphone indicator and battery cost. Speech during an active
conversation uses the normal speech-recognition and selected AI provider pipeline.

Audio interruption pauses readiness and releases media handlers. An interruption
ending with iOS's `shouldResume` signal attempts to re-arm; glasses reconnection
also attempts recovery. Otherwise the status remains paused and **Retry Ready Mode**
lets the user re-arm from the foreground. Audio-service resets or standby engine
configuration changes pause with a visible explanation. Live video is unavailable
in Ready mode because it owns a different audio/camera pipeline.

Conversation transitions observe service publishers directly, independently of
SwiftUI rendering while locked. Stopping cancels pending connection and command
tasks; canceled OpenAI requests cannot deliver replies or start another tool call.

## Basic media controls

Enable **Settings → Voice Control → Glasses Tap Control**, then return to Voice.
Allow microphone and speech recognition access first. The glasses must be paired
as a Bluetooth audio accessory; Meta camera registration alone is insufficient.

While iOS delivers media commands to Maya:

- Play starts a conversation and plays the existing activation chime once ready.
- Pause or Stop ends the conversation; Toggle alternates between start and end.
- Follow-up questions use the existing conversation timeout and voice pipeline.
- Leaving Voice releases the handlers and Now Playing information.

The same commands can come from headphones, Control Center, or the Lock Screen.
This is an opt-in because it takes ownership of media controls while Voice is open.
The feature uses Apple's `MPRemoteCommandCenter`, not a raw Meta touch event.

## Limits

Ready mode implements the background audio lifecycle, but physical-device
validation is still required before advertising reliable pocket activation.
It cannot guarantee delivery after force-quit, termination, Bluetooth loss, or
another app taking media controls. No silent playback loop is used. iOS must keep
the recording session running and route accessory media events to this app.
Playing music can take that ownership away; retry Ready mode in the foreground.
Ready mode currently requires OpenAI and system TTS; MLX and Kokoro use the GPU.
Automatic language selection and interruption without a wake phrase are not added
by this change.

## Physical-device acceptance checks

1. Leave the setting off: glasses media gestures should retain normal behavior.
2. Enable it, return to Voice, and tap: verify one conversation and one chime in
   the glasses. Ask a question and a follow-up.
3. Tap during a reply: verify output stops and no delayed response resumes.
4. Enable Ready mode, lock the phone and repeat after 1, 5, 15, and 30 minutes idle.
   Verify an entire question/reply/follow-up loop and another tap after ending it.
   Confirm speech in standby never creates a request or a conversation entry.
5. Play music, receive a phone call, disconnect/reconnect glasses, and verify
   that returning to Voice restores controls without duplicate callbacks.
6. Leave Voice or disable the setting: verify Maya no longer handles media taps.
7. Turn Ready mode off: confirm the recording engine stops, the microphone indicator
   clears, and no pending OpenAI reply resumes speech. Try ending during connection.

Reference: [Apple remote command documentation](https://developer.apple.com/documentation/mediaplayer/mpremotecommandcenter).
