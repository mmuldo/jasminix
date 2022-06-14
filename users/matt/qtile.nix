{ config, lib, ... }:

with lib;
let
  cfg = config.programs.qtile;
in {
  options.programs.qtile = {
    enable = mkEnableOption "qtile window manager";
    theme = mkOption {
      type = types.attrs;
      default = config.theme;
    };
  };

  config = mkIf cfg.enable {
    home.file.".config/qtile/config.py".text = ''
      from typing import List
      from libqtile import bar, layout, widget, hook, qtile
      from libqtile.config import Click, Drag, Group, Key, Match, Screen
      from libqtile.lazy import lazy
      from libqtile.utils import guess_terminal
      
      import os
      import subprocess
      
      mod = "mod4"
      terminal = "alacritty"
      browser = "firefox"
      
      keys = [
          # restart/quit qtile
          Key([mod, "shift"],
              "r",
              lazy.restart(),
              desc="restart qtile"),
          Key([mod, "shift"],
              "e",
              # lazy.shutdown(), #TODO: change to rofi on/off
              lazy.spawn(f"{os.environ['HOME']}/.local/bin/power-control"),
              desc="shutdown qtile"),
      
          # launch terminal
          Key([mod],
              "Return",
              lazy.spawn(terminal),
              desc=f"launch {terminal}"),
      
          # app launcher
          Key([mod],
              "d",
              lazy.spawn("rofi -show drun"),
              desc=f"launch rofi"),
      
          # kill window
          Key([mod],
              "x",
              lazy.window.kill(),
              desc="kill focused window"),
      
          # switch between windows
          Key([mod],
              "j",
              lazy.layout.down(),
              desc="move focus down"),
          Key([mod],
              "k",
              lazy.layout.up(),
              desc="move focus up"),
          Key([mod],
              "space",
              lazy.layout.next(),
              desc="move focus to other window"),
      
          # resize windows
          Key([mod],
              "h",
              lazy.layout.shrink(),
              desc="shrink master pane"),
          Key([mod],
              "l",
              lazy.layout.grow(),
              desc="grow master pane"),
      
          # move windows
          Key([mod, "shift"],
              "j",
              lazy.layout.shuffle_down(),
              desc="shift window down"),
          Key([mod, "shift"],
              "k",
              lazy.layout.shuffle_up(),
              desc="shift window up"),
      
          # reset windows to normal
          Key([mod],
              "n",
              lazy.layout.normalize(),
              desc="reset all window sizes"),
      
          # fullscreen window
          Key([mod],
              "f",
              lazy.window.toggle_fullscreen(),
              desc="toggle fullscreen"),
      
          # screen focus
          Key([mod],
              "w",
              lazy.to_screen(0),
              desc="focus monitor 1"),
          Key([mod],
              "e",
              lazy.to_screen(1),
              desc="focus monitor 2"),
          Key([mod],
              "r",
              lazy.to_screen(2),
              desc="focus monitor 3"),
      
          # pass
          Key([mod],
              "p",
              lazy.spawn("rofi-pass"),
              desc="show password-store in rofi"),
      
          # emojis
          Key([mod],
              "o",
              lazy.spawn("~/.local/bin/copy-emoji"),
              desc="prompt for copying emoji")
      
      ]
      
      # volume
      keys.extend([
          Key([],
              f'XF86Audio{action}',
              lazy.spawn(f'amixer sset Master {change}'))
          for action, change in {
              'RaiseVolume': '1%+', 
              'LowerVolume': '1%-', 
              'Mute': 'toggle'
          }.items()
      ])
      
      # brightness
      keys.extend([
          Key([],
              f'XF86MonBrightness{action}',
              lazy.spawn(f'xbacklight -{change} 5'))
          for action, change in {
              'Up': 'inc', 
              'Down': 'dec', 
          }.items()
      ])
      
      groups = [Group(i) for i in ""]
      
      for i, group in enumerate(groups):
          keys.extend([
              # group switching
              Key([mod],
                  str(i),
                  lazy.group[group.name].toscreen(),
                  desc=f"Switch to group {group.name}"),
      
              # group shifting
              Key([mod, "shift"],
                  str(i),
                  lazy.window.togroup(group.name),
                  desc=f"move focused window to group {group.name}")
          ])
      
      layouts = [
          l(border_width=4,
            border_normal="${cfg.theme.normal.black}",
            border_focus="${cfg.theme.bright.red}",
            margin=10,
            **kwargs)
      
          for l, kwargs in {
                  layout.MonadTall: {},
                  layout.Max: {}
          }.items()
      ]
      
      widget_defaults = dict(
          font="Monospace",
          fontsize=16,
          background="${cfg.theme.normal.black}",
          foreground="${cfg.theme.normal.white}",
          borderwidth=3,
          padding=5,
      )
      extension_defaults = widget_defaults.copy()
      
      screens = [
          Screen(
              top=bar.Bar(
                  [
                      widget.Spacer(
                          length=5
                      ),
                      widget.CurrentLayoutIcon(
                          scale=.5
                      ),
                      widget.GroupBox(
                          active="${cfg.theme.dim.blue}",
                          inactive="${cfg.theme.bright.black}",
                          urgent_alert_method="text",
                          urgent_text="${cfg.theme.normal.red}",
                          this_current_screen_border="${cfg.theme.bright.green}",
                          highlight_method="text",
                          padding=10
                      ),
                      widget.Spacer(
                          length=bar.STRETCH
                      ),
                      widget.Systray(
                      ),
                      widget.Spacer(
                          length=10
                      ),
                      widget.Memory(
                          foreground="${cfg.theme.dim.cyan}",
                          format=" {MemPercent}%",
                          update_interval=3.0
                      ),
                      widget.Spacer(
                          length=10
                      ),
                      widget.CPU(
                          foreground="${cfg.theme.normal.yellow}",
                          format=" {load_percent}%",
                          update_interval=3.0
                      ),
                      widget.Spacer(
                          length=10
                      ),
                      widget.ThermalSensor(
                          foreground="${cfg.theme.normal.green}",
                          fmt=" {}",
                          tag_sensor="Core 0",
                          foreground_alert="${cfg.theme.normal.red}",
                          threshold=60
                      ),
                      widget.Spacer(
                          length=10
                      ),
                      #widget.Net(
                      #    foreground="${cfg.theme.normal.yellow}",
                      #    format=" {down} ↓↑ {up}",
                      #    update_interval=2,
                      #    mouse_callbacks={
                      #        'Button1': lambda: qtile.cmd_spawn("networkmanager_dmenu")
                      #    }
                      #),
                      widget.Spacer(
                          length=10
                      ),
                      widget.Volume(
                          foreground="${cfg.theme.normal.blue}",
                          fmt=" {}"
                      ),
                      widget.Spacer(
                          length=10
                      ),
                      widget.Battery(
                          foreground="${cfg.theme.normal.magenta}",
                          format="{char} {percent:2.0%}",
                          show_short_text=False,
                          full_char="",
                          charge_char="",
                          discharge_char="",
                          empty_char="",
                          low_foreground="${cfg.theme.normal.red}",
                          low_percentage=0.2,
                          notify_below=0.2
                      ),
                      widget.Spacer(
                          length=10
                      ),
                      widget.Clock(
                          foreground="${cfg.theme.normal.cyan}",
                          fmt=" {}",
                          format='%a %b %d %I:%M %p'
                      ),
                      widget.Spacer(
                          length=10
                      ),
                  ],
                  size=30,
                  margin=[10, 10, 0, 10],
                  opacity=0.8
              ),
          ),
      ]
      
      # mouse events
      mouse = [
          # float windows
          # reposition window
          Drag([mod],
               "Button1",
               lazy.window.set_position_floating(),
               start=lazy.window.get_position()),
          # resize window
          Drag([mod],
               "Button3",
               lazy.window.set_size_floating(),
               start=lazy.window.get_size()),
          # focus window
          Click([mod],
                "Button2",
                lazy.window.bring_to_front())
      ]
      
      dgroups_key_binder = None
      dgroups_app_rules = []  # type: List
      follow_mouse_focus = True
      bring_front_click = False
      cursor_warp = False
      floating_layout = layout.Floating(float_rules=[
          # Run the utility of `xprop` to see the wm class and name of an X client.
          *layout.Floating.default_float_rules,
          Match(wm_class='confirmreset'),  # gitk
          Match(wm_class='makebranch'),  # gitk
          Match(wm_class='maketag'),  # gitk
          Match(wm_class='ssh-askpass'),  # ssh-askpass
          Match(title='branchdialog'),  # gitk
          Match(title='pinentry'),  # GPG key password entry
      ])
      auto_fullscreen = True
      focus_on_window_activation = "smart"
      reconfigure_screens = True
      
      # If things like steam games want to auto-minimize themselves when losing
      # focus, should we respect this or not?
      auto_minimize = True
      
      @hook.subscribe.startup
      def autostart():
          subprocess.run([f"{os.environ['HOME']}/.config/qtile/autostart.sh"])
      
      # XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
      # string besides java UI toolkits; you can see several discussions on the
      # mailing lists, GitHub issues, and other WM documentation that suggest setting
      # this string if your java app doesn't work correctly. We may as well just lie
      # and say that we're a working one by default.
      #
      # We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
      # java that happens to be on java's whitelist.
      wmname = "LG3D"
    '';
  };
}

