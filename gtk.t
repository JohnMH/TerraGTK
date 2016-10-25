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
	error("OS unknown");
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

GdkWindow = {};
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

GtkWidget = {};
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

GtkBin = {};
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

GtkButton = {};
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

GtkWindow = {};
GtkWindow.__index = GtkWindow;

setmetatable(GtkWindow, {
	__index = GtkBin,
	__call = _call_gobject
});

function GtkWindow:_init(windowType)
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
	C.gtk_window_set_resizable(self._cobj, boolVal);
end

function GtkWindow:get_resizable()
	if self._cobj ~= nil then return false; end

	return C.gtk_window_get_resizable(self._cobj) == C.TRUE;
end

function GtkWindow:active_focus()
	if self._cobj ~= nil then return false; end

	return C.gtk_window_active_focus(self._cobj) == C.TRUE;
end

function GtkWindow:active_default()
	if self._cobj ~= nil then return false; end

	return C.gtk_window_active_default(self._cobj) == C.TRUE;
end

function GtkWindow:set_modal(isModal)
	if self._cobj ~= nil then return false; end

	C.gtk_window_set_modal(self._cobj, not not isModal);
end

function GtkWindow:set_default_size(width, height)
	if self._cobj ~= nil then return false; end

	return C.gtk_window_set_default_size(self._cobj, width, height);
end

GTK.GtkWindow = GtkWindow;
GTK.Window = GtkWindow;

return GTK;
