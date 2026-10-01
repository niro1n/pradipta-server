# Pradipta HUD

Modern, modular, and high-performance HUD for **PRADIPTA SERVER**, customized and rebranded by **NIRO1N**.

## Features

- **Modern Minimalist UI**: Sleek status indicators (Health, Armor, Hunger, Thirst, Stress, Stamina, Oxygen, Nitro).
- **Vehicle HUD**: Dynamic speedometer with RPM, speed unit toggle, gear indicator, fuel gauge, engine health, and seatbelt status.
- **Cinematic Mode**: Smooth widescreen cinematic black bars (`/cinematic`).
- **In-Game Settings**: Open customization menu via `/hudsettings` or `I` key to configure positions, styles, scales, and colors.
- **Color Palette**: Fully styled with Pradipta signature Red theme palette (`#f44336` / `#d32f2f` / `#ff8a65` on dark surface `#1c1b1f`).
- **Framework Compatibility**: Seamlessly integrated with `pradipta-core` (and backwards-compatible with `qb-core`).

## Installation

Ensure resource in `server.cfg`:
```cfg
ensure pradipta-hud
```

## Commands & Keys

- `/hudsettings` (Default key: `I`) - Open HUD configuration & position editor.
- `/carcontrol` (Default key: `M`) - Vehicle control menu (doors, windows, engine).
- `/cinematic` - Toggle cinematic black bars.
- `B` - Toggle seatbelt.
- `L` - Toggle vehicle engine.
- `X` - Cancel active progress bar (`/pradiptahud:cancelProgress`).

## Developer

- **Developer**: NIRO1N
- **Project**: PRADIPTA SERVER
