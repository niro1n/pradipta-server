class TranslationManager {
    constructor() {
        this.translations = {};
        this.fallbacks = {
            deletechar_description: "Karakter ini akan dihapus secara permanen.",
            confirm: "Konfirmasi",
            cancel: "Batal",
            chardel_header: "Pendaftaran Karakter",
            firstname: "Nama Depan",
            lastname: "Nama Belakang",
            nationality: "Kewarganegaraan",
            birthdate: "Tanggal Lahir",
            gender: "Jenis Kelamin",
            male: "Laki-laki",
            female: "Perempuan",
            create_button: "Buat Karakter",
            retrieving_playerdata: "Memuat data...",
            validating_playerdata: "Memeriksa data...",
            retrieving_characters: "Memuat karakter...",
            validating_characters: "Memeriksa karakter...",
            ran_into_issue: "Terjadi kendala",
            profanity: "Data yang dimasukkan mengandung kata yang tidak diperbolehkan.",
            forgotten_field: "Pastikan semua data sudah terisi dengan benar.",
            connection_error: "Koneksi bermasalah. Silakan coba lagi.",
            delete_failed: "Gagal menghapus karakter. Silakan coba lagi.",
            selection_failed: "Gagal memilih karakter. Silakan coba lagi.",
            creation_failed: "Gagal membuat karakter. Silakan coba lagi.",
            setup_failed: "Gagal memuat karakter. Silakan coba lagi.",
            firstname_too_short: "Nama depan minimal 2 karakter.",
            firstname_too_long: "Nama depan maksimal 16 karakter.",
            lastname_too_short: "Nama belakang minimal 2 karakter.",
            lastname_too_long: "Nama belakang maksimal 16 karakter.",
            invalid_date: "Masukkan tanggal lahir yang valid.",
            date: "Tanggal Lahir",
            field: "Kolom",
        };
    }

    setTranslations(translations) {
        this.translations = translations || {};
    }

    translate(key) {
        if (this.translations && this.translations[key]) {
            return this.translations[key];
        }
        if (this.fallbacks && this.fallbacks[key]) {
            return this.fallbacks[key];
        }
        return key;
    }

    formatTranslation(key, params) {
        let text = this.translate(key);
        if (params) {
            Object.keys(params).forEach((param) => {
                text = text.replace(`{${param}}`, params[param]);
            });
        }
        return text;
    }
}

const translationManager = new TranslationManager();
