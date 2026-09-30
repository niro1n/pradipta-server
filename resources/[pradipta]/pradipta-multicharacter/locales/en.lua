local Translations = {
    notifications = {
        ["char_deleted"] = "Karakter berhasil dihapus!",
        ["deleted_other_char"] = "Berhasil menghapus karakter dengan ID %{citizenid}.",
        ["forgot_citizenid"] = "ID Citizen belum diisi!",
    },

    commands = {
        ["deletechar_description"] = "Hapus karakter pemain lain",
        ["citizenid"] = "ID Citizen",
        ["citizenid_help"] = "ID Citizen dari karakter yang ingin dihapus",
        ["logout_description"] = "Keluar dari karakter",
        ["closeNUI_description"] = "Tutup menu"
    },

    misc = {
        ["droppedplayer"] = "Terputus dari server"
    },

    ui = {
        characters_header = "Karakter Saya",
        emptyslot = "Slot Kosong",
        play_button = "Masuk Kota",
        create_button = "Buat Karakter",
        delete_button = "Hapus Karakter",
        charinfo_header = "Profil Aktif",
        charinfo_description = "Pilih slot untuk melihat data karakter.",
        name = "Nama",
        male = "Laki-laki",
        female = "Perempuan",
        firstname = "Nama Depan",
        lastname = "Nama Belakang",
        nationality = "Kewarganegaraan",
        gender = "Jenis Kelamin",
        birthdate = "Tanggal Lahir",
        job = "Pekerjaan",
        jobgrade = "Pangkat",
        cash = "Uang Tunai",
        bank = "Bank",
        phonenumber = "Nomor HP",
        accountnumber = "Nomor Rekening",
        chardel_header = "Pendaftaran Karakter",
        deletechar_header = "Hapus Karakter?",
        deletechar_description = "Karakter ini akan dihapus secara permanen.",
        cancel = "Batal",
        confirm = "Mulai di sini",
        retrieving_playerdata = "Memuat data...",
        validating_playerdata = "Memeriksa data...",
        retrieving_characters = "Memuat karakter...",
        validating_characters = "Memeriksa karakter...",
        ran_into_issue = "Terjadi kendala",
        profanity = "Nama atau data mengandung kata yang tidak diperbolehkan.",
        forgotten_field = "Pastikan semua data sudah terisi dengan benar."
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
