(function () {
    'use strict';

    const bgVideo = document.getElementById('bg-video');
    const soundToggle = document.getElementById('sound-toggle');
    const soundLabel = document.getElementById('sound-label');
    const statusText = document.getElementById('status-text');
    const progressFill = document.getElementById('progress-bar-fill');
    const progressPercent = document.getElementById('progress-percent');
    const progressDetail = document.getElementById('progress-detail');

    let isMuted = false;
    let totalInitCount = 0;
    let totalDataFiles = 0;
    let currentFraction = 0;
    let hasFiveMEvents = false;

    if (bgVideo) {
        bgVideo.muted = false;
        bgVideo.volume = 0.40;
        
        const playPromise = bgVideo.play();
        if (playPromise !== undefined) {
            playPromise.catch(() => {
                bgVideo.muted = true;
                isMuted = true;
                if (soundToggle) {
                    soundToggle.classList.remove('is-active');
                    soundLabel.textContent = 'AUDIO MUTED [M]';
                }
                bgVideo.play().catch(() => {});
            });
        }
    }

    function toggleAudio() {
        if (!bgVideo) return;

        isMuted = !isMuted;
        bgVideo.muted = isMuted;

        if (!isMuted) {
            bgVideo.volume = 0.40;
            bgVideo.play().catch(() => {});
            soundToggle.classList.add('is-active');
            soundLabel.textContent = 'AUDIO ACTIVE [M]';
        } else {
            soundToggle.classList.remove('is-active');
            soundLabel.textContent = 'AUDIO MUTED [M]';
        }
    }

    if (soundToggle) {
        soundToggle.addEventListener('click', toggleAudio);
    }

    window.addEventListener('keydown', function (e) {
        if (e.code === 'KeyM' || e.code === 'Space') {
            e.preventDefault();
            toggleAudio();
        }
    });

    function updateProgress(fraction, title, detail) {
        fraction = Math.max(0, Math.min(1, fraction));
        if (fraction > currentFraction) {
            currentFraction = fraction;
        }

        const percentage = Math.round(currentFraction * 100);

        if (progressFill) {
            progressFill.style.width = percentage + '%';
        }
        if (progressPercent) {
            progressPercent.textContent = percentage + '%';
        }
        if (title && statusText && statusText.textContent !== title) {
            statusText.textContent = title;
        }
        if (detail && progressDetail) {
            progressDetail.textContent = detail;
        }
    }

    const handlers = {
        startInitFunctionOrder(data) {
            hasFiveMEvents = true;
            totalInitCount = data.count || 1;
            updateProgress(currentFraction, 'INITIALIZING', 'STARTING SYSTEM PROCEDURES');
        },

        initFunctionInvoking(data) {
            hasFiveMEvents = true;
            const fraction = totalInitCount > 0 ? (data.idx / totalInitCount) * 0.45 : currentFraction;
            const typeStr = data.type ? 'INITIALIZING ' + data.type : 'INITIALIZING SYSTEM';
            const nameStr = data.name ? data.name : 'SYSTEM COMPONENT';
            updateProgress(fraction, typeStr, nameStr);
        },

        initFunctionInvoked(data) {
            hasFiveMEvents = true;
        },

        startDataFileEntries(data) {
            hasFiveMEvents = true;
            totalDataFiles = data.count || 1;
            updateProgress(0.50, 'LOADING ASSETS', 'PREPARING ASSET MANIFEST');
        },

        onDataFileEntry(data) {
            hasFiveMEvents = true;
            const assetName = data.name ? data.name.split('/').pop() : 'GAME DATA';
            updateProgress(currentFraction, 'LOADING ASSETS', assetName);
        },

        performMapLoadFunction(data) {
            hasFiveMEvents = true;
            const fraction = 0.75 + ((data.idx || 1) / 100) * 0.20;
            updateProgress(fraction, 'PREPARING WORLD', 'CONNECTING TO PRADIPTA');
        },

        loadProgress(data) {
            hasFiveMEvents = true;
            if (typeof data.loadFraction === 'number') {
                updateProgress(data.loadFraction, 'CONNECTING TO PRADIPTA', 'FINALIZING ENVIRONMENT');
            }
        },

        onLogLine(data) {
            hasFiveMEvents = true;
            if (data.message && data.message.trim().length > 0) {
                const cleanMsg = data.message.replace(/[\^][0-9]/g, '').trim();
                if (cleanMsg.length > 0 && !cleanMsg.startsWith('[')) {
                    progressDetail.textContent = cleanMsg.slice(0, 45).toUpperCase();
                }
            }
        }
    };

    window.addEventListener('message', function (event) {
        if (!event.data || !event.data.eventName) return;
        const handler = handlers[event.data.eventName];
        if (typeof handler === 'function') {
            handler(event.data);
        }
    });

    window.addEventListener('DOMContentLoaded', function () {
        setTimeout(function () {
            if (!hasFiveMEvents) {
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('demo') === '1') {
                    let demoP = 0;
                    const demoInterval = setInterval(function () {
                        demoP += 0.05;
                        if (demoP >= 1) {
                            demoP = 1;
                            clearInterval(demoInterval);
                            updateProgress(1, 'CONNECTED', 'PRADIPTA PRIVATE ENVIRONMENT READY');
                        } else {
                            updateProgress(demoP, 'LOADING RESOURCES', 'VERIFYING PACKAGE DATA');
                        }
                    }, 200);
                } else {
                    statusText.textContent = 'CONNECTING TO PRADIPTA';
                    progressDetail.textContent = 'AWAITING SERVER HANDSHAKE';
                }
            }
        }, 1200);
    });
})();
