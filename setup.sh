#!/bin/bash

REPO_ROOT_DIR=$(dirname "$(realpath "$0")")

# === Colori ===
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# === Funzione banner ===
banner() {
    echo -e "${CYAN}"
    echo "===================================="
    echo "         $1"
    echo "===================================="
    echo -e "${RESET}"
}

# === Funzione per rilevare package manager ===
detect_pkg_manager() {
    if command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
    else
        echo -e "${RED}Error: No supported package manager found (apt or dnf).${RESET}"
        exit 1
    fi
}

install_package() {
    PACKAGES=("$@")
    echo -e "${GREEN}Installing packages: ${PACKAGES[*]}${RESET}"
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update
        sudo apt install -y "${PACKAGES[@]}"
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y "${PACKAGES[@]}"
    fi
}

# === Funzioni installazione ===

install_zsh() {
    banner "Installing Oh My Zsh"
    if ! command -v zsh >/dev/null 2>&1; then
        echo -e "${GREEN}Zsh not found, installing...${RESET}"
        install_package zsh zsh-doc
    fi
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${GREEN}Installing Oh My Zsh framework...${RESET}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        cd $REPO_ROOT_DIR
        cat .oh-my-zsh/custom/aliases.zsh > $HOME/.oh-my-zsh/custom/aliases.zsh
        cd -
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
        git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/you-should-use
        install_package python3-virtualenvwrapper
        cd $REPO_ROOT_DIR
        cat .zshrc > $HOME/.zshrc
        cd -
        chsh -s "$(which zsh)"
        banner "All tasks completed!"
        zsh
    else
        echo -e "${YELLOW}Oh My Zsh already installed.${RESET}"
    fi
}

install_tmux() {
    banner "Installing Oh My Tmux"
    if ! command -v tmux >/dev/null 2>&1; then
        echo -e "${GREEN}Tmux not found, installing...${RESET}"
        install_package tmux
    fi
    if [ ! -d "$HOME/.oh-my-tmux" ]; then
        echo -e "${GREEN}Cloning Oh My Tmux repository...${RESET}"
        git clone https://github.com/gpakosz/.tmux.git ~/.oh-my-tmux
        ln -s -f ~/.oh-my-tmux/.tmux.conf ~/.tmux.conf
        cp ~/.oh-my-tmux/.tmux.conf.local ~/
        git clone https://github.com/tmux-plugins/tmux-resurrect ~/tmux-resurrect
        cd $REPO_ROOT_DIR
        cat .tmux.conf.local > $HOME/.tmux.conf.local
        cd -
    else
        echo -e "${YELLOW}Oh My Tmux already installed.${RESET}"
    fi
}

install_docker() {
    banner "Installing Docker"
    if command -v docker >/dev/null 2>&1; then
        echo -e "${YELLOW}Docker already installed.${RESET}"
        return
    fi

    echo -e "${GREEN}Installing Docker and dependencies...${RESET}"

    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo apt update
        sudo apt install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
            sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
          https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}Docker installed.${RESET}"
    echo -e "${YELLOW}You may need to logout and login again to use Docker as non-root.${RESET}"
}

install_tools() {
    banner "Installing Utilities (btop, net-tools, duf...)"

    install_package btop net-tools git eza fzf unzip wget vim python3-pip 
    sudo snap install dust
    cd ~
    wget https://github.com/owenthereal/ccat/releases/download/v1.1.0/linux-amd64-1.1.0.tar.gz
    tar -xvf linux-amd64-1.1.0.tar.gz
    sudo mv linux-amd64-1.1.0/ccat /usr/bin/
    rm linux-amd64-1.1.0.tar.gz
    if grep -i "Microsoft" /proc/sys/kernel/osrelease; then
        echo "You are inside WSL. Skipping font installation."
    else
        banner "Not inside WSL. Installing fonts."
        # Aggiungi qui la tua installazione di font
        banner "Installing Nerd Fonts (FiraCode)"
        mkdir -p ~/.local/share/fonts
        cd /tmp
        curl -fLo "FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
        unzip -o FiraCode.zip -d FiraCode
        cp FiraCode/*.ttf ~/.local/share/fonts/
        fc-cache -fv
        cd -  
    fi
}

# === Parsing parametri ===

INSTALL_ZSH=false
INSTALL_TMUX=false
INSTALL_DOCKER=false
INSTALL_TOOLS=false

if [ $# -eq 0 ] || [[ " $* " == *" --all "* ]]; then
    INSTALL_ZSH=true
    INSTALL_TMUX=true
    INSTALL_DOCKER=true
    INSTALL_TOOLS=true
else
    for arg in "$@"; do
        case "$arg" in
            --zsh)
                INSTALL_ZSH=true
                INSTALL_TOOLS=true
                ;;
            --tmux)
                INSTALL_TMUX=true
                INSTALL_TOOLS=true
                ;;
            --docker)
                INSTALL_DOCKER=true
                INSTALL_TOOLS=true
                ;;
            --tools)
                INSTALL_TOOLS=true
                ;;
            --all)
                INSTALL_ZSH=true
                INSTALL_TMUX=true
                INSTALL_DOCKER=true
                INSTALL_TOOLS=true
                ;;
            *)
                echo -e "${RED}Unknown option: $arg${RESET}"
                echo "Usage: $0 [--all] [--zsh] [--tmux] [--docker] [--tools]"
                exit 1
                ;;
        esac
    done
fi

# === Detect distro & package manager ===
detect_pkg_manager

# === Installazioni richieste ===
[ "$INSTALL_TOOLS" = true ] && install_tools
[ "$INSTALL_TMUX" = true ] && install_tmux
[ "$INSTALL_DOCKER" = true ] && install_docker
[ "$INSTALL_ZSH" = true ] && install_zsh

# banner "All tasks completed!"
