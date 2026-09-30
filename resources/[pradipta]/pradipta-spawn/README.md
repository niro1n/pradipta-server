# PRADIPTA - spawn
Spawn Selector for PRADIPTA SERVER FRAMEWORK (PRADIPTA SERVER) :eagle:

# License

    PRADIPTA SERVER FRAMEWORK (PradiptaCore)
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>


## Dependencies
- [pradipta-core](https://github.com/pradiptacore-framework/pradipta-core)
- [pradipta-houses](https://github.com/pradiptacore-framework/pradipta-houses) - Lets player select the house
- [pradipta-apartment](https://github.com/pradiptacore-framework/pradipta-apartment) - Lets player select the apartment
- [pradipta-garages](https://github.com/pradiptacore-framework/pradipta-garages) - For house garages

## Screenshots
![Spawn selector](https://i.imgur.com/nz0mPGe.png)

## Features
- Ability to select spawn after selecting the character

## Installation
### Manual
- Download the script and put it in the `[pradipta]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure pradipta-core
ensure pradipta-spawn
ensure pradipta-apartments
ensure pradipta-garages
```

## Configuration
An example to add spawn option
```
PRADIPTA.Spawns = {
    ["spawn1"] = { -- Needs to be unique
        coords = vector4(1.1, -1.1, 1.1, 180.0), -- Coords player will be spawned
        location = "spawn1", -- Needs to be unique
        label = "Spawn 1 Name", -- This is the label which will show up in selection menu.
    },
    ["spawn2"] = { -- Needs to be unique
        coords = vector4(1.1, -1.1, 1.1, 180.0), -- Coords player will be spawned
        location = "spawn2", -- Needs to be unique
        label = "Spawn 2 Name", -- This is the label which will show up in selection menu.
    },
}
```
