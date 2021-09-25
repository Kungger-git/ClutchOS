#!/bin/env bash

# This is the installer for ClutchOS
# Since I have no knowledge of building my own iso image yet, I'll be using this
# Please enjoy it
# Open an issue if there are any bugs you need me to fix

# Github: https://github.com/KungPaoChick

set -e

set_color() {
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}

main() {
    set_color

    # creates srcs folder
    if [[ ! -d $HOME/.srcs/ ]]; then
	    mkdir -p $HOME/.srcs/
    fi
    
    # copies pacman.conf and mkinitcpio
    sudo cp -f systemfiles/pacman.conf \
               systemfiles/mkinitcpio.conf /etc/

    # adds passwd insults to sudoers.d
    sudo cp -f systemfiles/01_pw_feedback /etc/sudoers.d/

    reset
    echo "${BLUE}"
    echo "▄▄      ▄▄ ▄▄▄▄▄▄▄▄  ▄▄           ▄▄▄▄     ▄▄▄▄    ▄▄▄  ▄▄▄  ▄▄▄▄▄▄▄▄  ▄▄"; sleep 0.1
    echo "██      ██ ██▀▀▀▀▀▀  ██         ██▀▀▀▀█   ██▀▀██   ███  ███  ██▀▀▀▀▀▀  ██"; sleep 0.1
    echo "▀█▄ ██ ▄█▀ ██        ██        ██▀       ██    ██  ████████  ██        ██"; sleep 0.1
    echo " ██ ██ ██  ███████   ██        ██        ██    ██  ██ ██ ██  ███████   ██"; sleep 0.1
    echo " ███▀▀███  ██        ██        ██▄       ██    ██  ██ ▀▀ ██  ██        ▀▀"; sleep 0.1
    echo " ███  ███  ██▄▄▄▄▄▄  ██▄▄▄▄▄▄   ██▄▄▄▄█   ██▄▄██   ██    ██  ██▄▄▄▄▄▄  ▄▄"; sleep 0.1
    echo " ▀▀▀  ▀▀▀  ▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀     ▀▀▀▀     ▀▀▀▀    ▀▀    ▀▀  ▀▀▀▀▀▀▀▀  ▀▀"
    echo "${RESET}"

    #
    # choose video driver
    #
    echo "${BOLD}##########################################################################${RESET}

${RED}1.) xf86-video-amdgpu     ${GREEN}2.) nvidia     ${BLUE}3.) xf86-video-intel${RESET}     4.) Skip

${BOLD}##########################################################################${RESET}"
    read -r -p "${YELLOW}${BOLD}[!] ${RESET}Choose your video card driver. ${YELLOW}(Default: 1)${RESET}: " vidri

    #
    # prompt for installing recommended packages
    #
    cat recommended_packages.txt
    read -p "${YELLOW}${BOLD}[!] ${RESET}Would you like to download these recommended system packages? [y/N] " recp

    #
    # select an aur helper to install
    #
    HELPER="yay"
    echo "${BOLD}####################${RESET}

${RED}1.) yay     ${BLUE}2.) paru${RESET}

${BOLD}####################${RESET}"
    printf  "\n\n${YELLOW}${BOLD}[!] ${RESET}An AUR helper is essential to install required packages.\n"
    read -r -p "${YELLOW}${BOLD}[!] ${RESET}Select an AUR helper. ${YELLOW}(Default: yay)${RESET}: " sel

    #
    # select a picom or picom fork
    #
    echo "${BOLD}##################################${RESET}

${RED}1.) picom   ${BLUE}2.) picom-jonaburg-git${RESET}

${BOLD}##################################${RESET}"
    read -r -p "${YELLOW}${BOLD}[!] ${RESET}Select your preferred compositor. ${YELLOW}(Default: 1)${RESET}: " comp

    #
    # prompt for selecting a shell environment
    #
    echo "${BOLD}##################################${RESET}

${RED}1.) bash${RESET}      ${GREEN}2.) zsh${RESET}     ${BLUE}3.) fish${RESET}

${BOLD}##################################${RESET}"
    read -r -p "${YELLOW}${BOLD}[!] ${RESET}Select your preferred shell.[Only for bspwm] ${YELLOW}(Default: 1)${RESET}: " she

    #
    # prompt for installing recommended aur packages
    #
    cat recommended_aur.txt
    read -p "${YELLOW}${BOLD}[!] ${RESET}Would you like to download these recommended aur packages? [y/N] " reca

    # prompt to install networking tools and applications
    read -p "${YELLOW}${BOLD}[!] ${RESET}Would you like to install networking tools and applications? [y/N] " netw

    # prompt to install audio tools and applications
    read -p "${YELLOW}${BOLD}[!] ${RESET}Would you like to install audio tools and applications? [y/N] " aud

    #
    #
    # post prompt process
    #
    #

    # aur helper set to paru if sel var is eq to 2
    if [ $sel -eq 2 ]; then
        HELPER="paru"
    fi

    # clones specified aur helper
    if ! command -v $HELPER &> /dev/null; then
        git clone https://aur.archlinux.org/$HELPER.git $HOME/.srcs/$HELPER
    fi

    # video driver card case
    case $vidri in
    [1])
            DRIVER='xf86-video-amdgpu xf86-video-ati xf86-video-fbdev'
            ;;

    [2])
            DRIVER='nvidia nvidia-settings nvidia-utils'
            ;;

    [3])
            DRIVER='xf86-video-intel xf86-video-nouveau'
            ;;

    [4])
            DRIVER=""
            ;;

    *)
            DRIVER='xf86-video-amdgpu xf86-video-ati xf86-video-fbdev'
            ;;
    esac

    ## full system upgrade
    clear
    printf "${GREEN}${BOLD}[*] ${RESET}Performing System Upgrade and Installation...\n\n"
    sudo pacman -Syu --noconfirm

    # installing selected video driver
    sudo pacman -S --needed --noconfirm $DRIVER

    # installs required system packages
    sudo pacman -S --needed --noconfirm - < packages.txt

    # installs a different version of rofi
    sudo pacman -U --noconfirm https://archive.archlinux.org/repos/2021/08/29/community/os/x86_64/rofi-1.6.1-1-x86_64.pkg.tar.zst

    #
    # Essential stuff, including: aur & other utility packages
    #

    # recommended packages installer
    if [[ "$recp" == "" || "$recp" == "N" || "$recp" == "n" ]]; then
        printf "\n${RED}${BOLD}Abort!${RESET}\n"
        echo "${YELLOW}${BOLD}[!] ${RESET}You can install them later by doing: ${YELLOW}(sudo pacman -S - < recommended_packages.txt)${RESET}"
    else
        sudo pacman -S --needed --noconfirm - < recommended_packages.txt
    fi

    # networking tools and applications installer
    if [[ "$netw" == "" || "$netw" == "N" || "$netw" == "n" ]]; then
        printf "\n${RED}Abort!${RESET}\n"
        echo "${YELLOW}${BOLD}[!] ${RESET}You can find the networking setup script in the bin folder."
    else
        (cd bin/; ./networking_setup.sh)
    fi

    # audio tools and applications installer
    if [[ "$aud" == "" || "$aud" == "N" || "$aud" == "n" ]]; then
        printf "\n${RED}Abort!${RESET}\n"
        echo "${YELLOW}${BOLD}[!] ${RESET}You can find the audio setup script in the bin folder."
    else
        (cd bin/; ./audio_setup.sh)
    fi
    
    # aur installer
    if [[ -d $HOME/.srcs/$HELPER ]]; then
        printf "\n\n${YELLOW}${BOLD}[!] ${RESET}We'll be installing ${GREEN}${BOLD}$HELPER${RESET} now.\n\n"
        (cd $HOME/.srcs/$HELPER/; makepkg -si --noconfirm)
    fi

    # install aur packages
    $HELPER -S --needed --noconfirm - < aur.txt

    # recommended aur packages installer
    if [[ "$reca" == "" || "$reca" == "N" || "$reca" == "n" ]]; then
        printf "\n${RED}Abort!${RESET}\n"
        echo "${YELLOW}${BOLD}[!] ${RESET}You can install them later by doing: ${YELLOW}($HELPER -S - < recommended_aur.txt)${RESET}"
    else
        $HELPER -S --needed --noconfirm - < recommended_aur.txt
    fi

    #
    # Back to copying more stuff
    #

    # touchpad config
    sudo cp -f systemfiles/02-touchpad-ttc.conf /etc/X11/xorg.conf.d/

    # enable display manager
    sudo systemctl enable lxdm-plymouth.service

    # copies scripts to /usr/local/bin directory
    sudo cp -f scripts/* /usr/local/bin

    #
    # Grub and Plymouth configuration
    #

    # writes grub menu entries, copies grub, themes and updates it
    sudo bash -c "cat >> '/etc/grub.d/40_custom' <<-EOF

    menuentry 'Reboot System' --class restart {
        reboot
    }

    menuentry 'Shutdown System' --class shutdown {
        halt
    }"
    sudo cp -f grubcfg/grubd/* /etc/grub.d/
    sudo cp -f grubcfg/grub /etc/default/
    sudo cp -rf grubcfg/themes/default /boot/grub/themes/
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    # plymouth
    sudo cp -f lxdm/lxdm.conf /etc/lxdm/
    sudo cp -rf lxdm/lxdm-theme/* /usr/share/lxdm/themes/
    sudo plymouth-set-default-theme -R arch10

    # xsessions
    sudo cp -rf xsessions /usr/share/

    #
    # Now for the more important things, the dots & configs
    #

    # make user dirs
    xdg-user-dirs-update

    # install selected compositor
    case $comp in
    [1])
            sudo pacman -S --needed --noconfirm picom &&
            cp -f compositors/default/picom.conf $HOME/.config/
            ;;
    [2])
            $HELPER -S --needed --noconfirm picom-jonaburg-git &&
            cp -r compositors/jonaburg/picom.conf $HOME/.config/
            ;;
    *)
            sudo pacman -S --needed --noconfirm picom &&
            cp -r compositors/default/picom.conf $HOME/.config/
            ;;
    esac

    # copy dots to home
    cp -rf dots/.dwm       \
           dots/.mpd       \
           dots/.ncmpcpp   \
           dots/.dmrc      \
           dots/.gtkrc-2.0 \
           dots/.vimrc $HOME

    # replaces username in files
    sed -i "s/kungger/$USER/g" $HOME/.gtkrc-2.0
    sed -i "s/kungger/$USER/g" $HOME/.dwm/config.def.h

    # copies all configurations to .config
    cp -rf configs/* $HOME/.config/

    #
    # Shell installer
    #

    # shell environment case
    case $she in
    [1])
            printf "\nYou chose ${YELLOW}bash shell${RESET}\n\n"
            
            # copies bashrc file
            cp -f shells/bash/.bashrc $HOME
            ;;
    [2])
            printf "\nYou chose ${YELLOW}zsh shell${RESET}\n\n"
            sudo pacman -S --needed --noconfirm zsh
            curl -L http://install.ohmyz.sh | sh
            sed -i "s/alacritty.yml/alacritty.yml -e zsh/g" $HOME/.config/sxhkd/sxhkdrc           
 
            # copies zshrc file
            cp -f shells/zsh/.zshrc $HOME
           
            # replace username in zsh export
            sed -i "s/kungger/$USER/g" $HOME/.zshrc
 
            # clone and install zsh plugins
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
            git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
            ;;
    [3])
            printf "\nYou chose ${YELLOW}fish shell${RESET}\n\n"
            sudo pacman -S --needed --noconfirm fish
            sed -i "s/alacritty.yml/alacritty.yml -e fish/g" $HOME/.config/sxhkd/sxhkdrc

            # downloads oh-my-fish installer
            curl -L https://get.oh-my.fish > $HOME/.srcs/install.fish; chmod +x $HOME/.srcs/install.fish
            #fish -c "cd $HOME/.srcs/; ./install.fish; omf install cbjohnson"
            clear
            echo "${YELLOW}${BOLD}[!] ${RESET}oh-my-fish install script has been downloaded. You can execute the installer later on in ${YELLOW}$HOME/.srcs/install.fish${RESET}"; sleep 3
        
            # copies fish congigurations
            if [[ ! -d $HOME/.config/fish ]]; then
                mkdir -p $HOME/.config/fish
                cp -rf shells/fish/config.fish $HOME/.config/fish/
            else
                cp -rf shells/fish/config.fish $HOME/.config/fish/
            fi
            ;;
    *)
            printf "\nThe default is: ${YELLOW}bash shell${RESET}\n\n"

            # copies bashrc file
            cp -f shells/bash/.bashrc $HOME
            ;;
    esac

    # installs fish as default shell environment for the other WMs
    if ! command -v fish &> /dev/null; then
        sudo pacman -S --noconfirm fish
        curl -L https://get.oh-my.fish/ > $HOME/.srcs/install.fish; chmod +x $HOME/.srcs/install.fish

        clear
        echo "${YELLOW}${BOLD}[!] ${RESET}oh-my-fish install script has been downloaded. You can execute the installer later on in ${YELLOW}$HOME/.srcs/install.fish${RESET}"; sleep 3
        
        # copies fish configurations
        if [[ ! -d $HOME/.config/fish/ ]]; then
            mkdir -p $HOME/.config/fish
            cp -f shells/fish/config.fish $HOME/.config/fish/
        else
            cp -f shells/fish/config.fish $HOME/.config/fish/
        fi
    fi

    #
    # compile dwm
    #

    # compiles dwm
    if [[ -d $HOME/.dwm ]]; then
        (cd $HOME/.dwm; sudo make clean install)
    fi

    # clones & compiles dwmblocks
    if [[ ! -d $HOME/.config/dwmblocks ]]; then
        git clone https://github.com/KungPaoChick/dwmblocks-kungger.git $HOME/.config/dwmblocks
        (cd $HOME/.config/dwmblocks; sudo make clean install)        
    fi

    # clones & compiles dmenu
    if [[ ! -d $HOME/.config/dmenu ]]; then
        git clone https://github.com/KungPaoChick/dmenu-kungger.git $HOME/.config/dmenu
        (cd $HOME/.config/dmenu; sudo make clean install)
    fi

    # install fonts for the bars
    FDIR="$HOME/.local/share/fonts"
    echo -e "\n${GREEN}${BOLD}[*] ${RESET}Installing fonts..."
    if [[ -d "$FDIR" ]]; then
        cp -rf fonts/* "$FDIR"
    else
        mkdir -p "$FDIR"
        cp -rf fonts/* "$FDIR"
    fi

    #
    # Finalization and cleaning up
    #

    # last orphan delete and cache delete
    sudo pacman -Rns --noconfirm $(pacman -Qtdq); sudo pacman -Sc --noconfirm; $HELPER -Sc --noconfirm; sudo pacman -R --noconfirm i3-wm
    rm -rf $HOME/.srcs/$HELPER
    
    # reboot prompt
    clear
    read -p "${GREEN}$USER!${RESET}, Reboot Now? ${YELLOW}(Required)${RESET} [Y/n] " reb
    if [[ "$reb" == "" || "$reb" == "Y" || "$reb" == "y" ]]; then
        reboot
    else
        printf "\n${RED}Abort!${RESET}\n"
    fi
}

main "@"
