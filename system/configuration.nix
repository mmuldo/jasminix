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

  # use grub 2 as boot loader
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sdb";
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;

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
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # list packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim 
    wget
    firefox
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
    printing.enable = true; # enable CUPS to print documents
    openssh.enable = true; # ssh daemon
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

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

