flake-overlays:
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # enable nix flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = flake-overlays;

  # use grub 2 as boot loader
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sdb";
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [3389];

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces = {
      enp0s25.useDHCP = true;
      wlp3s0.useDHCP = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # list packages installed in system profile
  environment.systemPackages = with pkgs; [
    dropbox
    lm_sensors
    mathematica
    matlab
    firefox
    vim 
    wget
    wineWowPackages.stable
    thinkfan
    zsh
  ];

  services = {
    xserver = {
      enable = true; # Enable the X11 windowing system.
      layout = "us"; # Configure keymap in X11
      libinput.enable = true; # enable touchpad support
      displayManager.lightdm.enable = true; # display manager
      windowManager.qtile.enable = true; # window manager
    };
    xrdp.enable = true;
    #thinkfan = {
    #  enable = true;
    #  levels = [
    #    [ "level full-speed" 0 32767 ]
    #  ];
    #  sensors = [
    #    {
    #      query = "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp1_input";
    #      type = "hwmon";
    #    }
    #    {
    #      query = "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp2_input";
    #      type = "hwmon";
    #    }
    #    {
    #      query = "/sys/devices/platform/coretemp.0/hwmon/hwmon4/temp3_input";
    #      type = "hwmon";
    #    }
    #  ];
    #};
    printing.enable = true; # enable CUPS to print documents
    openssh.enable = true; # ssh daemon
    #blueman.enable = true;
  };

  systemd.user.services.dropbox = {
    description = "dropbox";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  #hardware.bluetooth.enable = true;

  programs.zsh.enable = true;

  # don't prompt for password when a wheel member invokes sudo
  security.sudo.wheelNeedsPassword = false;

  # define a user account 
  users.users.matt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  fonts.fonts = with pkgs; [
    font-awesome
    twemoji-color-font
    nerdfonts
  ];
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

