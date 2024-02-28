{ pkgs, config, ... }:
let
  Custom = import ./style.nix { inherit config; };
in
{
  home.packages = with pkgs; [
    swaynotificationcenter
  ];

  xdg.configFile."swaync/style.css".text = ''
    	${Custom.styles}
  '';

  xdg.configFile."swaync/config.json".text = ''
    {
        "$schema": "/etc/xdg/swaync/configSchema.json",
        "positionX": "right",
        "positionY": "top",
        "layer": "overlay",
        "control-center-layer": "overlay",
        "cssPriority": "user",
        "control-center-width": 500,
        "control-center-height": 1000,
        "control-center-margin-top": 10,
        "control-center-margin-bottom": 10,
        "control-center-margin-right": 10,
        "control-center-margin-left": 10,
        "notification-icon-size": 64,
        "notification-window-width": 440,
        "timeout": 5,
        "timeout-low": 2,
        "timeout-critical": 0,
        "fit-to-screen": false,
        "keyboard-shortcuts": true,
        "image-visibility": "when-available",
        "transition-time": 200,
        "hide-on-clear": true,
        "hide-on-action": true,
        "script-fail-notify": true,
        "widgets": [
            "title",
            "dnd",
            "notifications",
            "mpris",
            "volume"
        ],
        "widget-config": {
            "title": {
                "text": "Notification Center",
                "clear-all-button": true,
                "button-text": "󰆴 Clear All"
            },
            "dnd": {
                "text": "Do Not Disturb"
            },
            "label": {
                "max-lines": 1,
                "text": "Notification Center"
            },
            "mpris": {
                "image-size": 96,
                "image-radius": 7
            },
            "volume": {
                "label": "󰕾",
                "show-per-app": true
            }
        }
    }
  '';
}
