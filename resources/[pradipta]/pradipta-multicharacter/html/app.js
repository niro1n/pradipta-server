if (typeof axios === "undefined") {
    window.axios = {
        post: (url, data) => fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(data || {})
        }).then(r => r.json().catch(() => ({})))
    };
}

if (!window.pendingEvents) {
    window.pendingEvents = [];
}

window.addEventListener("message", (event) => {
    if (window.vueMessageHandler) {
        window.vueMessageHandler(event);
    } else {
        window.pendingEvents.push(event);
    }
});

function initMulticharacter() {
    if (window.__multicharacter_loaded) return;
    window.__multicharacter_loaded = true;

    const viewmodel = new Vue({
        el: "#app",
        data: {
            characters: [],
            chardata: {},
            show: {
                loading: false,
                characters: false,
                register: false,
                delete: false,
            },
            registerData: {
                date: "2000-01-01",
                firstname: "",
                lastname: "",
                nationality: undefined,
                gender: "Male",
            },
            allowDelete: false,
            characterAmount: 0,
            loadingText: "",
            selectedCharacter: -1,
            translations: {},
            customNationality: false,
            nationalities: [],
        },
        methods: {
            click_character: function (idx, type) {
                this.selectedCharacter = idx;
                if (this.characters[idx] !== undefined) {
                    axios.post("https://pradipta-multicharacter/cDataPed", {
                        cData: this.characters[idx],
                    });
                } else {
                    axios.post("https://pradipta-multicharacter/cDataPed", {});
                    if (type === "empty") {
                        this.resetRegisterData();
                    }
                }
            },
            prepareDelete: function () {
                this.show.characters = false;
                this.show.delete = true;
            },
            cancelDelete: function () {
                this.show.delete = false;
                this.show.characters = true;
            },
            cancelCreate: function () {
                this.show.register = false;
                this.show.characters = true;
            },
            delete_character: function () {
                if (this.show.delete && this.selectedCharacter !== -1 && this.characters[this.selectedCharacter]) {
                    this.show.delete = false;
                    axios.post("https://pradipta-multicharacter/removeCharacter", {
                        citizenid: this.characters[this.selectedCharacter].citizenid,
                    });
                    setTimeout(() => {
                        this.show.characters = true;
                    }, 500);
                }
            },
            play_character: function () {
                if (this.selectedCharacter !== -1) {
                    const data = this.characters[this.selectedCharacter];
                    if (data !== undefined) {
                        axios.post("https://pradipta-multicharacter/selectCharacter", {
                            cData: data,
                        });
                        setTimeout(() => {
                            this.show.characters = false;
                        }, 500);
                    } else {
                        this.resetRegisterData();
                    }
                }
            },
            resetRegisterData: function () {
                this.show.characters = false;
                this.show.register = true;
                this.registerData = {
                    date: "2000-01-01",
                    firstname: "",
                    lastname: "",
                    nationality: this.nationalities && this.nationalities.length > 0 ? this.nationalities[0] : undefined,
                    gender: "Male",
                };
            },
            create_character: function () {
                const registerData = this.registerData;
                let validationResult = { isValid: true };
                if (typeof characterValidator !== "undefined" && characterValidator.validateCharacter) {
                    validationResult = characterValidator.validateCharacter({
                        firstname: registerData.firstname,
                        lastname: registerData.lastname,
                        nationality: registerData.nationality,
                        gender: registerData.gender,
                        date: registerData.date,
                    });
                }

                if (validationResult.isValid) {
                    this.show.register = false;
                    const genderLabel = registerData.gender === "Female" ? (this.translate("female") || "Perempuan") : (this.translate("male") || "Laki-laki");

                    axios.post("https://pradipta-multicharacter/createNewCharacter", {
                        firstname: registerData.firstname,
                        lastname: registerData.lastname,
                        nationality: registerData.nationality,
                        birthdate: registerData.date,
                        gender: genderLabel,
                        cid: this.selectedCharacter,
                    });

                    setTimeout(() => {
                        this.show.characters = false;
                    }, 500);
                } else {
                    if (typeof Swal !== "undefined") {
                        Swal.fire({
                            icon: "error",
                            title: this.translate("ran_into_issue") || "Terjadi kendala",
                            text: this.translate(validationResult.message, { field: this.translate(validationResult.field) }) || "Periksa kembali data yang dimasukkan.",
                            timer: 5000,
                            timerProgressBar: true,
                            showConfirmButton: false,
                        });
                    }
                }
            },
            translate(key, params) {
                if (typeof translationManager !== "undefined") {
                    if (params) {
                        return translationManager.formatTranslation(key, params);
                    }
                    return translationManager.translate(key);
                }
                return key;
            },
        },
        mounted() {
            if (typeof initializeValidator === "function") {
                initializeValidator();
            }

            window.vueMessageHandler = (event) => {
                const data = event.data;
                if (!data) return;

                switch (data.action) {
                    case "ui":
                        if (!data.toggle) {
                            this.show.characters = false;
                            this.show.register = false;
                            this.show.delete = false;
                            this.show.loading = false;
                            break;
                        }
                        this.customNationality = data.customNationality;
                        if (typeof translationManager !== "undefined") {
                            translationManager.setTranslations(data.translations);
                        }
                        this.translations = data.translations || {};
                        this.nationalities = data.countries || [];
                        this.characterAmount = data.nChar || 1;
                        this.selectedCharacter = -1;
                        this.show.register = false;
                        this.show.delete = false;
                        this.allowDelete = data.enableDeleteButton;
                        this.show.loading = true;
                        this.loadingText = this.translate("retrieving_characters") || "Memuat karakter...";

                        // Signal client Lua that UI received the open instruction
                        fetch("https://pradipta-multicharacter/uiLoaded", {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify({})
                        }).catch(() => {});

                        axios.post("https://pradipta-multicharacter/setupCharacters");

                        // Safety timer: if setupCharacters lags or drops, retry automatically
                        setTimeout(() => {
                            if (this.show.loading) {
                                axios.post("https://pradipta-multicharacter/setupCharacters");
                            }
                        }, 2500);
                        break;

                    case "setupCharacters":
                        const newChars = [];
                        if (data.characters && data.characters.length) {
                            for (let i = 0; i < data.characters.length; i++) {
                                newChars[data.characters[i].cid] = data.characters[i];
                            }
                        }
                        this.characters = newChars;
                        this.show.loading = false;
                        this.show.characters = true;
                        axios.post("https://pradipta-multicharacter/removeBlur");

                        let autoSelected = 1;
                        for (let i = 1; i <= this.characterAmount; i++) {
                            if (newChars[i]) {
                                autoSelected = i;
                                break;
                            }
                        }
                        this.click_character(autoSelected, newChars[autoSelected] ? "existing" : "empty");
                        break;

                    case "setupCharInfo":
                        this.chardata = data.chardata || {};
                        break;
                }
            };

            // Process any buffered messages that arrived during page load
            while (window.pendingEvents && window.pendingEvents.length > 0) {
                window.vueMessageHandler(window.pendingEvents.shift());
            }

            // Signal client Lua that NUI DOM and event listeners are fully ready
            fetch("https://pradipta-multicharacter/nuiReady", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({})
            }).catch(() => {});
        },
    });
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initMulticharacter);
} else {
    initMulticharacter();
}
