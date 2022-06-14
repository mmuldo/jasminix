{
    description = "system flake";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-21.11";
        home-manager.url = "github:nix-community/home-manager/release-21.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        nix-matlab = {
            inputs.nixpkgs.follows = "nixpkgs";
            url = "gitlab:doronbehar/nix-matlab";
        };
    };

    outputs = { nixpkgs, home-manager, nixos-hardware, nix-matlab, ... }:
    let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
        theme = (import ./users/matt/themes.nix).nord;
        flake-overlays = [
            nix-matlab.overlay
        ];
    in {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [

                nixos-hardware.nixosModules.lenovo-thinkpad-t420

                (import ./system/configuration.nix flake-overlays)

                home-manager.nixosModules.home-manager {
                    home-manager.users.matt = { config, pkgs, lib, ... }: {
                        nixpkgs.config.allowUnfree = true;

                        imports = [
                          ./users/matt/qtile.nix
                        ];

                        home.stateVersion = lib.mkForce "21.11";

                        home.packages = with pkgs; 
                        #let
                        #  my-python-packages = python-packages: with python-packages; [
                        #    jinja2
                        #  ];
                        #  python-with-my-packages = python3.withPackages my-python-packages;
                        #in
                        [
                            anki
                            #alacritty
                            conda
                            discord
                            #dmenu
                            exa
                            feh
                            flameshot
                            #git
                            #gnupg
                            gcc
                            gnome.networkmanagerapplet
                            jupyter
                            musescore
                            networkmanager_dmenu
                            #neovim
                            nodejs
                            pass
                            pdftk
                            picom
                            pinentry-qt
                            python39Full
                            python39Packages.pip
                            #python-with-my-packages
                            #rofi
                            remmina
                            rpi-imager
                            spotify-tui
                            thunderbird
                            vscode
                            xclip
                            zoom-us
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
                                core.editor = "nvim";
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
                            plugins = [
                                {
                                    name = "zsh-nix-shell";
                                    file = "nix-shell.plugin.zsh";
                                    src = pkgs.fetchFromGitHub {
                                        owner = "chisui";
                                        repo = "zsh-nix-shell";
                                        rev = "v0.4.0";
                                        sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
                                    };
                                }
                            ];
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
                                gs = "git status";
                                ls = "exa";
                                vim = "nvim";
                                v = "nvim";
                                vc = "nvim ~/code/jasminix/system/configuration.nix";
                                vh = "nvim ~/code/jasminix/users/matt/home.nix";
                                vf = "nvim ~/code/jasminix/flake.nix";
                                see = "TERM=vt100 ssh electrical@192.168.1.3";
                            };
                        };

                        programs.qtile = {
                            enable = true;
                            theme = theme;
                        };

                        home.file.".config/qtile/autostart.sh" = {
                            text = ''
                                #!/bin/sh
                                feh --no-fehbg --bg-fill '/home/matt/wallpapers/minimal-25-nordified.jpg' '/home/matt/wallpapers/minimal-25-nordified.jpg'
                                #picom --experimental-backends &
                                #dropbox &
                                nm-applet &
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
                                        background = "${theme.normal.black}";
                                        foreground =  "${theme.normal.white}";
                                        dim_foreground =  "${theme.dim.white}";
                                    };
                                    cursor = {
                                        text =  "CellBackground";
                                        cursor =  "CellForeground";
                                    };
                                    selection = {
                                        text =  "CellBackground";
                                        background =  "CellForeground";
                                    };
                                    normal = {
                                        black =     "${theme.normal.black}";
                                        red =       "${theme.normal.red}";
                                        green =     "${theme.normal.green}";
                                        yellow =    "${theme.normal.yellow}";
                                        blue =      "${theme.normal.blue}";
                                        magenta =   "${theme.normal.magenta}";
                                        cyan =      "${theme.normal.cyan}";
                                        white =     "${theme.normal.white}";
                                    };
                                    bright = {
                                        black =     "${theme.bright.black}";
                                        red =       "${theme.bright.red}";
                                        green =     "${theme.bright.green}";
                                        yellow =    "${theme.bright.yellow}";
                                        blue =      "${theme.bright.blue}";
                                        magenta =   "${theme.bright.magenta}";
                                        cyan =      "${theme.bright.cyan}";
                                        white =     "${theme.bright.white}";
                                    };
                                    dim = {
                                        black =     "${theme.dim.black}";
                                        red =       "${theme.dim.red}";
                                        green =     "${theme.dim.green}";
                                        yellow =    "${theme.dim.yellow}";
                                        blue =      "${theme.dim.blue}";
                                        magenta =   "${theme.dim.magenta}";
                                        cyan =      "${theme.dim.cyan}";
                                        white =     "${theme.dim.white}";
                                    };
                                };
                            };
                        };

                        programs.neovim = {
                            enable = true;
                            extraConfig = ''
                                filetype plugin indent on
                                set nocompatible 
                                set showmatch ignorecase smartcase hlsearch incsearch
                                set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
                                set number
                                set wildmode=longest,list
                                set cursorline
                                set ttyfast
                                set clipboard+=unnamedplus
                                set cc=80
                                set title
                                set termguicolors
                                colorscheme nord
                                set splitright splitbelow
                                let mapleader=" "
                                nmap <leader>0 :NERDTreeToggle<CR>
                            '';
                            withPython3 = true;
                            plugins = with pkgs.vimPlugins; [
                                vim-nix
                                nord-vim
                                ultisnips
                                vim-devicons
                                vim-snippets
                                nerdtree
                                nerdcommenter
                                vim-startify
                                vim-surround
                                coc-nvim
                                coc-pyright
                            ];
                        };

                        programs.rofi = {
                            enable = true;
                            pass.enable = true;
                            extraConfig = {
                                modi = "drun,emoji,run,window";
                                width = 800;
                                lines = 15;
                                columns = 1;
                                bw = 0;
                                terminal = "alacritty";
                                icon-theme = "candy-icons";
                                show-icons = true;
                                theme = "launcher";
                                fake-transparency = false;
                                kb-mode-next = "Shift+Right,Control+Tab,Alt+n";
                                kb-mode-previous = "Shift+Left,Control+ISO_Left_Tab,Alt+p";
                            };
                            plugins = with pkgs; [
                                rofi-emoji
                                rofi-calc
                            ];
                        };

                        home.file.".config/rofi/launcher.rasi".text = ''
                            * {
                                selected-normal-foreground:  rgba ( 2, 20, 63, 100 % );
                                foreground:                  rgba ( 219, 223, 188, 100 % );
                                normal-foreground:           @foreground;
                                alternate-normal-background: rgba ( 0, 0, 0, 0 % );
                                red:                         rgba ( 220, 50, 47, 100 % );
                                selected-urgent-foreground:  rgba ( 2, 20, 63, 100 % );
                                blue:                        rgba ( 38, 139, 210, 100 % );
                                urgent-foreground:           rgba ( 255, 129, 255, 100 % );
                                alternate-urgent-background: rgba ( 0, 0, 0, 0 % );
                                active-foreground:           rgba ( 138, 196, 255, 100 % );
                                lightbg:                     rgba ( 238, 232, 213, 100 % );
                                selected-active-foreground:  rgba ( 2, 20, 63, 100 % );
                                alternate-active-background: rgba ( 0, 0, 0, 0 % );
                                background:                  rgba ( 0, 0, 33, 87 % );
                                bordercolor:                 rgba ( 219, 223, 188, 100 % );
                                alternate-normal-foreground: @foreground;
                                normal-background:           rgba ( 0, 0, 208, 0 % );
                                lightfg:                     rgba ( 88, 104, 117, 100 % );
                                selected-normal-background:  rgba ( 219, 223, 188, 100 % );
                                border-color:                @foreground;
                                spacing:                     2;
                                separatorcolor:              rgba ( 219, 223, 188, 100 % );
                                urgent-background:           rgba ( 0, 0, 208, 0 % );
                                selected-urgent-background:  rgba ( 255, 129, 127, 100 % );
                                alternate-urgent-foreground: @urgent-foreground;
                                background-color:            rgba ( 0, 0, 0, 0 % );
                                alternate-active-foreground: @active-foreground;
                                active-background:           rgba ( 0, 0, 208, 0 % );
                                selected-active-background:  rgba ( 138, 196, 255, 100 % );
                            }
                            window {
                                background-color: @background;
                                border:           1;
                                padding:          5;
                            }
                            mainbox {
                                border:  0;
                                padding: 0;
                            }
                            message {
                                border:       2px 0px 0px ;
                                border-color: @separatorcolor;
                                padding:      1px ;
                            }
                            textbox {
                                text-color: @foreground;
                            }
                            listview {
                                fixed-height: 0;
                                border:       2px 0px 0px ;
                                border-color: @separatorcolor;
                                spacing:      2px ;
                                scrollbar:    true;
                                padding:      2px 0px 0px ;
                            }
                            element {
                                border:  0;
                                padding: 1px ;
                            }
                            element-text {
                                background-color: inherit;
                                text-color:       inherit;
                            }
                            element.normal.normal {
                                background-color: @normal-background;
                                text-color:       @normal-foreground;
                            }
                            element.normal.urgent {
                                background-color: @urgent-background;
                                text-color:       @urgent-foreground;
                            }
                            element.normal.active {
                                background-color: @active-background;
                                text-color:       @active-foreground;
                            }
                            element.selected.normal {
                                background-color: @selected-normal-background;
                                text-color:       @selected-normal-foreground;
                            }
                            element.selected.urgent {
                                background-color: @selected-urgent-background;
                                text-color:       @selected-urgent-foreground;
                            }
                            element.selected.active {
                                background-color: @selected-active-background;
                                text-color:       @selected-active-foreground;
                            }
                            element.alternate.normal {
                                background-color: @alternate-normal-background;
                                text-color:       @alternate-normal-foreground;
                            }
                            element.alternate.urgent {
                                background-color: @alternate-urgent-background;
                                text-color:       @alternate-urgent-foreground;
                            }
                            element.alternate.active {
                                background-color: @alternate-active-background;
                                text-color:       @alternate-active-foreground;
                            }
                            scrollbar {
                                width:        4px ;
                                border:       0;
                                handle-width: 8px ;
                                padding:      0;
                            }
                            mode-switcher {
                                border:       2px 0px 0px ;
                                border-color: @separatorcolor;
                            }
                            button.selected {
                                background-color: @selected-normal-background;
                                text-color:       @selected-normal-foreground;
                            }
                            inputbar {
                                spacing:    0;
                                text-color: @normal-foreground;
                                padding:    1px ;
                            }
                            case-indicator {
                                spacing:    0;
                                text-color: @normal-foreground;
                            }
                            entry {
                                spacing:    0;
                                text-color: @normal-foreground;
                            }
                            prompt, button{
                                spacing:    0;
                                text-color: @normal-foreground;
                            }
                            inputbar {
                                children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
                            }
                            textbox-prompt-colon {
                                expand:     false;
                                str:        ":";
                                margin:     0px 0.3em 0em 0em ;
                                text-color: @normal-foreground;
                            }
                        '';
                        #home.file.".config/rofi/launcher.rasi".text = ''
                        #    * {
                        #        separatorcolor: ${theme.normal.black};
                        #        background-color: ${theme.normal.black};
                        #    }
                        #    
                        #    window {
                        #        border-color: ${theme.normal.yellow};
                        #        border: 4;
                        #        padding: 40px;
                        #        background-color: ${theme.normal.black};
                        #    }
                        #    
                        #    mainbox {
                        #        background-color: ${theme.normal.black};
                        #    }
                        #    
                        #    inputbar {
                        #        background-color: ${theme.normal.black};
                        #    }
                        #    
                        #    prompt {
                        #        background-color: ${theme.normal.black};
                        #        text-color: ${theme.normal.red};
                        #    }
                        #    
                        #    entry {
                        #        background-color: ${theme.normal.black};
                        #        text-color: ${theme.normal.yellow};
                        #    }
                        #    
                        #    case-indicator {
                        #        background-color: ${theme.normal.black};
                        #        text-color: ${theme.dim.cyan};
                        #    }
                        #    
                        #    
                        #    element.selected.normal {
                        #        background-color: ${theme.normal.white};
                        #        text-color:       ${theme.normal.black};
                        #    }
                        #    
                        #    element.normal.normal {
                        #        background-color: ${theme.normal.black};
                        #        text-color:       ${theme.normal.white};
                        #    }
                        #'';

                        programs.browserpass.enable = true;

                        programs.zathura.enable = true;

                        services.spotifyd = {
                            enable = true;
                            settings.global = {
                                username = "currybomber";
                                password_cmd = "pass spotify.com/itz.kyrith@gmail.com";
                                device_name = "nix";
                            };
                        };
                    };
                }

            ];
        };
    };
}
