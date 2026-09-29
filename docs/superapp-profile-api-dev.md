# Profile bisnis: hasil tes API dev, 28 September 2026

Endpoint update: `PUT https://api.internal.komerce.my.id/dev/auth/api/v1/user/partner/profile-business`.
Endpoint baca: `GET https://api.internal.komerce.my.id/dev/auth/api/v1/user/partner/get-profile-mobile`.
Tes menggunakan akun pengguna dan file JPEG asset project `assets/images/komtim_icon.jpeg`. Token tidak dicatat di dokumen ini.

## Request yang diterima dan tersimpan

| Nilai di aplikasi | Field multipart yang diterima dev |
| --- | --- |
| Nama bisnis | `brand_name` |
| Nomor HP bisnis | `pic_phone` |
| Lokasi | `business_location` |
| Sektor | `partner_category_name` |
| File logo JPEG | `logo` |

Upload dengan `business_logo` sebagai file menghasilkan HTTP 400:

```json
{"status":"failed","code":400,"message":"unsupported field type for multipart.FileHeader","errors":"unsupported field type for multipart.FileHeader"}
```

Request curl multipart standar dengan alias file `logo` menghasilkan HTTP 200. Jadi kegagalan file field `business_logo` juga terjadi di luar Dio.

Field `no_hp_business` mendapat respons sukses, tetapi GET tetap mengembalikan `pic_phone: ""`. Setelah PUT memakai `pic_phone`, nomor tampil pada GET. Lokasi dan sektor tersimpan dengan `business_location` dan `partner_category_name`.

## Bentuk GET yang benar-benar diterima

```json
{
  "business_profile": {
    "business_logo": "/photo_profile_partner/dev/1790587689_95b30932_komtim_icon.jpeg",
    "brand_name": "Test Ya Hijab",
    "business_location": "Simeulue Timur, Kabupaten Simeulue, Aceh",
    "pic_phone": "08755766499494",
    "partner_category_name": "Bisnis Offline"
  }
}
```

Parser global mendukung bentuk ini serta nama field canonical dari Swagger. String logo kosong dianggap tidak ada logo. Form membaca hasil parser dari `SuperappProfileBloc`.

## Masalah storage yang masih perlu diperbaiki backend

Endpoint Komship `POST https://dev.komship.komerce.my.id/api/v1/my-profile` mengembalikan URL logo:

`https://dev.komtim.komerce.my.id/storage//photo_profile_partner/dev/1790587689_95b30932_komtim_icon.jpeg`

GET URL tersebut menghasilkan HTTP 404. Versi dengan slash yang dinormalisasi (`/storage/photo_profile_partner/...`) juga 404. Setelah bucket auth dev dikonfirmasi, path logo dari GET ternyata bisa diunduh dari `https://storage.googleapis.com/komerce-dev-auth/` + path relatif; file JPEG akun uji menghasilkan HTTP 200 `image/jpeg`. Flutter dev kini memakai bucket tersebut. URL absolut dari GET tidak diubah. Staging/production masih memakai origin sebelumnya karena bucket-nya belum diverifikasi.

Catatan: host legacy Komtim di atas bukan origin yang benar untuk logo dari auth dev. Jangan gunakan hasil HTTP 404 di host legacy sebagai bukti bahwa upload file gagal.

Form menampilkan file lokal hanya selama logo baru dipilih tetapi belum disimpan. Setelah PUT sukses, pilihan lokal dilepas; `SuperappProfileBloc` me-refresh GET profil dan preview memakai URL dari respons global. Bila file pada URL itu gagal dimuat, form menampilkan ikon gambar rusak agar kegagalan storage tidak tertutup oleh salinan lokal. HTTP 200 dari PUT dan path pada GET belum membuktikan file gambar dapat diunduh.
