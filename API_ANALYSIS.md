# Citroën ConnectedCAM — Local API (reverse-engineered)

Reverse-engineered from a live packet capture of the official **ConnectedCAM Citroën** iOS app (v1.7.8)
talking to the camera over its WiFi AP. All traffic is **cleartext HTTP on port 80** (no TLS).

## Device under test

| Field | Value |
|---|---|
| Platform | Garmin VIRB-based dashcam (rebadged) |
| WiFi SSID | `ConnectedCAM0000` |
| Default WiFi password | `ConnectedCam` (changed to `Test1234` during testing — see `setWifiPassword`) |
| Camera IP / gateway | `192.168.0.1` |
| Firmware | `200` |
| vimVersion | `140` |
| Part number | `006-B2465-00` |
| deviceId | `1234567890` |

## Transport

- **Base URL:** `http://192.168.0.1`
- **Control endpoint:** `POST /virb` — single RPC endpoint; the action is the `command` field in a JSON body.
- **Media endpoint:** `GET /media/...` — plain file download, **no auth/handshake required**.
- The server is a minimal embedded HTTP server. It returns a bare `404` with no headers for any
  path/method it doesn't recognize (which is why blind probing/`GET /virb` finds nothing — `/virb`
  only answers **POST**).
- **Content-Type is ignored.** The app sends `application/x-www-form-urlencoded` but the body is JSON;
  the camera parses the body as JSON regardless. Use `application/json` for clarity.

### Exact request headers the app uses
```
POST /virb HTTP/1.1
Host: 192.168.0.1
Content-Type: application/x-www-form-urlencoded
Connection: keep-alive
Accept: */*
User-Agent: ConnectedCAM%20Citro%C3%ABn%C2%AE/1.7.8 CFNetwork/1410.1 Darwin/22.6.0
Content-Length: <n>

{"command":"...", ...}
```

> **Important (session model):** The app keeps **one persistent keep-alive TCP connection** for all
> control commands. The camera serves a single **active phone** at a time. Commands from a client that
> is not the active phone (or sent before the handshake) come back **empty** or with `result:9`.
> When building your own client, keep the connection alive and make sure no other phone is currently
> the active phone (close the official app first).

## State machine / handshake

```
1. Join WiFi AP  (WPA2, password = the AP password)
2. POST initialConnection {phoneId, timestamp}
      → result:9 + deviceInfo  while setupComplete:0  (camera not finished first-time setup)
      → result:1 + deviceInfo + activePhoneId   once setupComplete:1
3. POST activePhoneRequest {phoneId}    → become the ACTIVE phone (result:1, activePhoneId == your phoneId)
4. POST periodicUpdate {phoneId}        → keep-alive heartbeat every 3 s (GPS, flags, who is active/primary)
5. Now control + media commands work: mediaList, snapPicture, deleteFile, ...
```

- The official app sends `initialConnection` once when it opens, then keeps the session alive with
  a `periodicUpdate` heartbeat every **3 s**; when the heartbeat fails it re-runs the handshake.
- `phoneId` is a client-generated UUID (uppercase, e.g. `00000000-0000-4000-A000-000000000001`).
  Generate once and reuse for the lifetime of the client.
- **primaryPhoneId** = first phone to pair (owner). **activePhoneId** = phone currently in control.
  `activePhoneId == "INVALID_ID"` means nobody is in control.

## Result codes (empirical)

| `result` | Meaning |
|---|---|
| `1`  | Success |
| `5`  | Nothing to do (seen on `downloadShareImage` when no photos are queued to share) |
| `9`  | Not ready / not the active phone / setup incomplete |
| `11` | Error (observed as the `deleteFile` failure response, echoed with `cmdRequestId:4`) |
| `3`  | Request denied (seen on phone-request commands before `initialConnection`) |

## `cmdRequestId` is a fixed per-command opcode (NOT a counter)

The response echoes a fixed id per command — use it to match async responses on the shared connection:

| cmdRequestId | command |
|---|---|
| 0  | initialConnection |
| 1  | snapPicture |
| 2  | mediaDirList |
| 3  | mediaList |
| 5  | downloadShareImage |
| 6  | deleteFile |
| 7  | periodicUpdate |
| 10 | setWifiPassword |
| 11 | primaryPhoneRequest |
| 12 | activePhoneRequest |
| 4  | deleteFile (error response — success echoes 6) |
| 14 | setSaveVideoDuration |

## Commands (observed)

### initialConnection
```json
{"command":"initialConnection","phoneId":"<UUID>","timestamp":"2026/06/27 13:04:55"}
```
Response (set up):
```json
{"result":1,"cmdRequestId":0,"activePhoneId":"<UUID>","setupComplete":1,
 "deviceInfo":[{"wifiSSID":"ConnectedCAM0000","firmware":200,"vimVersion":140,
 "partNumber":"006-B2465-00","deviceId":1234567890}]}
```

### activePhoneRequest
```json
{"command":"activePhoneRequest","phoneId":"<UUID>"}
→ {"result":1,"cmdRequestId":12,"activePhoneId":"<UUID>"}
```

### primaryPhoneRequest
```json
{"command":"primaryPhoneRequest","phoneId":"<UUID>"}
→ {"result":1,"cmdRequestId":11,...}
```

### periodicUpdate  (status poll / keep-alive — the official app sends it every 3 s)
```json
{"command":"periodicUpdate","phoneId":"<UUID>"}
→ {"result":1,"cmdRequestId":7,"gpsLatitude":45.4642,"gpsLongitude":9.1896,"gpsSpeed":0,
   "activePhoneId":"<UUID>","numPhotosToShare":0,"lastMediaEventTime":35784,"incidentDetected":0,
   "primaryPhoneId":"<UUID>","numberOfConnections":1,"saveVideoDuration":20,"needFormat":0,
   "faultDescription":"No Fault"}
```
(GPS fields only present once the camera has a fix.)

### mediaList
```json
{"command":"mediaList"}
→ {"media":[ <MediaItem>, ... ]}
```
Only ever returns `VID_NORM` videos and `PHOTO` stills — clips in `VID_SAVE` and `INCIDENT`
(see `mediaDirList`) are **not** listed here. Whether those folders can be enumerated another way
is still open.

### mediaDirList
```json
{"command":"mediaDirList","phoneId":"<UUID>"}
→ {"mediaDirs":[
   {"type":"mediadirectory","path":"D:/DCIM/VID_NORM/","date":1152875494},
   {"type":"mediadirectory","path":"D:/DCIM/VID_SAVE/","date":1152875494},
   {"type":"mediadirectory","path":"D:/DCIM/INCIDENT/","date":1152875494},
   {"type":"mediadirectory","path":"D:/DCIM/PHOTO/","date":1152875494}],
   "result":1,"cmdRequestId":2}
```
The four on-camera media folders. `VID_NORM` = continuous recordings, `VID_SAVE` = manually
saved/protected clips, `INCIDENT` = crash-triggered clips, `PHOTO` = stills. The `date` is a fixed
placeholder (2006), not meaningful. The official app doesn't send this command; found by probing.

### snapPicture  (take a photo now)
```json
{"command":"snapPicture"}
→ {"result":1,"cmdRequestId":1,"media":{"type":"photo",
   "url":"http://192.168.0.1/media/photo/DCIM/PHOTO/2026_06_27_13h06_1.JPG",
   "thumbUrl":"http://192.168.0.1/media/thumb/photo/DCIM/PHOTO/2026_06_27_13h06_1.JPG",
   "name":"2026_06_27_13h06_1.JPG"}}
```

### deleteFile
```json
{"command":"deleteFile","files":["http://192.168.0.1/media/video/DCIM/VID_NORM/2026_06_27_13h01_v.MP4"]}
→ {"result":1,"cmdRequestId":6}
```
On failure the camera answers `{"result":11,"cmdRequestId":4}` instead — observed on 2026-07-13
when deleting a file that likely belonged to the still-active recording session.

### setWifiPassword
```json
{"command":"setWifiPassword","newPassword":"<new-password>","oldPassword":"ConnectedCam","phoneId":"<UUID>"}
→ {"result":1,"cmdRequestId":10}
```
> Changing this disconnects all WiFi clients; they must reconnect with the new password.

### setSaveVideoDuration
```json
{"command":"setSaveVideoDuration","phoneId":"<UUID>","length":"30"}
→ {"result":1,"cmdRequestId":14}
```
> `length` is the saved-clip length in seconds, sent as a JSON *string*. Read the current value
> back from `periodicUpdate`'s `saveVideoDuration` field.

### downloadShareImage / ackDownloadShareImage  (incident-photo sharing flow)
```json
{"command":"downloadShareImage","phoneId":"<UUID>"}
→ {"result":1,"cmdRequestId":5,"numPhotosToShare":1,
   "files":["http://192.168.0.1/media/photo/DCIM/PHOTO/2026_06_27_13h06.JPG"]}

{"command":"ackDownloadShareImage","phoneId":"<UUID>","urlsReceived":"1"}
```

## MediaItem schema

```jsonc
// video
{"type":"video","url":"http://192.168.0.1/media/video/DCIM/VID_NORM/2026_06_27_11h57_v.MP4",
 "thumbUrl":"http://192.168.0.1/media/thumb/video/DCIM/VID_NORM/2026_06_27_11h57_v.BMP",
 "sessionId":249,"gpsLatitude":45.464200,"gpsLongitude":9.189600,"videoType":0,"validTime":1,
 "name":"2026_06_27_11h57_v.MP4","fileSize":167772160,"date":1782554222}
// photo
{"type":"photo","url":"http://192.168.0.1/media/photo/DCIM/PHOTO/2026_06_27_13h06.JPG",
 "thumbUrl":"http://192.168.0.1/media/thumb/photo/DCIM/PHOTO/2026_06_27_13h06.BMP",
 "gpsLatitude":45.464350,"gpsLongitude":9.189450,
 "name":"2026_06_27_13h06.JPG","fileSize":2097152,"date":1782558364}
```
- `date` is a Unix epoch (seconds).
- `fileSize` for videos is a fixed/placeholder value (160 MB) in the listing, not the true byte size.
- `videoType` 0 = normal recording (`VID_NORM`). Saved and incident clips live in the `VID_SAVE`
  and `INCIDENT` folders (confirmed via `mediaDirList`) but do not appear in `mediaList` output.
- `validTime` 1 = the camera had a time/GPS fix for the clip; `validTime:0` entries carry no GPS
  fields and their `date` is unreliable (seen on the first clip after power-on).

## Media download (no handshake required)

| Kind | GET path | Content-Type |
|---|---|---|
| Video | `/media/video/DCIM/VID_NORM/<name>.MP4` | `video/mp4` |
| Photo | `/media/photo/DCIM/PHOTO/<name>.JPG` | `image/jpeg` |
| Video thumb | `/media/thumb/video/DCIM/VID_NORM/<name>.BMP` | `image/bmp` |
| Photo thumb | `/media/thumb/photo/DCIM/PHOTO/<name>.BMP` | `image/bmp` |
| GPS track | `/media/gpx/DCIM/VID_NORM/<video-base>.GPX` | (GPX/XML) |

The **`/media/gpx/` route exists** (returns `200`, where invented routes like `/media/fit/`,
`/media/data/`, `/media/lowres/` return `404`): the camera generates a GPX track per clip from its
embedded GPS. Confirmed empty (`0 bytes`) for a `validTime:0` clip (no GPS fix); a `validTime:1`
clip is expected to return a real track — re-verify on one. No handshake needed (plain file GET).
No low-res proxy is served (`VID_LOW`, `/media/lowres/`, `_low` naming all `404`).

Videos are served with `Accept-Ranges`-style progressive download; the app fetches them with a
libavformat client (`User-Agent: Lavf/56.36.100`), i.e. ffmpeg-based playback.

## Command probing (the empty-response oracle)

This firmware answers an **unknown command with `HTTP 200` and a 0-byte body**, and a recognized
command with a JSON body. That makes command discovery easy: POST a candidate name and treat any
non-empty response as a supported command. Used to map the surviving command set below
(2026-07-13, firmware 200 / vimVersion 140, part 006-B2465-00).

**Confirmed present:** `initialConnection`, `activePhoneRequest`, `primaryPhoneRequest`,
`periodicUpdate`, `mediaList`, `mediaDirList`, `snapPicture`, `deleteFile`, `setSaveVideoDuration`,
`setWifiPassword`, `downloadShareImage` / `ackDownloadShareImage`.

**Probed and ABSENT** (documented Garmin VIRB commands PSA stripped — all return empty):
`livePreview`, `features`, `sensors`, `commandList`, `deviceInfo` (as a standalone command — its
data only ships inside `initialConnection`), `status` (this firmware uses `periodicUpdate` instead),
`getErrorLogUrl`, `found`. There is **no live-preview / streaming command and no features/sensors
settings subsystem** on this firmware.

## Network surface (2026-07-13 scan)

- **Only TCP 80 is open** on `192.168.0.1`. No RTSP (554), RTMP (1935), telnet, SSH, or FTP —
  so live video streaming is not possible even outside the command layer.
- The HTTP server exposes only `/virb` (the command endpoint) and `/media/...` (file/thumb
  download). Every other path (`/`, `/media/`, `/status`, `/cgi-bin/`, …) returns 404; there is no
  directory listing or web UI.

## App binary analysis (the official app is a rebranded Garmin VIRB app)

Static analysis of the official Android APK (`com.psa.citroen.connectedcam`, v1.5.1, 2017) shows the
ConnectedCAM app is Garmin's **VIRB Mobile** app reskinned: UI classes live under
`com.garmin.android.apps.virb.*` with Citroën event wrappers, and the entire camera protocol client
is a shared C++ core (`core/shared/libs/camera/`, files `CameraAdapter.cpp`, `MediaListController.cpp`,
`MediaItem.cpp`, `PeriodicStatus.cpp`, …) compiled into `lib/armeabi-v7a/libcamera.so`. JSON is built
with `libjsoncpp`, HTTP via `libcpprest`, video via bundled FFmpeg (`libav*` → the `Lavf` user-agent).

**Full command vocabulary the app knows** (from `libcamera.so` `CameraAdapter_t` methods — a superset
of what this firmware implements; see the probe results above for what actually answers):
`initialConnection`, `activePhoneRequest`, `primaryPhoneRequest`, `foundCamera`, `periodicUpdate`,
`mediaList`, `mediaDirList`, `snapPicture`, `deleteFile`, `clearAllMedia`, `startRecording`,
`stopRecording`, `stopStillRecording`, `setSaveVideoDuration`, `updateFeature`, `getFeatures`,
`getStatus`, `livePreview`, `stopStream`, `locateCamera`, `formatUnit`, `setWifiPassword`,
`checkWifiPassword`, `downloadShareImage` / `ackDownloadShareImage`, `videoStitch`.

**Live preview mechanism** (present in the app, absent from this firmware): `livePreview` is sent with
`streamType:"rtp"`; the camera returns a URL (`CameraAdapter_t::LivePreviewUrl`), and the app plays it
as an **RTP / H.264** stream decoded through FFmpeg (`video::AndroidRTPVideoDecodingStrategy`). The app
guards it with `unsupported_live_preview_while_recording`. On this camera the command returns empty
(stripped from the firmware), and no RTP/RTSP port is open — so live view is not achievable here.

**Fields the app's models carry** (some unused by this firmware — worth probing whether it populates
them for saved/incident clips): per-clip `fitURL` and `gpxUrl` (downloadable **GPS track** in FIT/GPX
form), `lowResVideoPath` (low-res proxy for fast preview), and richer `periodicUpdate` telemetry
`gpsSpeed` / `gpsAccuracy` / `gpsLastTime`. Also `friendlyName` (camera naming), `otaUploadUrl`
(firmware push — do not touch), and a share-list flow (`getShareList`, `numPhotosToShare`) that is the
likely path to incident clips.

## Still unknown / TODO

- **Can `VID_SAVE` / `INCIDENT` clips be listed?** `mediaDirList` proves the folders exist, but
  `mediaList` omits them. Next: create a saved clip via the official app, then re-run `mediaList`
  and check whether it appears (and in which folder), or capture the app while it views a saved /
  incident clip to learn the listing mechanism.
- `formatUnit` (format SD) and `updateFeature` were **not** tested — deliberately excluded from
  probing as destructive/stateful. Their presence on this firmware is unknown.
- **GPS export via `/media/gpx/`** — confirmed the route exists; still need one fetch against a
  `validTime:1` clip to capture a real GPX body and its schema, and to check whether `VID_SAVE` /
  `INCIDENT` clips expose GPX too. This is the most promising net-new feature (per-clip route maps).
- Probe results (2026-07-13): `locateCamera`, `getShareList`, `foundCamera` → **absent** (empty);
  `downloadShareImage` → **present** (idle `result:5`); low-res proxy → **absent** (404).
- `startRecording` / `stopRecording` remain untested — they change camera state, so left for a
  deliberate, careful check rather than blind probing.

## How this was captured (repeatable)

```bash
# 1. Mirror the iPhone running the app over USB
rvictl -s <iphone-udid>            # creates rvi0
# 2. Capture all camera traffic to a pcap (run in a real terminal; needs sudo)
sudo tcpdump -i rvi0 -s 0 -U -w cam_capture.pcap 'host 192.168.0.1'
# 3. Use the app, then Ctrl-C. Read it back (cleartext, so strings works without tshark):
strings -n 4 cam_capture.pcap | grep -aE '^\{"command"|^\{"result"|^(POST|GET) '
# stop mirroring:
rvictl -x <iphone-udid>
```
