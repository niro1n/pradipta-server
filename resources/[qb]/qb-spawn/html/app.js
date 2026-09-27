document.addEventListener("DOMContentLoaded", () => {
    const viewmodel = new Vue({
        el: "#app",
        data: {
            positions: {
                normal: {},
                appartment: {},
                house: [],
            },
            selectedValue: {
                type: "",
                name: "",
                label: "",
            },
            newChar: false,
            show: false,
            translations: {},
        },
        computed: {
            hasLocations() {
                return (
                    !this.newChar ||
                    (this.positions.normal && Object.keys(this.positions.normal).length > 0) ||
                    (this.positions.house && this.positions.house.length > 0) ||
                    (this.positions.appartment && Object.keys(this.positions.appartment).length > 0)
                );
            },
            selectedDisplayName() {
                if (this.selectedValue.label) {
                    return this.selectedValue.label;
                }
                if (this.selectedValue.type === "current") {
                    return this.translate("last_location") || "Lokasi terakhir";
                }
                return this.translate("choose_location") || "Pilih lokasi";
            },
        },
        methods: {
            click_location(type, name, label) {
                this.selectedValue = {
                    type: type,
                    name: name,
                    label: label || name,
                };
                fetch("https://qb-spawn/setCam", {
                    method: "POST",
                    headers: { "Content-Type": "application/json; charset=UTF-8" },
                    body: JSON.stringify({
                        posname: name,
                        type: type,
                    }),
                }).catch(() => {});
            },
            submit_spawn() {
                if (!this.selectedValue.type || !this.selectedValue.name) return;
                this.show = false;
                const data = this.selectedValue;
                if (data.type !== "appartment") {
                    fetch("https://qb-spawn/spawnplayer", {
                        method: "POST",
                        headers: { "Content-Type": "application/json; charset=UTF-8" },
                        body: JSON.stringify({
                            spawnloc: data.name,
                            typeLoc: data.type,
                        }),
                    }).catch(() => {});
                } else {
                    fetch("https://qb-spawn/chooseAppa", {
                        method: "POST",
                        headers: { "Content-Type": "application/json; charset=UTF-8" },
                        body: JSON.stringify({
                            appType: data.name,
                        }),
                    }).catch(() => {});
                }
            },
            translate(phrase) {
                return this.translations[phrase] || phrase;
            },
            autoSelectFirst() {
                if (!this.newChar) {
                    this.click_location("current", "current", this.translate("last_location") || "Lokasi terakhir");
                    return;
                }
                if (this.positions.appartment && Object.keys(this.positions.appartment).length > 0) {
                    const firstAppKey = Object.keys(this.positions.appartment)[0];
                    const appObj = this.positions.appartment[firstAppKey];
                    this.click_location("appartment", firstAppKey, appObj.label || firstAppKey);
                    return;
                }
                if (this.positions.normal && Object.keys(this.positions.normal).length > 0) {
                    const firstNormKey = Object.keys(this.positions.normal)[0];
                    const normObj = this.positions.normal[firstNormKey];
                    this.click_location("normal", firstNormKey, normObj.label || firstNormKey);
                }
            },
        },
        mounted() {
            window.addEventListener("message", (event) => {
                const data = event.data;
                if (!data) return;

                switch (data.action) {
                    case "showUi":
                        this.show = !!data.status;
                        if (data.translations) {
                            this.translations = data.translations;
                        }
                        if (this.show && (!this.selectedValue.type || !this.selectedValue.name)) {
                            this.$nextTick(() => {
                                this.autoSelectFirst();
                            });
                        }
                        break;

                    case "setupLocations":
                        this.positions = {
                            normal: data.locations || {},
                            appartment: {},
                            house: data.houses || [],
                        };
                        this.newChar = !!data.isNew;
                        this.$nextTick(() => {
                            this.autoSelectFirst();
                        });
                        break;

                    case "setupAppartements":
                        this.positions = {
                            normal: {},
                            appartment: data.locations || {},
                            house: [],
                        };
                        this.newChar = !!data.isNew;
                        this.$nextTick(() => {
                            this.autoSelectFirst();
                        });
                        break;
                }
            });
        },
    });
});
