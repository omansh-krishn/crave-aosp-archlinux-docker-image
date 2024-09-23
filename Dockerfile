# Heavily based on https://github.dev/accupara/docker-images/tree/master/baseimages/phase1/ubuntu/22.04
FROM archlinux/archlinux:multilib-devel
COPY assets/sshd_config /tmp/
RUN set -x && \
  pacman -Sy --noconfirm \
  && pacman -Syu base-devel binutils byobu cargo chafa cmake curl croc extra-cmake-modules ffmpeg ffmpegthumbnailer fd fzf git git-lfs github-cli gnu-netcat gradle guile imagemagick jq less lsb-release meson ninja openssh openssl p7zip poppler popt python pacman-contrib psmisc remake ripgrep repo rsync subversion sudo tmux tree vim neovim wget xxhash yazi zoxide zsh --noconfirm \
  && pacman -Sc --noconfirm \
  && /usr/bin/ssh-keygen -A \
  && mkdir -p /etc/crave \
  && wget -O /etc/crave/create_build_tools_json.sh https://raw.githubusercontent.com/accupara/docker-images/master/baseimages/shared/create_build_tools_json.sh \
  && chmod +x /etc/crave/create_build_tools_json.sh \
  && curl -s https://raw.githubusercontent.com/accupara/crave/master/get_crave.sh | bash -s -- \
  && mv crave /usr/local/bin/ \
  && useradd -ms /usr/bin/zsh admin \
  && echo "admin:admin" | chpasswd \
  && usermod -aG wheel admin \
  && echo "admin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && mkdir -p /var/run/sshd \
  && mv /tmp/sshd_config /etc/ssh/sshd_config 
RUN ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime \
  && echo "Asia/Kolkata" > /etc/timezone
USER admin
ENV HOME=/home/admin \
    USER=admin \
    TERM=xterm \
    LANG=en_US.utf8
WORKDIR /home/admin
CMD /usr/bin/zsh
RUN set -x \
  && sudo chown -R admin:admin /home/admin \
  && mkdir /home/admin/.ssh \
  && chmod 700 /home/admin/.ssh \
  && touch /home/admin/.ssh/authorized_keys \
  && sudo chmod 0600 /etc/ssh/* \
  && echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen \
  && sudo locale-gen \
  && echo "export LC_ALL=en_US.UTF-8" >> /home/admin/.bashrc \
  && echo "export LANG=en_US.UTF-8" >> /home/admin/.bashrc \
  && echo "export LANGUAGE=en_US.UTF-8" >> /home/admin/.bashrc \
  && sudo mkdir -p /opt/aosp \
  && sudo chown admin:admin /opt/aosp \
  && git config --global user.name 'Omansh Krishn' \
  && git config --global user.email 'omansh@duck.com' \
  && git config --global color.ui true \
  && git config --global core.editor "vim" \
  && wget https://omansh.vercel.app/api/raw/?path=/omansh/pkgs/lib32-ncurses5-compat-libs/lib32-ncurses5-compat-libs-6.4-1-x86_64.pkg.tar.zst \
  && sudo pacman -U ./*zst --noconfirm && rm *zst \
  && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd .. && rm -rf paru \
  && paru -S aosp-devel lineageos-devel --noconfirm
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
  && $HOME/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install \
  && git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting \
  && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
  && git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
RUN byobu-enable && touch /home/admin/.config/byobu/.welcome-displayed

COPY assets/zshrc /home/admin/.zshrc
COPY assets/p10k.zsh /home/admin/.p10k.zsh

RUN sudo chmod 777 /etc/mke2fs.conf
RUN sudo rm -rf $HOME/.cache/paru $HOME/.cargo /var/cache/pacman/pkg/

COPY assets/telegram /usr/bin/
COPY assets/upload /usr/bin/

ENV REPO_NO_INTERACTIVE=1 \
    GIT_TERMINAL_PROMPT=0

EXPOSE 22

WORKDIR /tmp/src/android
