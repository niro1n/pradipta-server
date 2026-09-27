local Translations = {
    ui = {
        last_location = "Lokasi terakhir",
        confirm = "Mulai di sini",
        where_would_you_like_to_start = "Pilih lokasi",
        no_locations = "Tidak ada lokasi",
        selected = "Dipilih",
        loading = "Memuat...",
        choose_location = "Pilih lokasi",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
