{ config, ... }:
let
  palette = config.colorScheme.palette;
in
{
  styles = ''

* {
	font-family: JetBrainsMono NFP;
	font-weight: bold;
	font-size: 14px;
}


.blank-window {
   background: transparent;  
}

.control-center .notification-row:focus,
.control-center .notification-row:hover {
	opacity: 1;
}

.notification-row {
	outline: none;
	margin: 5px;
	padding: 0;
}

.notification {
	/* background: transparent; */
	margin: 10px;
}

.notification-content {
	background: #${palette.base00};
	padding: 5px;
	border-radius: 0px;
	border: 2px solid #${palette.base03};
	margin: 0;
}

.close-button {
	background: #${palette.base0A};
	color: @cc-bg;
	text-shadow: none;
	padding: 0;
	border-radius: 0px;
	margin-top: 5px;
	margin-right: 5px;
}

.close-button:hover {
	box-shadow: none;
	background: #${palette.base08};
	transition: all .15s ease-in-out;
	border: none
}

.notification-action {
	color: #${palette.base06}; 
	border: 2px solid #${palette.base03};
	border-top: none;
	border-radius: 0px;
	background: #${palette.base01}; 
}

.notification-default-action:hover,
.notification-action:hover {
	color: #${palette.base06}; 
	background: #${palette.base01}; 
}

.summary {
	padding-top: 7px;
	font-size: 13px;
	color: #${palette.base06}; 
}

.time {
	font-size: 11px;
	color: #${palette.base09}; 
	margin-right: 24px
}

.body {
	font-size: 12px;
	color: #${palette.base06}; 
}

.control-center {
	border: 2px solid #${palette.base04}; /* or 3*/
	border-radius: 0px;
}

.control-center-list {
	background: transparent
}

.control-center-list-placeholder {
	opacity: .5
}

.floating-notifications {
	background: transparent
}

.widget-title {
	color: #${palette.base07};
	background: #${palette.base00};
	padding: 5px 10px;
	margin: 10px 10px 5px 10px;
	font-size: 1.5rem;
	border-radius: 5px;
}

.widget-title>button {
	font-size: 1rem;
	color: #${palette.base07};
	background: #${palette.base03};
	text-shadow: none;
	box-shadow: none;
	border-radius: 5px;
}

.widget-title>button:hover {
	background: #${palette.base0A};
	color: #${palette.base01};
}

.widget-dnd {
	background: #${palette.base00}; 
	padding: 5px 10px;
	margin: 5px 10px 10px 10px;
	border-radius: 5px;
	font-size: large;
	color:#${palette.base07} ;
}

.widget-dnd>switch {
	border-radius: 4px;
	background: #${palette.base03};
}

.widget-dnd>switch:checked {
	border: 1px solid #${palette.base0B};
}

.widget-dnd>switch slider {
	background: #${palette.base08} ;
	border-radius: 5px
}

.widget-dnd>switch:checked slider {
	background: #${palette.base0B} ;
	border-radius: 5px
}

.widget-label {
	margin: 10px 10px 5px 10px;
}

.widget-label>label {
	font-size: 1rem;
	color: #${palette.base07};
}


.widget-volume {
	background: #${palette.base00}; 
}

.widget-mpris {
	color: #${palette.base07};
	background: #${palette.base00};
	padding: 5px 10px 0px 0px;
	margin: 5px 10px 5px 10px;
	border-radius: 0px;
}

.widget-mpris > box > button {
	border-radius: 5px;
}

.widget-mpris-player {
	padding: 5px 10px;
	margin: 10px
}

.widget-mpris-title {
	font-weight: 700;
	font-size: 1.25rem
}

.widget-mpris-subtitle {
	font-size: 1.1rem
}

.widget-buttons-grid {
	font-size: x-large;
	padding: 5px;
	margin: 5px 10px 10px 10px;
	border-radius: 5px;
	background: #${palette.base00};
}

.widget-buttons-grid>flowbox>flowboxchild>button {
	margin: 3px;
	background: #${palette.base00};
	border-radius: 5px;
	color: #${palette.base07};
}

.widget-buttons-grid>flowbox>flowboxchild>button:hover {
	background: #${palette.base0A};
	color: #${palette.base01};
}

.widget-menubar>box>.menu-button-bar>button {
	border: none;
	background: transparent
}

.topbar-buttons>button {
	border: none;
	background: transparent
}

'';
}
