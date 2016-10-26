--[[
Copyright (C) 2016 John M. Harris, Jr.

This program is free software: you can redistribute it and/or modify  
it under the terms of the GNU Lesser General Public License as   
published by the Free Software Foundation, version 3.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
Lesser General Lesser Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
]]

local ffi = require("ffi");

local plat;

if ffi.os == "Linux" then
	plat = require("./platform/linux");
else
	error("OS unknown: " .. ffi.os);
end
--TODO: Mac OS X, Windows

local GTK = {};

local C = terralib.includecstring([[
#include "stdlib.h"
#include "stdio.h"

#include <gtk/gtk.h>
]]);

GTK.C = C;

--Useful when running from the Terra REPL or running a script
function GTK.loadlib()
	terralib.linklibrary(plat.lib_path);
end

terra _gtk_init(argc : int, argv : &rawstring)
	C.gtk_init(&argc, &argv);
end

function GTK.init(argc, argv)
	if type(argc) == "nil" then
		_gtk_init(0, nil);
	else
		_gtk_init(argc, argv);
	end
end

function GTK.main()
	C.gtk_main();
end

function GTK.main_quit()
	C.gtk_main_quit();
end

local GObject = {};
GObject.__index = GObject;

local function _call_gobject(cls, ...)
	local self = setmetatable({}, cls);
	self:_init(...);
	return self;
end

setmetatable(GObject, {
	__call = _call_gobject
});

function GObject:_init()
	self._cobj = nil;
end

function GObject:ref()
	if self._cobj == nil then return; end
	
	C.g_object_ref(self._cobj);
end

function GObject:unref()
	if self._cobj == nil then return; end
	
	C.g_object_unref(self._cobj);
end

function GObject:connect(sig, cb, data, flags)
	if self._cobj == nil then return; end
	
	return C.g_signal_connect_data(self._cobj, sig, terralib.cast(C.GCallback, cb), data, nil, flags or 0);
end

GTK.GObject = GObject;

--Gdk
local GdkGravity = {};
GdkGravity.NorthWest = C.GDK_GRAVITY_NORTH_WEST;
GdkGravity.North = C.GDK_GRAVITY_NORTH;
GdkGravity.NorthEast = C.GDK_GRAVITY_NORTH_EAST;
GdkGravity.West = C.GDK_GRAVITY_WEST;
GdkGravity.Center = C.GDK_GRAVITY_CENTER;
GdkGravity.East = C.GDK_GRAVITY_EAST;
GdkGravity.SouthWest = C.GDK_GRAVITY_SOUTH_WEST;
GdkGravity.South = C.GDK_GRAVITY_SOUTH;
GdkGravity.SouthEast = C.GDK_GRAVITY_SOUTH_EAST;
GdkGravity.Static = C.GDK_GRAVITY_STATIC;

GTK.GdkGravity = GdkGravity;

local GdkWindow = {};
GdkWindow.__index = GdkWindow;

setmetatable(GdkWindow, {
	__index = GObject,
	__call = _call_gobject
});

function GdkWindow:_init(cobj)
	self._cobj = cobj;
	return self;
end

GTK.GdkWindow = GdkWindow;

local GdkScreen = {};
GdkScreen.__index = GdkScreen;

setmetatable(GdkScreen, {
	__index = GObject,
	__call = _call_gobject
});

function GdkScreen:_init(cobj)
	self._cobj = cobj;
	return self;
end

GTK.GdkScreen = GdkScreen;

--Gtk
local GtkWidget = {};
GtkWidget.__index = GtkWidget;

setmetatable(GtkWidget, {
	__index = GObject,
	__call = _call_gobject
});

function GtkWidget:_init(cobj)
	self._cobj = cobj;
	return self;
end

function GtkWidget:destroy()
	if self._cobj == nil then return; end

	C.gtk_widget_destroy(self._cobj);
end

function GtkWidget:in_destruction()
	if self._cobj == nil then return; end

	return C.gtk_widget_in_destruction(self._cobj) == C.TRUE;
end

function GtkWidget:unparent()
	if self._cobj == nil then return; end

	C.gtk_widget_unparent(self._cobj);
end

function GtkWidget:show()
	if self._cobj == nil then return; end

	C.gtk_widget_show(self._cobj);
end

function GtkWidget:show_now()
	if self._cobj == nil then return; end

	C.gtk_widget_show_now(self._cobj);
end

function GtkWidget:hide()
	if self._cobj == nil then return; end

	C.gtk_widget_hide(self._cobj);
end

function GtkWidget:show_all()
	if self._cobj == nil then return; end

	C.gtk_widget_show_all(self._cobj);
end

function GtkWidget:map()
	if self._cobj == nil then return; end

	C.gtk_widget_map(self._cobj);
end

function GtkWidget:unmap()
	if self._cobj == nil then return; end

	C.gtk_widget_unmap(self._cobj);
end

GTK.GtkWidget = GtkWidget;
GTK.Widget = GtkWidget;

GtkContainer = {};
GtkContainer.__index = GtkContainer;

setmetatable(GtkContainer, {
	__index = GtkWidget,
	__call = _call_gobject
});

function GtkContainer:_init()
	error("Do not create a GtkContainer directly.");
end

terra GTK_CONTAINER(cont : &C.GtkWidget) : &C.GtkContainer
	return [&C.GtkContainer](cont);
end
		
function GtkContainer:add(widget)
	if self._cobj == nil then return; end
	C.gtk_container_add(GTK_CONTAINER(self._cobj), widget._cobj);
end

GTK.GtkContainer = GtkContainer;
GTK.Container = GtkContainer;

local GtkBin = {};
GtkBin.__index = GtkBin;

setmetatable(GtkBin, {
	__index = GtkContainer,
	__call = _call_gobject
});

function GtkBin:_init()
	error("Do not create a GtkBin directly.");
end

GTK.GtkBin = GtkBin;
GTK.Bin = GtkBin;

local ReliefStyle = {};
ReliefStyle.Normal = C.GTK_RELIEF_NORMAL;
ReliefStyle.None = C.GTK_RELIEF_NONE;

GTK.ReliefStyle = ReliefStyle;

local PositionType = {};
PositionType.Left = C.GTK_POS_LEFT;
PositionType.Right = C.GTK_POS_RIGHT;
PositionType.Top = C.GTK_POS_TOP;
PositionType.Bottom = C.GTK_POS_BOTTOM;

GTK.PositionType = PositionType;

local GtkButton = {};
GtkButton.__index = GtkButton;

setmetatable(GtkButton, {
	__index = GtkBin,
	__call = _call_gobject
});

function GtkButton:_init(cobj)
	self._cobj = cobj;

	return self;
end

function GtkButton.new()
	local cobj = C.gtk_button_new();
	return GtkButton(cobj);
end

function GtkButton.new_with_label(label)
	local cobj = C.gtk_button_new_with_label(label);
	return GtkButton(cobj);
end

function GtkButton.new_with_mnemonic(label)
	local cobj = C.gtk_button_new_with_mnemonic(label);
	return GtkButton(cobj);
end

function GtkButton.new_from_icon_name(icon_name, size)
	local cobj = C.gtk_button_new_from_icon_name(icon_name, size);
	return GtkButton(cobj);
end

terra GTK_BUTTON(win : &C.GtkWidget)
	return [&C.GtkButton](win);
end

function GtkButton:set_relief(relief)
	if self._cobj == nil then return; end
	
	C.gtk_button_set_relief(GTK_BUTTON(self._cobj), relief);
end

function GtkButton:get_relief()
	if self._cobj == nil then return; end
	
	return C.gtk_button_get_relief(GTK_BUTTON(self._cobj));
end

function GtkButton:set_label(label)
	if self._cobj == nil then return; end
	
	C.gtk_button_set_label(GTK_BUTTON(self._cobj), label);
end

function GtkButton:get_label()
	if self._cobj == nil then return; end
	
	return C.gtk_button_get_label(GTK_BUTTON(self._cobj));
end

function GtkButton:set_use_underline(useUnderline)
	if self._cobj == nil then return; end
	
	C.gtk_button_set_use_underline(GTK_BUTTON(self._cobj), useUnderline);
end

function GtkButton:get_use_underline()
	if self._cobj == nil then return; end
	
	return C.gtk_button_get_use_underline(GTK_BUTTON(self._cobj));
end

function GtkButton:set_image(img)
	if self._cobj == nil then return; end
	if not img or img._cobj == nil then return; end
	
	C.gtk_button_set_image(GTK_BUTTON(self._cobj), img._cobj);
end

function GtkButton:get_image()
	if self._cobj == nil then return; end
	
	local imgTemp = C.gtk_button_get_image(GTK_BUTTON(self._cobj));
	if imgTemp == nil then
		return nil;
	else
		return GtkWidget(imgTemp);
	end
end

function GtkButton:set_image_position(pos)
	if self._cobj == nil then return; end
	
	C.gtk_button_set_image_position(GTK_BUTTON(self._cobj), pos);
end

function GtkButton:get_image_position()
	if self._cobj == nil then return; end
	
	return C.gtk_button_get_image_position(GTK_BUTTON(self._cobj));
end

function GtkButton:set_always_show_image(alwaysShow)
	if self._cobj == nil then return; end
	
	C.gtk_button_set_always_show_image(GTK_BUTTON(self._cobj), alwaysShow);
end

function GtkButton:get_image_position()
	if self._cobj == nil then return; end
	
	return C.gtk_button_get_always_show_image(GTK_BUTTON(self._cobj)) == C.TRUE;
end

function GtkButton:get_event_window()
	if self._cobj == nil then return; end

	local winTemp = C.gtk_button_get_event_window(GTK_BUTTON(self._cobj));
	if winTemp == nil then
		return nil;
	else
		return GdkWindow(winTemp);
	end
end

GTK.GtkButton = GtkButton;
GTK.Button = GtkButton;

local WindowType = {};
WindowType.TopLevel = C.GTK_WINDOW_TOPLEVEL;
WindowType.Popup = C.GTK_WINDOW_POPUP;

GTK.WindowType = WindowType;

local WindowPosition = {};
WindowPosition.None = C.GTK_WIN_POS_NONE;
WindowPosition.Center = C.GTK_WIN_POS_CENTER;
WindowPosition.Mouse = C.GTK_WIN_POS_MOUSE;
WindowPosition.CenterAlways = C.GTK_WIN_POS_CENTER_ALWAYS;
WindowPosition.CenterOnParent = C.GTK_WIN_POS_CENTER_ON_PARENT;

GTK.WindowPosition = WindowPosition;

local GtkWindow = {};
GtkWindow.__index = GtkWindow;

setmetatable(GtkWindow, {
	__index = GtkBin,
	__call = _call_gobject
});

function GtkWindow:_init(windowType)
	if type(windowType) == "cdata" then
		self._cobj = windowType;
		return self;
	end
	
	local useWinType;
	if windowType ~= WindowType.TopLevel and windowType ~= WindowType.Popup then
		useWinType = 0;
	else
		useWinType = windowType;
	end

	self._cobj = C.gtk_window_new(useWinType);
	return self;
end

terra GTK_WINDOW(win : &C.GtkWidget)
	return [&C.GtkWindow](win);
end

function GtkWindow:set_title(title)
	if self._cobj == nil then return; end
	
	local titleToSet = title;
	if type(title) ~= "string" then
		titleToSet = tostring(title);
	end
	C.gtk_window_set_title(GTK_WINDOW(self._cobj), titleToSet);
end

function GtkWindow:set_resizable(resizable)
	if self._cobj ~= nil then return; end
	
	local boolVal = not not resizable;
	C.gtk_window_set_resizable(GTK_WINDOW(self._cobj), boolVal);
end

function GtkWindow:get_resizable()
	if self._cobj ~= nil then return false; end

	return C.gtk_window_get_resizable(GTK_WINDOW(self._cobj)) == C.TRUE;
end

function GtkWindow:active_focus()
	if self._cobj ~= nil then return false; end

	return C.gtk_window_active_focus(GTK_WINDOW(self._cobj)) == C.TRUE;
end

function GtkWindow:active_default()
	if self._cobj ~= nil then return false; end

	return C.gtk_window_active_default(GTK_WINDOW(self._cobj)) == C.TRUE;
end

function GtkWindow:set_modal(isModal)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_modal(GTK_WINDOW(self._cobj), not not isModal);
end

function GtkWindow:set_default_size(width, height)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_default_size(GTK_WINDOW(self._cobj), width, height);
end

function GtkWindow:set_gravity(gravity)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_gravity(GTK_WINDOW(self._cobj), gravity);
end

function GtkWindow:get_gravity()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_gravity(GTK_WINDOW(self._cobj));
end

function GtkWindow:set_position(pos)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_position(GTK_WINDOW(self._cobj), pos);
end

function GtkWindow:set_transient_for(otherWindow)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_transient_for(GTK_WINDOW(self._cobj), GTK_WINDOW(otherWindow));
end

function GtkWindow:set_attached_to(widget)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_attached_to(GTK_WINDOW(self._cobj), widget);
end

function GtkWindow:set_destroy_with_parent(doDestroy)
	if self._cobj ~= nil then return; end

	local boolVal = not not doDestroy;
	C.gtk_window_set_destroy_with_parent(GTK_WINDOW(self._cobj), boolVal);
end

function GtkWindow:set_hide_titlebar_when_maximized(doHide)
	if self._cobj ~= nil then return; end

	local boolVal = not not doHide;
	C.gtk_window_set_hide_titlebar_when_maximized(GTK_WINDOW(self._cobj), boolVal);
end

function GtkWindow:set_screen(screen)
	if self._cobj ~= nil then return; end
	if not screen or screen._cobj == nil then return; end

	C.gtk_window_set_screen(GTK_WINDOW(self._cobj), screen._cobj);
end

function GtkWindow:get_screen()
	if self._cobj ~= nil then return; end

	local tmpScreen = C.gtk_window_get_screen(GTK_WINDOW(self._cobj));
	if tmpScreen == nil then
		return nil;
	else
		return GdkScreen(tmpScreen);
	end
end

function GtkWindow:is_active()
	if self._cobj ~= nil then return; end

	return C.gtk_window_is_active(GTK_WINDOW(self._cobj)) == C.TRUE;
end

function GtkWindow:is_maximized()
	if self._cobj ~= nil then return; end

	return C.gtk_window_is_maximized(GTK_WINDOW(self._cobj)) == C.TRUE;
end

function GtkWindow:has_toplevel_focus()
	if self._cobj ~= nil then return; end

	return C.gtk_window_has_toplevel_focus(GTK_WINDOW(self._cobj)) == C.TRUE;
end

function GtkWindow:close()
	if self._cobj ~= nil then return; end

	C.gtk_window_close(GTK_WINDOW(self._cobj));
end

function GtkWindow:iconify()
	if self._cobj ~= nil then return; end

	C.gtk_window_iconify(GTK_WINDOW(self._cobj));
end

function GtkWindow:deiconify()
	if self._cobj ~= nil then return; end

	C.gtk_window_deiconify(GTK_WINDOW(self._cobj));
end

function GtkWindow:stick()
	if self._cobj ~= nil then return; end

	C.gtk_window_stick(GTK_WINDOW(self._cobj));
end

function GtkWindow:unstick()
	if self._cobj ~= nil then return; end

	C.gtk_window_unstick(GTK_WINDOW(self._cobj));
end

function GtkWindow:maximize()
	if self._cobj ~= nil then return; end

	C.gtk_window_maximize(GTK_WINDOW(self._cobj));
end

function GtkWindow:unmaximize()
	if self._cobj ~= nil then return; end

	C.gtk_window_unmaximize(GTK_WINDOW(self._cobj));
end

function GtkWindow:fullscreen()
	if self._cobj ~= nil then return; end

	C.gtk_window_fullscreen(GTK_WINDOW(self._cobj));
end

function GtkWindow:unfullscreen()
	if self._cobj ~= nil then return; end

	C.gtk_window_unfullscreen(GTK_WINDOW(self._cobj));
end

function GtkWindow:set_keep_above(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_keep_above(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_keep_below(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_keep_below(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_decorated(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_decorated(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_deletable(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_deletable(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_skip_taskbar_hint(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_skip_taskbar_hint(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_urgency_hint(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_urgency_hint(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_accept_focus(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_accept_focus(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:set_focus_on_map(setting)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_focus_on_map(GTK_WINDOW(self._cobj), not not setting);
end

function GtkWindow:get_decorated()
	if self._cobj ~= nil then return; end

	return not not C.gtk_window_get_decorated(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_deletable()
	if self._cobj ~= nil then return; end

	return not not C.gtk_window_get_deletable(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_default_icon_name()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_default_icon_name(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_destroy_with_parent()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_destroy_with_parent(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_default_icon_name()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_default_icon_name(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_hide_titlebar_when_maximized()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_hide_titlebar_when_maximized(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_icon_name()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_icon_name(GTK_WINDOW(self._cobj));
end

function GtkWindow:set_icon_name(name)
	if self._cobj ~= nil then return; end

	C.gtk_window_set_icon_name(GTK_WINDOW(self._cobj), name);
end

function GtkWindow:get_modal()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_modal(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_title()
	if self._cobj ~= nil then return; end

	return C.gtk_window_get_title(GTK_WINDOW(self._cobj));
end

function GtkWindow:get_transient_for()
	if self._cobj ~= nil then return; end

	local tmpTransient = C.gtk_window_get_transient_for(GTK_WINDOW(self._cobj));

	if tmpTransient == nil then
		return nil;
	else
		return tmpTransient;
	end
end

GTK.GtkWindow = GtkWindow;
GTK.Window = GtkWindow;

return GTK;
