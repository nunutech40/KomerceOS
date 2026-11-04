# KYC UI flow (branch `aris-sprint-kyc`)

Design reference: [Sprint 3 — Update 13.10.2026 KYC](https://www.figma.com/design/LkqSMbnuKrsmb34GSfECVO/Sprint-3?node-id=1558-31685).

## Current path

1. `verification_ktp_status = 0`: show paid verification offer; the existing payment API is called before KYC begins.
2. `verification_ktp_status = 5` (paid) or `3` (retry): open identity introduction without another payment.
3. Open the KomerceOS liveness page (look right, look left, smile). On Android, the app owns the Figma-style header, progress, guidance, camera frame and footer; the local SDK supplies the embedded camera, face detection and capture result. Every attempt starts from the tutorial; its selfie is not copied or cached by KomerceOS. iOS currently retains the SDK capture screen.
4. Show the full-screen liveness result with `Batal` and `Selanjutnya`. `Batal` opens the cancellation sheet; `Selanjutnya` opens the KTP tutorial bottom sheet over the result. `Mulai Foto` opens the full-screen KTP camera.
5. After capturing the KTP, show the selfie + KTP tutorial bottom sheet, then the front camera. Each captured-photo state shows the photo, a green confirmation banner, `Ambil Ulang`, and `Selanjutnya`.
6. Show the document processing bottom sheet, then the **Informasi Data Partner** form. The processing sheet is only a UI preview; it performs no OCR.
7. The form has a preview draft action and a preview completion popup. Neither saves data, sends data, or changes KYC status. Closing the result returns to the previous page so the flow can be restarted.

The KTP and selfie photos are held only for the active page session. Retaking a photo or closing the page removes the camera's temporary file. A one-time cleanup removes older liveness JPG caches and their `SharedPreferences` keys when this flow starts. No liveness photo is copied or saved by the app.

The KTP camera guides use the physical KTP-el blank ratio **85.60:53.98** (about **1.586:1**) for both the standalone KTP and the smaller KTP outline in the selfie camera. Source: [Permendagri 72/2022](https://peraturan.bpk.go.id/Details/247759/permendagri-no-72-tahun-2022). The selfie camera and liveness camera build their dashed face outlines from the same path helper.

## Backend integration still needed

- KTP upload/OCR and response model for pre-filling identity fields. The current form is blank and editable.
- Submit KTP, identity data, selfie-with-KTP and liveness evidence as one KYC application.
- Persist and restore a real draft. The current draft popup explicitly says nothing was saved to the server.
- Replace preview completion with a success state only after the submit API confirms it.
- Refresh `verification_ktp_status` from the profile API after submit.

The page intentionally does not simulate an OCR response or claim that the application was submitted.

## Component audit

- The new KYC page uses shared `DsAppBar`, `DsButton`, `DsAppImage`,
  `DsTextField`, `DsFormCard`, `DsFormRow`, and `DsPickerField`.
- The liveness result uses a full-screen page; KTP and selfie guides retain their
  existing KYC widgets because their illustrated layouts are specific to the
  Figma flow. The final preview uses the existing `KycSuccessBottomSheet` with
  copy stating that no submission occurred.
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
| Memverifikasi Dokumen | Processing bottom sheet over partner form | `KycVerifyingDocumentBottomSheet` | UI preview only; OCR endpoint unconnected. |
| Informasi Data Partner | Full-screen form | `KycSubmissionPage` | Shared form components and Figma labels used; OCR values unavailable. |
| Pengajuan berhasil / simpan draft | Bottom sheets over partner form | `KycSuccessBottomSheet` | Preview copy explicitly avoids claiming backend submission or persistence. |

The Figma board also contains OCR failure, rejected liveness/KTP/selfie, retry and verification-status branches. These need API/status contracts before their transitions can be completed. Their existing KYC bottom sheet widgets are retained; the Main Flow above is the current UI scope.
