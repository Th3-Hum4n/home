{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
  url = "https://github.com/rycee/home-manager.git";
  rev = "19dd9866da0b62135ea96d779056984d1f0f2b80";
  ref = "master";
  };
in
{
  imports = [ "${home-manager}/nixos" ];

  users.users.viz = {
    name = "viz";
    isNormalUser = true;
    extraGroups = [ "viz" "wheel" "audio" "video" "input" ];
    home = "/home/viz";
    password = "nicetry";
    shell = pkgs.mksh;
  };


  # Workaround for getting home-manager to work in Nixos 19.09
  # See issue #948 in home-manager
  # systemd.services.home-manager-viz.preStart = "${pkgs.nix}/bin/nix-env -i -E";

  home-manager.users.viz = {
    home.packages = with pkgs; [
        mpv git xclip farbfeld clang-tools slock ffmpeg transmission socat wget curl
        xdotool xorg.xprop xorg.xrandr sxhkd
        chromium # Sorry, ren
        emacs # Emacs is good at everything except text editing
        racket-minimal
        go # A nice programming language?
        zathura # Possibly the easiest to use document reader
        dwm dmenu st tabbed bgs doas lemonbar-xft
        # Custom packages
        xscreenshot crud
    ];
    
    home.sessionVariables = {
      ENV = "\$HOME/lib/kshrc";
      PATH = "\$HOME/bin:\$PATH";
      LESSHISTFILE = "\$XDG_CACHE_HOME/lesshst";
      GOPATH = "\$HOME/opt/go:\$HOME/src/go";
      EDITOR = "vis";
      VISUAL = "vis";
      MANPAGER = "less";
      PYTHONUSERBASE = "\$HOME/opt/python";
      PYTHONPATH = "\$HOME/opt/python";
    };

    xdg = {
      enable = true;
      cacheHome = "/home/viz/.cache";
      configHome = "/home/viz/lib";
      dataHome = "/home/viz/opt";
      userDirs = {
        enable = true;
        desktop = "/no";
        documents = "/no";
        download = "~/tmp";
        music = "~/med/mus";
        pictures = "~/med/img";
        publicShare = "/no";
        templates = "/no";
        videos = "~/med/vid";
      };
    };

    programs = {
      home-manager.enable = true;

      git = {
        enable = true;
        userEmail = "visuwesh@tutanota.com";
        userName = "viz";
      };

      chromium = {
        enable = true;
        extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin 
          "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
          "kbmfpngjjgdllneeigpgjifpgocmfgmb" # RES
          "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus because some sites have horrible UI
        ];
      };

      zathura = {
        enable = true;
        options = {
          default-bg = "#e7e7d4";
          default-fg = "#1c1e1d";
          recolor-lightcolor = "#e7e7d4";
          recolor-darkcolor = "#1c1e1d";
          recolor = true;
          font = "Go Mono 14";
          guioptions = "";
        };
        extraConfig = ''
          map q abort
        '';
      };
    };

    services.sxhkd = {
      enable = true;
      extraPath = "/home/viz/bin/x";
      extraConfig = ''
        alt + p
          `menu run`
        super + shift + Return
          st -g 80x40 -t floating-st
        alt + shift + Return
          tab -w st
        super + {v,l,m}
          {chromium,slock,mus}
        super + {x,i,n,e}
          {turnoff,view_image,mbar,tab --parent-id emacsclient -c -a ""}
        alt + shift + f
          dmenu_dir -h 1
        alt + shift + ctrl + f
          dmenu_dir -h 0
        Print
          screenshot -s
        super + Print
          screenshot -u
        super + shift + ctrl + m
          togmouse
        super + shift + {k,j,m,u}
          vol {-i 1%,-d 1%,-m,-u}
        super + shift + {l,h}
          doas ~/bin/brness {-i 1,-d 1,}
        super + shift + {b,t,v,p}
          notify-send {battery `bat -p`%,time `date +%H:%M`,volume `cat /tmp/info/vol/cur`%,`mus pprint`}
        alt + s
          ~/tmp/tst
        super + button2
          plumb
      '';
    };
  };

  security.wrappers = {
    slock.source = "${pkgs.slock.out}/bin/slock";
    doas.source = "${pkgs.doas.out}/bin/doas";
  };
}
