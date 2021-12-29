{ config, pkgs, lib, ... }:

let
  myTheme = (import ./themes.nix).nord;
in
{

  imports = [ 
    ./qtile.nix 
  ];


  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "matt";
  home.homeDirectory = "/home/matt";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = lib.mkForce "21.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    alacritty
    dmenu
    exa
    feh
    git
    gnupg
    networkmanager_dmenu
    neovim
    pinentry-qt
    rofi
    xclip
  ];

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  programs.git = {
    enable = true;
    userName = "Matt Muldowney";
    userEmail = "matt.muldowney@gmail.com";
    extraConfig = {
      github.user = "mmuldo";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    enableCompletion = true;
    autocd = true;
    initExtra = ''
      bindkey -v
      bindkey '^ ' autosuggest-accept
    '';
    oh-my-zsh = {
      enable = true;
      custom = "$HOME/.oh-my-zsh/custom";
      plugins = [
        "git"
	"zsh-vi-mode"
      ];
      theme = "agnoster";
    };
    sessionVariables = {
      PATH = "$HOME/.emacs.d/bin:$HOME/.local/bin:$HOME/.poetry/bin:$HOME/code/jasminix/bin:$PATH";
      XDG_CONFIG_HOME = "$HOME/.config";
    };
    shellAliases = {
      gaa = "git add -A";
      gc = "git commit";
      gcm = "git commit -m";
      gs = "git commit -m";
      ls = "exa";
      vim = "nvim";
      v = "nvim";
      vc = "nvim ~/code/jasminix/system/configuration.nix";
      vh = "nvim ~/code/jasminix/users/matt/home.nix";
    };
  };

  programs.qtile = {
    enable = true;
    theme = myTheme;
  };

  home.file.".config/qtile/autostart.sh" = {
    text = ''
      #!/bin/sh
      feh --no-fehbg --bg-fill '/home/matt/wallpapers/minimal-25-nordified.jpg' '/home/matt/wallpapers/minimal-25-nordified.jpg'
      #picom --experimental-backends &
      #dropbox &
    '';
    executable = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "alacritty";
      font.size = 9;
      draw_bold_text_with_bright_colors = true;
      selection.save_to_clipboard = false;
      live_config_reload = true;
      colors = {
        primary = {
          background = "${myTheme.normal.black}";
          foreground =  "${myTheme.normal.white}";
          dim_foreground =  "${myTheme.dim.white}";
	};
        cursor = {
          text =  "CellBackground";
          cursor =  "CellForeground";
	};
        selection = {
          text =  "CellForeground";
          background =  "CellBackground";
	};
        normal = {
          black =     "${myTheme.normal.black}";
          red =       "${myTheme.normal.red}";
          green =     "${myTheme.normal.green}";
          yellow =    "${myTheme.normal.yellow}";
          blue =      "${myTheme.normal.blue}";
          magenta =   "${myTheme.normal.magenta}";
          cyan =      "${myTheme.normal.cyan}";
          white =     "${myTheme.normal.white}";
        };
        bright = {
          black =     "${myTheme.bright.black}";
          red =       "${myTheme.bright.red}";
          green =     "${myTheme.bright.green}";
          yellow =    "${myTheme.bright.yellow}";
          blue =      "${myTheme.bright.blue}";
          magenta =   "${myTheme.bright.magenta}";
          cyan =      "${myTheme.bright.cyan}";
          white =     "${myTheme.bright.white}";
	};
        dim = {
          black =     "${myTheme.dim.black}";
          red =       "${myTheme.dim.red}";
          green =     "${myTheme.dim.green}";
          yellow =    "${myTheme.dim.yellow}";
          blue =      "${myTheme.dim.blue}";
          magenta =   "${myTheme.dim.magenta}";
          cyan =      "${myTheme.dim.cyan}";
          white =     "${myTheme.dim.white}";
	};
      };
    };
  };
}
