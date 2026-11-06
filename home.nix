{ config, pkgs, ... }:

{
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # браузеры и офис
    firefox
    chromium
    onlyoffice-desktopeditors
    obsidian

    # связь
    telegram-desktop
    discord

    # разработка
    zed-editor
    jetbrains.pycharm # unified PyCharm: используем бесплатные основные функции, без Pro-подписки
    python3
    lazygit

    # игры
    prismlauncher

    # секреты
    bitwarden-desktop

    # сеть и лаборатория (wireshark ставится системным модулем)
    nmap
    tcpdump
    iperf3
    mtr

    # утилиты
    btop
    jq
    tree
    neovim
    fzf
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "artem-blshkn";
      user.email = "artem.blshkn.git@gmail.com"; # git-only почта, не основная
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.starship.enable = true;

  home.shellAliases = {
    # снапшот перед пересборкой: если новое поколение не загрузится —
    # откат через меню systemd-boot или snapper
    rebuild = "sudo snapper -c root create -d 'before rebuild' || true; sudo nixos-rebuild switch --flake ~/nixos-config#thinkpad";
    update = "nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config#thinkpad";
    snap = "sudo snapper -c root create -d manual";
    gc = "sudo nix-collect-garbage -d";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };
}
