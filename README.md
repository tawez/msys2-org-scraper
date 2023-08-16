# msys2-org-scraper

Script to download the most recent packages from https://repo.msys2.org/

But why?

I tried to install packages using `pacman`
and pacman was unable to download packages due to very restricted network configuration.
At the same time, I was able to download packages directly from https://repo.msys2.org/ and install them later manually using `pacman`.

## `scrap-msys2.sh`

`scrap-msys2.sh` script downloads packages for most of the environments in https://repo.msys2.org/mingw/


### Usage

```
scrap-msys2.sh <environment>
```

Where `environment` is one of:

- clang32
- clang64
- clangarm64
- mingw32
- mingw64
- ucrt64
