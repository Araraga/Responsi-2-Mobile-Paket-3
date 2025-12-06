# Responsi 2 Mobile Paket 3 (NIM Anda)

**Identitas Mahasiswa**

- **Nama:** Arga Aryanta Indrafata
- **NIM:** H1D023096
- **Shift Baru:** C
- **Shift Asal:** E

---

## Video Demo Aplikasi

Berikut adalah demonstrasi fitur aplikasi mulai dari Registrasi, Login, hingga operasi CRUD (Create, Read, Update, Delete) pada inventaris buku.

<div align="center">
  <img src="assets/demo_aplikasi.gif" alt="Video Demo Aplikasi" width="600"/>
</div>

---

## Tech Stack & State Management

### Teknologi yang Digunakan

- **Frontend:** Flutter (Dart SDK)
- **Backend:** Node.js (Runtime) dengan Express.js (Framework)
- **Database:** MySQL (Relational Database Management System)
- **HTTP Client:** Package `http` untuk komunikasi API
- **State Management:** `flutter_bloc` (Business Logic Component)

### State Management

Aplikasi ini menerapkan arsitektur BLoC untuk memisahkan antara UI dan Business Logic Layer.

1.  **Event-Driven:** UI tidak mengubah state secara langsung, melainkan mengirimkan _Event_ (contoh: `LoginEvent`).
2.  **State Output:** BLoC memproses event tersebut, melakukan komunikasi data, dan menghasilkan _State_ baru (contoh: `LoginSuccess` atau `LoginFailure`).
3.  **Traceability:** Memudahkan debugging karena setiap perubahan state dipicu oleh event yang jelas.

---

## Spesifikasi API (Backend Node.js)

Backend dibangun menggunakan Node.js yang berjalan pada port `3000`. Server ini bertugas menangani permintaan HTTP dari aplikasi Flutter dan meneruskannya ke database MySQL.

### 1. Konfigurasi Server & Database

- **Koneksi MySQL:** Menggunakan library `mysql2` untuk membuat koneksi _pool_ ke database `db_buku_nim`.
- **CORS:** Middleware `cors` diaktifkan agar API dapat diakses dari IP yang berbeda (penting untuk Emulator/Device fisik).
- **Body Parser:** Mengurai _request body_ bertipe JSON agar bisa dibaca oleh backend.

### 2. Endpoint Autentikasi

| Method | Endpoint    | Deskripsi Fungsi                                                                                                                 |
| :----- | :---------- | :------------------------------------------------------------------------------------------------------------------------------- |
| `POST` | `/register` | Menerima `username` & `password`. Password disimpan langsung (untuk tujuan pembelajaran) atau di-hash (jika menggunakan bcrypt). |
| `POST` | `/login`    | Mencocokkan input user dengan data di tabel `users`. Mengembalikan JSON `{success: true}` jika valid.                            |

### 3. Endpoint Inventaris Buku

| Method | Endpoint  | Deskripsi Fungsi                                                                                              |
| :----- | :-------- | :------------------------------------------------------------------------------------------------------------ |
| `GET`  | `/read`   | Mengambil seluruh baris data dari tabel `buku` dan mengembalikannya dalam format JSON Array `[{...}, {...}]`. |
| `POST` | `/create` | Menerima payload JSON berisi atribut buku dan menyimpannya ke database menggunakan perintah `INSERT INTO`.    |
| `POST` | `/update` | Memperbarui data buku berdasarkan `id` yang dikirimkan menggunakan perintah `UPDATE ... WHERE id = ?`.        |
| `POST` | `/delete` | Menghapus satu baris data buku berdasarkan `id` yang diterima.                                                |

---

## Penjelasan Detail Kode Frontend (Flutter)

Aplikasi ini dibagi menjadi tiga layer utama sesuai prinsip _Clean Architecture_ sederhana:

### 1. Layer Data (`repositories/`)

Layer ini berfungsi sebagai gerbang komunikasi ke dunia luar (API).

- **`auth_repository.dart`**:
  - Fungsi `login()`: Mengirim `POST` request. Jika status code 200 dan body merespons sukses, fungsi mengembalikan `true`. Jika gagal, melempar `Exception` yang akan ditangkap oleh BLoC.
- **`buku_repository.dart`**:
  - Fungsi `getBuku()`: Melakukan `GET` request ke endpoint `/read`. Respons JSON didecode menjadi `List<dynamic>` yang siap dikonsumsi oleh UI.
  - Fungsi `saveBuku()`: Cerdas mendeteksi apakah operasi ini adalah **Simpan Baru** atau **Edit** berdasarkan parameter `isEdit`. Jika edit, ia memanggil `/update`, jika baru memanggil `/create`.

### 2. Layer Logic (`blocs/`)

Layer ini adalah "otak" aplikasi yang menghubungkan Repository dengan UI.

- **`AuthBloc`**:
  - Mengelola state autentikasi: `AuthInitial` -> `AuthLoading` -> `AuthSuccess` / `AuthFailure`.
  - Saat `LoginEvent` masuk, BLoC mengubah state jadi Loading, memanggil repo, lalu memancarkan Success jika berhasil. Ini memicu navigasi halaman di UI.
- **`BukuBloc`**:
  - Mengelola state data buku.
  - **CRUD Logic:** Setelah operasi `AddBukuEvent` atau `DeleteBukuEvent` berhasil, BLoC secara otomatis memicu event `LoadBukuEvent` lagi. Ini memastikan daftar buku di layar pengguna selalu _up-to-date_ tanpa perlu refresh manual.

### 3. Layer Presentation (`screens/` & `widgets/`)

Layer ini berisi kode tampilan yang bereaksi terhadap perubahan State.

#### A. Konfigurasi Global (`main.dart`)

- **MultiBlocProvider:** Membungkus `MaterialApp` agar instance `AuthBloc` dan `BukuBloc` dibuat sekali di awal dan dapat diakses (di-_inject_) ke seluruh halaman di bawahnya menggunakan `context.read<T>()`.
- **ThemeData:** Menetapkan `primarySwatch` ke `Colors.brown` dan font `Roboto` untuk konsistensi visual di seluruh aplikasi.

#### B. Halaman Utama (`home_page.dart`)

- **BlocBuilder:** Widget ini mendengarkan `BukuBloc`.
  - Jika state `BukuLoading`: Tampilkan `CircularProgressIndicator`.
  - Jika state `BukuLoaded`: Tampilkan `ListView`.
  - Jika state `BukuError`: Tampilkan pesan error.
- **Client-Side Filtering & Sorting:**
  - Fitur pencarian (`_searchCtrl`) dan pengurutan (`_sortBy`) dilakukan di sisi aplikasi (bukan di query database) menggunakan fungsi `_processList()`. Ini memungkinkan interaksi yang sangat cepat (_snappy_) karena data sudah dimuat di memori.

#### C. Halaman Form (`form_page.dart`)

- **Reusability Logic:** Halaman ini digunakan untuk dua tujuan sekaligus.
  - **Mode Tambah:** Jika parameter `widget.data` bernilai `null`, form ditampilkan kosong.
  - **Mode Edit:** Jika `widget.data` berisi objek buku, `TextEditingController` akan diisi secara otomatis (_pre-filled_) dengan data tersebut pada method `initState`.
- **Date Picker:** Menggunakan `showDatePicker` bawaan Flutter untuk memastikan format tanggal yang dikirim ke server valid dan seragam (`YYYY-MM-DD`).

#### D. Komponen Widget (`widgets/`)

- **`book_card.dart`:** Memecah tampilan item buku menjadi widget terpisah agar kode `HomePage` lebih bersih. Menggunakan `InkWell` untuk mendeteksi ketukan (navigasi ke Edit).
- **`dialog_popup.dart`:** Sebuah _utility class_ statis untuk menampilkan _Alert Dialog_. Digunakan untuk konfirmasi Logout dan Hapus Data, memastikan kode UI utama tidak "kotor" dengan logika _showDialog_ yang berulang.

---

## Screenshot Aplikasi

<p align="center">
  <img src="assets/screenshots/login.png" alt="Login" width="150"/>
  &nbsp;
  <img src="assets/screenshots/register.png" alt="Register" width="150"/>
  &nbsp;
  <img src="assets/screenshots/home_list.png" alt="Home" width="150"/>
  &nbsp;
  <img src="assets/screenshots/search_sort.png" alt="Search" width="150"/>
  &nbsp;
  <img src="assets/screenshots/form_add.png" alt="Form" width="150"/>
  &nbsp;
  <img src="assets/screenshots/dialog_delete.png" alt="Dialog" width="150"/>
</p>
