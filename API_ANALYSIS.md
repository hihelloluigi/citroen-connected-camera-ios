# Citroën ConnectedCAM — Local API (reverse-engineered)

Reverse-engineered from a live packet capture of the official **ConnectedCAM Citroën** iOS app (v1.7.8)
talking to the camera over its WiFi AP. All traffic is **cleartext HTTP on port 80** (no TLS).

## Device under test

| Field | Value |
|---|---|
| Platform | Garmin VIRB-based dashcam (rebadged) |
| WiFi SSID | `ConnectedCAM0690` |
| Default WiFi password | `ConnectedCam` (changed to `Test1234` during testing — see `setWifiPassword`) |
| Camera IP / gateway | `192.168.0.1` |
| Firmware | `200` |
| vimVersion | `140` |
| Part number | `006-B2465-00` |
| deviceId | `3939980690` |

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
- `phoneId` is a client-generated UUID (uppercase, e.g. `0AC33FDC-DDB8-46F3-B190-F51569FF21E3`).
  Generate once and reuse for the lifetime of the client.
- **primaryPhoneId** = first phone to pair (owner). **activePhoneId** = phone currently in control.
  `activePhoneId == "INVALID_ID"` means nobody is in control.

## Result codes (empirical)

| `result` | Meaning |
|---|---|
| `1`  | Success |
| `9`  | Not ready / not the active phone / setup incomplete |
| `11` | Error (observed as the `deleteFile` failure response, echoed with `cmdRequestId:4`) |
| `3`  | Request denied (seen on phone-request commands before `initialConnection`) |

## `cmdRequestId` is a fixed per-command opcode (NOT a counter)

The response echoes a fixed id per command — use it to match async responses on the shared connection:

| cmdRequestId | command |
|---|---|
| 0  | initialConnection |
| 1  | snapPicture |
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
 "deviceInfo":[{"wifiSSID":"ConnectedCAM0690","firmware":200,"vimVersion":140,
 "partNumber":"006-B2465-00","deviceId":3939980690}]}
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
→ {"result":1,"cmdRequestId":7,"gpsLatitude":45.7089,"gpsLongitude":9.6965,"gpsSpeed":0,
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
{"command":"setWifiPassword","newPassword":"Test1234","oldPassword":"ConnectedCam","phoneId":"<UUID>"}
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
 "sessionId":249,"gpsLatitude":45.708911,"gpsLongitude":9.696649,"videoType":0,"validTime":1,
 "name":"2026_06_27_11h57_v.MP4","fileSize":167772160,"date":1782554222}
// photo
{"type":"photo","url":"http://192.168.0.1/media/photo/DCIM/PHOTO/2026_06_27_13h06.JPG",
 "thumbUrl":"http://192.168.0.1/media/thumb/photo/DCIM/PHOTO/2026_06_27_13h06.BMP",
 "gpsLatitude":45.709058,"gpsLongitude":9.696463,
 "name":"2026_06_27_13h06.JPG","fileSize":2097152,"date":1782558364}
```
- `date` is a Unix epoch (seconds).
- `fileSize` for videos is a fixed/placeholder value (160 MB) in the listing, not the true byte size.
- `videoType` 0 = normal recording (`VID_NORM`); incident/locked clips likely use a different folder/type.
- `validTime` 1 = the camera had a time/GPS fix for the clip; `validTime:0` entries carry no GPS
  fields and their `date` is unreliable (seen on the first clip after power-on).

## Media download (no handshake required)

| Kind | GET path | Content-Type |
|---|---|---|
| Video | `/media/video/DCIM/VID_NORM/<name>.MP4` | `video/mp4` |
| Photo | `/media/photo/DCIM/PHOTO/<name>.JPG` | `image/jpeg` |
| Video thumb | `/media/thumb/video/DCIM/VID_NORM/<name>.BMP` | `image/bmp` |
| Photo thumb | `/media/thumb/photo/DCIM/PHOTO/<name>.BMP` | `image/bmp` |

Videos are served with `Accept-Ranges`-style progressive download; the app fetches them with a
libavformat client (`User-Agent: Lavf/56.36.100`), i.e. ffmpeg-based playback.

## Still unknown / TODO (needs another capture)

- **Live preview**: no `livePreview`/RTSP/MJPEG seen — live view was not exercised in this capture.
  Re-capture while opening live view to learn the stream command + URL (likely a progressive MP4 over
  HTTP given the Lavf client).
- Remaining settings commands (e.g. `updateFeature`, format SD = `formatUnit`).
- Incident/locked-video folder naming.

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
