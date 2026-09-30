# PRADIPTA - fuel

Fuel and fuelstations system for Fivem :fuelpump:

## Dependencies

-   [pradipta-core](https://github.com/pradiptacore-framework/pradipta-core) (Required)
-   [pradipta-target](https://github.com/BerkieBb/pradipta-target) (Required)
-   [PolyZone](https://github.com/mkafrin/PolyZone) (Required)

## Exports 📡

|  Name   | Namespace |    Arguments    | Return |
| :-----: | :-------: | :-------------: | :----: |
| GetFuel |  Client   |     vehicle     | number |
| SetFuel |  Client   | vehicle, number |  void  |

_\* The exports can be use with the resource name (pradipta-fuel) or with LegacyFuel_

## Compatibility

This resource is fully compatible with PradiptaCore servers and it sustitutes the _[LegacyFuel](https://github.com/InZidiuZ/LegacyFuel)_, thanks to InZidiuZ for that amazing script that inspired us to make a new Fuel System script.

```lua
-- Will return the same
exports['pradipta-fuel']:GetFuel(vehicle)
exports['LegacyFuel']:GetFuel(vehicle)
```

This will make it easier to change from _LegacyFuel_ to _pradipta-fuel_.
