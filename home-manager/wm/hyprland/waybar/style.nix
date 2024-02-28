{ config, ... }:
let
  palette = config.colorScheme.palette;
in
{
  styles = ''

* {
	border: none;
	border-radius: 0px;
	font-family: "JetBrainsMono Nerd Font";
	font-weight: bold;
	font-size: 13px;
	min-height: 10px;
}

window#waybar {
	background: rgba(21, 18, 27, 0); /*transparent*/
	/*background: #${palette.base00};*/
}

#cpu,
#memory,
#battery,
#temperature,
#clock,
#workspaces,
#window,
#pulseaudio,
#custom-l_end,
#custom-r_end,
#custom-sl_end,
#custom-sr_end,
#custom-rl_end,
#custom-rr_end,
#custom-notification,
#custom-nix,
#tray {
	background: #${palette.base00};
	color: #${palette.base0D};
	opacity: 1;
	margin: 4px 0px 4px 0px;
	padding-left: 4px;
	padding-right: 4px;
	border: 0px solid #${palette.base0F};
}

#workspaces {
    background: #${palette.base00};
}

#workspaces button {
    box-shadow: none;
	text-shadow: none;
    padding: 0px;
    margin-top: 3px;
    margin-bottom: 3px;
    padding-left: 3px;
    padding-right: 3px;
    color: #${palette.base04};
    animation: gradient_f 20s ease-in infinite;
    transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
}

#workspaces button.active {
    background: #${palette.base03};
    color: #${palette.base07};
    margin-left: 3px;
    padding-left: 12px;
    padding-right: 12px;
    margin-right: 3px;
    animation: gradient_f 20s ease-in infinite;
    transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
}

#workspaces button:hover {
	background: #f5c2e7;
    color: #${palette.base03};
    padding-left: 3px;
    padding-right: 3px;
    animation: gradient_f 20s ease-in infinite;
    transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
}

#workspaces button.focused {
    color: #${palette.base07};
    background: #${palette.base01};
}

#workspaces button.urgent {
    color: #${palette.base07};
    background: #${palette.base08};
}

#clock {
    color: #${palette.base0A};
}

#cpu {
    color: #${palette.base09};
}

#memory {
    color: #${palette.base07};
}

#temperature {
    color: #${palette.base0C};
}

#temperature.critical {
    color: #${palette.base08};
}

#pulseaudio {
    color: #${palette.base0F};
}

#battery {
    color: #${palette.base0D};
}

#custom-notification {
    padding-left: 10px;
    padding-right: 15px;
}

#custom-r_end {
    margin-right: 9px;
    padding-right: 3px;
}

#custom-l_end {
    margin-left: 9px;
    padding-left: 3px;
}

#custom-sr_end {
    margin-right: 9px;
    padding-right: 3px;
}

#custom-sl_end {
    margin-left: 9px;
    padding-left: 3px;
}

#custom-rr_end {
    margin-right: 9px;
    padding-right: 3px;
}

#custom-rl_end {
    margin-left: 9px;
    padding-left: 3px;
}
''
  ;
}
