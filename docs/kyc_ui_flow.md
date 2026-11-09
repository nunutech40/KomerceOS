# KYC UI flow (branch `aris-sprint-kyc`)

Design reference: [Sprint 3 — Update 13.10.2026 KYC](https://www.figma.com/design/LkqSMbnuKrsmb34GSfECVO/Sprint-3?node-id=1558-31685).

## Current path

1. `verification_ktp_status = 0`: show paid verification offer; the existing payment API is called before KYC begins.
2. `verification_ktp_status = 5` (paid) or `3` (retry): open identity introduction without another payment.
3. Open the KomerceOS liveness page (look right, look left, smile). On Android, the app owns the Figma-style header, progress, guidance, camera frame and footer; the local SDK supplies the embedded camera, face detection and capture result. Every attempt starts from the tutorial; its selfie is not copied or cached by KomerceOS. iOS currently retains the SDK capture screen.
4. Show the full-screen liveness result with `Batal` and `Selanjutnya`. `Batal` opens the cancellation sheet; `Selanjutnya` opens the KTP tutorial bottom sheet over the result. `Mulai Foto` opens the full-screen KTP camera.
5. After capturing the KTP, show the selfie + KTP tutorial bottom sheet, then the front camera. Each captured-photo state shows the photo, a green confirmation banner, `Ambil Ulang`, and `Selanjutnya`.
6. Once a KTP photo is captured, run on-device ML Kit OCR on that photo. After the selfie + KTP step, show the document processing bottom sheet while waiting for OCR, then prefill recognized values on the **Informasi Data Partner** form. Unrecognized or invalid values stay blank and every field remains editable.
7. Prepare a compressed JPEG upload copy when each capture step completes. Keep the original KTP crop for preview and OCR; the upload copies are bounded to 1 MiB each. At the final form, `Simpan sebagai Draft` uploads all three prepared files together; `Ajukan Verifikasi` checks NIK, uploads all three prepared files together, then submits the complete partner form. No image upload runs at an intermediate step. A complete server draft uses its existing image URLs and skips local compression/upload on submit.

## API integration status (9 November 2026)

- Settings reads `latest-history` before opening KYC. The observed dev response is HTTP 200 with `meta` and `data`, including `liveness_picture`, `ktp_picture`, `ktp_face_picture`, and `info_data_partner`. The 9 November dev draft response returned KTP and selfie URLs but `liveness_picture.status = draft` with an empty URL. That combination now opens directly on **Informasi Data Partner**. The form is prefilled from `info_data_partner` when that data exists. Submit reuses images already saved on the server and does not require temporary files from a previous app session. A history containing only liveness still resumes at the KTP step; a recorded KTP image can be reviewed or retaken.
- PM clarified that the upload API expects a complete image set and that the app must not save each step independently. The previous liveness-only and one-file-plus-empty-field calls were sent too early in the flow; their `400 file is empty` responses do not establish that the API rejects null for a valid final request. `null` cannot be represented as a nullable multipart file part by Dio; absent file parts are omitted. The app now requires all three file paths and sends one multipart request only from the final Draft or Submit action.
- JPEG upload copies are compressed below 1 MiB at their respective capture steps and read into validated bytes when constructing the multipart request; the original KTP crop remains available for OCR and preview until the flow closes. On 9 November, the final three-image upload returned HTTP 200 on the dev device and `latest-history` then reported `draft`.
- A temporary dev-only diagnostic on 5 November at 16:11 WIB sent the same available test JPEG in all three multipart parts (`image_liveness`, `image_ktp`, `image_ktp_with_face`) under the logged-in `testsuper5` account. Both diagnostic calls returned success through the repository. This proves the endpoint accepts a three-part request from the app, but does not prove which missing part causes the one-part 400, nor that the test images form a valid KYC submission. The diagnostic code was removed and the normal APK reinstalled. Treat `testsuper5` KYC draft/images as test data until the server state is checked or reset.
- The earlier test that sent one liveness file with two empty fields on 5 November at 16:41 WIB also returned HTTP 400, `file is empty`. Per the PM clarification, this was an incomplete request sent before the final step and is not a valid test of the complete upload contract.
- The backend's follow-up example uses the names `imagektp`, `imagektpwithface`, and `imageliveness` in chat, while the earlier contract listed camel-case `imageKtp`, `imageKtpWithFace`, and `imageLiveness`; the working three-file web/client probe used snake-case names. It is not yet established whether the chat names are literal wire keys or shorthand. Sending the literal text `null` rather than an empty form field is also a different request that has not yet been tested.
- On 5 November, the dev web KYC page was inspected in Chrome Incognito with the test account. `latest-history` returned HTTP 200 and an empty first-attempt history (`id` and `verif_ktp_id` zero; picture URLs/statuses empty). The page presented liveness, selfie with KTP, KTP photo, and data form. Its `Verification.vue` source map showed `FormData.append` with the three snake-case names and conditional file inclusion. The webcam flow was not completed, so no successful web upload response was captured.
- On 9 November, the saved draft resumed directly at the prefilled partner form. `check-nik` returned HTTP 200, final `POST /auth/api/v1/partner/ktp-verification` returned HTTP 200 with `meta.status = success`, and the next `latest-history` returned `status = requested`. A fresh profile fetch showed `verification_ktp_status = 1` and the **Dalam Proses Verifikasi** badge. A `requested` history now opens the in-progress sheet instead of the KTP camera.

The KTP and selfie photos are held only for the active page session. Retaking a photo or closing the page removes the camera's temporary file. A one-time cleanup removes older liveness JPG caches and their `SharedPreferences` keys when this flow starts. No liveness photo is copied or saved by the app.

The KTP camera guides use the physical KTP-el blank ratio **85.60:53.98** (about **1.586:1**) for both the standalone KTP and the smaller KTP outline in the selfie camera. Source: [Permendagri 72/2022](https://peraturan.bpk.go.id/Details/247759/permendagri-no-72-tahun-2022). The selfie camera and liveness camera build their dashed face outlines from the same path helper.

## Backend work still needed

- Confirm how the backend stores the partner form fields for `Simpan sebagai Draft`. The current action uploads images only; it does not persist text entered in the form.
- Retaking a photo from a server draft still needs an agreed upload contract for reusing the other server images; a partial history with only server liveness likewise cannot satisfy the full three-local-file upload requirement.

The success sheet is shown only after the submit API returns success.

KTP OCR uses `google_mlkit_text_recognition` 0.13.1 (Latin script) on Android and iOS. This version is compatible with the existing iOS liveness and Firebase dependencies, so the iOS deployment target remains 15.0. The parser only accepts a 16-digit NIK and valid calendar dates; absent KTP fields such as postal code remain blank. The OCR image and text are not logged or uploaded by this step.

The KTP camera uses a higher capture resolution for OCR. Immediately after capture, it maps the visible guide rectangle through the centered `BoxFit.cover` transform to the rotated photo and crops that area with a small edge margin. The full camera photo is deleted; the KTP-only crop is shown in the photo review and passed directly to ML Kit OCR. The crop is deleted when retaken or when the page closes. This keeps text on the surrounding desk or keyboard out of the form across different image sizes. The parser accepts only plausible uppercase KTP values; uncertain values stay blank. Users should review every populated field and retake a dark or distant photo when key fields are missing.

## Component audit

- The new KYC page uses shared `DsAppBar`, `DsButton`, `DsAppImage`,
  `DsTextField`, `DsFormCard`, `DsFormRow`, and `DsPickerField`.
- The liveness result uses a full-screen page; KTP and selfie guides retain their
  existing KYC widgets because their illustrated layouts are specific to the
  Figma flow. The submit result uses `KycSuccessBottomSheet` only after a successful API response.
- The form card, row, and picker styling previously lived only under Setting.
  Their shared implementations now live in the design system, with Setting
  wrappers retaining its existing widget names.
- Android integration testing verified that the KTP guide sheet's `Mulai Foto` button is reachable and opens the full-screen KTP camera. A separate device test confirmed that `CameraPreview` becomes active after camera permission is available. The device screenshot exposed a guide sheet that was too tall compared with Figma; its height is now 78% of the viewport, while the longer selfie + KTP guide remains 90% with scrolling content and a pinned button. The camera flow now requests Android camera permission before initializing the preview. Widget tests cover the liveness result, first KTP screen, and the sheet's button position at 360 × 800 logical pixels. Full visual comparison of every state remains pending.

## Main Flow frame audit

| Visible frame | Figma type | Current implementation | Status |
| --- | --- | --- | --- |
| Verifikasi Identitas Kamu | Bottom sheet | `KycIdentityBottomSheet` | Matches type; opened after paid verification. |
| Verifikasi Wajah Liveness | Bottom sheet | `KycLivenessBottomSheet` | Matches type; starts the SDK. |
| Izin kamera | Dialog over liveness screen | `KycCameraPermissionDialog` | Present before SDK capture when permission is missing. |
| Pemeriksaan liveness | Full screen | `KycLivenessCapturePage` with embedded SDK camera (Android) | Camera height follows available space and card width; the app draws a tapered face guide and four orange curved corners. After each detected movement, an orange circular check appears at the upper-right of the camera, matching the Figma success state. |
| Verifikasi Wajah Berhasil | Full screen | `KycLivenessResultPage` | Shown before the KTP guide, with `Batal` and `Selanjutnya`. |
| Verifikasi Foto KTP | Bottom sheet over liveness result | `KycKtpGuideBottomSheet` over `KycLivenessResultPage` | Opened only after `Selanjutnya`. |
| Ambil Foto KTP | Full-screen camera, then captured-photo state | `KycSubmissionPage` with live `KycPhotoCaptureSection` | Camera, frame, banner and actions present; device visual QA pending. |
| Verifikasi Foto Selfie & KTP | Bottom sheet over captured KTP | `KycSelfieKtpGuideBottomSheet` | Matches route type. |
| Ambil Foto Selfie & KTP | Full-screen front camera, then captured-photo state | `KycSubmissionPage` with dashed face and KTP guides | Structure matches; device visual QA pending. |
| Memverifikasi Dokumen | Processing bottom sheet over partner form | `KycVerifyingDocumentBottomSheet` | Waits for on-device KTP OCR. |
| Informasi Data Partner | Full-screen form | `KycSubmissionPage` | Shared form components and Figma labels; recognized OCR fields are editable. |
| Pengajuan berhasil / simpan draft | Bottom sheets over partner form | `KycSuccessBottomSheet` | Submission success requires an API success response; draft success follows the image upload response. Saving partner form text as a draft is not covered by the known API contract. |

The Figma board also contains OCR failure, rejected liveness/KTP/selfie, retry and verification-status branches. These need API/status contracts before their transitions can be completed. Their existing KYC bottom sheet widgets are retained; the Main Flow above is the current UI scope.
