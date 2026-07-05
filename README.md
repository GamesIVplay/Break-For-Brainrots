# Don't Break This Block

Roblox/Luau game built with Rojo, Wally, Rokit, Blink, Selene, and StyLua.

**Play:** https://www.roblox.com/games/75406379949350/Don-t-Break-This-Block

## Setup

```sh
sh scripts/setup.sh
```

## Common Commands

```sh
sh scripts/generate-network.sh
sh scripts/install-packages.sh
sh scripts/sourcemap.sh
sh scripts/serve.sh
sh scripts/check.sh
```

Legacy wrappers still work:

```sh
sh scripts/blink.sh
sh scripts/installPackages.sh
sh scripts/nvim-dev.sh
```

## Workflow

- Edit Blink files in `.config/blink/`, then run `sh scripts/generate-network.sh`.
- `network/`, `Packages/`, and `sourcemap.json` are generated.
- Run `sh scripts/check.sh` before pushing.

Entire game scripted by **Dale**.

https://daledevs.com
