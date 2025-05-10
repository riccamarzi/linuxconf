# Setup Script: Zsh, Tmux, Docker & Tools

A simple bash script to quickly install **Oh My Zsh**, **Oh My Tmux**, **Docker**, and useful system tools on a new machine (Ubuntu/Debian or Fedora).

## Features

- Installs **Oh My Zsh** (with Zsh)
- Installs **Oh My Tmux** (with Tmux)
- Installs **Docker** (with Docker Compose and Buildx)
- Installs useful tools: **btop**, **net-tools**, **ncdu**
- Supports both **APT** (Ubuntu/Debian) and **DNF** (Fedora)
- Colorful and easy-to-read interface

## Quick install

Clone the repo from GitHub and execute all:

```bash
git clone https://github.com/riccamarzi/linuxconf.git
cd linuxconf
./setup.sh

```

## Usage

| Option     | Description                      |
|------------|----------------------------------|
| `--all`    | Install everything              |
| `--zsh`    | Install only Oh My Zsh          |
| `--tmux`   | Install only Oh My Tmux         |
| `--docker` | Install only Docker             |
| `--tools`  | Install only btop, net-tools, dust, git, ccat |

### Examples

Install everything:

```bash
./setup.sh --all
```

Install only Docker and tools:

```bash
./setup.sh --docker --tools
```

## After installation

- **Docker**: You might need to log out and log back in to use Docker without `sudo`
- **Oh My Tmux**: A `.tmux.conf.local` file is copied to your home directory
- **Oh My Zsh**: The default shell is set to `zsh` along with some Oh My ZSH plugins  

## Compatibility

- Ubuntu 20.04+ / Debian 11+
- Fedora 37+

## License

MIT License
