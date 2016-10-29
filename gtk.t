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
elseif ffi.os == "OSX" then
	plat = require("./platform/osx");
else
	error("OS unknown: " .. ffi.os);
end
--TODO: Windows

local GTK = {};

local C = terralib.includecstring([[
#include "stdlib.h"
#include "stdio.h"

#include <gtk/gtk.h>
]]);

GTK.C = C;

--"Macros"
function G_OBJECT(obj)
	return terralib.cast(&C.GObject, obj);
end

function G_APPLICATION(obj)
	return terralib.cast(&C.GApplication, obj);
end

function GTK_APPLICATION(obj)
	return terralib.cast(&C.GtkApplication, obj);
end

function GTK_WIDGET(obj)
	return terralib.cast(&C.GtkWidget, obj);
end

function GTK_WINDOW(obj)
	return terralib.cast(&C.GtkWindow, obj);
end

function GTK_CONTAINER(obj)
	return terralib.cast(&C.GtkContainer, obj);
end

function GTK_BUTTON(obj)
	return terralib.cast(&C.GtkButton, obj);
end

function GTK_BUTTONBOX(obj)
	return terralib.cast(&C.GtkButtonBox, obj);
end

function GTK_BOX(obj)
	return terralib.cast(&C.GtkBox, obj);
end

function G_MENU_MODEL(obj)
	return terralib.cast(&C.GMenuModel, obj);
end

function GTK_MENU_ITEM(obj)
	return terralib.cast(&C.GtkMenuItem, obj);
end

function GTK_MENU(obj)
	return terralib.cast(&C.GtkMenu, obj);
end

function GTK_MENU_SHELL(obj)
	return terralib.cast(&C.GtkMenuShell, obj);
end

function GTK_BUILDER(obj)
	return terralib.cast(&C.GtkBuilder, obj);
end

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

local ApplicationFlags = {};
ApplicationFlags.None = C.G_APPLICATION_FLAGS_NONE;
ApplicationFlags.Service = C.G_APPLICATION_IS_SERVICE;
ApplicationFlags.Launcher = C.G_APPLICATION_IS_LAUNCHER;
ApplicationFlags.HandlesOpen = C.G_APPLICATION_HANDLES_OPEN;
ApplicationFlags.HandlesCommandLine = C.G_APPLICATION_HANDLES_COMMAND_LINE;
ApplicationFlags.SendEnvironment = C.G_APPLICATION_SEND_ENVIRONMENT;
ApplicationFlags.NonUnique = C.G_APPLICATION_NON_UNIQUE;
ApplicationFlags.CanOverrideAppId = C.G_APPLICATION_CAN_OVERRIDE_APP_ID;

GTK.ApplicationFlags = ApplicationFlags;

local GMenuModel = {};
GMenuModel.__index = GMenuModel;

setmetatable(GMenuModel, {
	__index = GObject,
	__call = _call_gobject
});

function GMenuModel:_init(un)
	if type(un) == "cdata" then
		self._cobj = un;
		return;
	end
end

function GMenuModel:is_mutable()
	if self._cobj == nil then return; end

	return not not C.g_menu_model_is_mutable(G_MENU_MODEL(self._cobj));
end

function GMenuModel:get_n_items()
	if self._cobj == nil then return; end

	return C.g_menu_model_get_n_items(G_MENU_MODEL(self._cobj));
end

function GMenuModel:get_item_link(idx, link)
	if self._cobj == nil then return; end

	local tmpMenu = g_menu_model_get_n_items(G_MENU_MODEL(self._cobj), idx, link);

	if tmpMenu == nil then
		return nil;
	else
		return GMenuModel(tmpMenu);
	end
end

GTK.MenuModel = GMenuModel;

local GApplication = {};
GApplication.__index = GApplication;

setmetatable(GApplication, {
	__index = GObject,
	__call = _call_gobject
});

function GApplication:_init(un)
	if type(un) == "cdata" then
		self._cobj = un;
		return;
	end
end

function GApplication.get_default()
	local tmpApp = C.g_application_get_default();
	if tmpApp == nil then
		return nil;
	else
		return GApplication(tmpApp);
	end
end

function GApplication:get_application_id()
	if self._cobj == nil then return; end

	return C.g_application_get_application_id(G_APPLICATION(self._cobj));
end

function GApplication:set_application_id(app_id)
	if self._cobj == nil then return; end

	C.g_application_set_application_id(G_APPLICATION(self._cobj), app_id);
end

function GApplication:get_is_registered()
	if self._cobj == nil then return; end

	return not not C.g_application_get_is_registered(G_APPLICATION(self._cobj));
end

function GApplication:get_is_remote()
	if self._cobj == nil then return; end

	return not not C.g_application_get_is_remote(G_APPLICATION(self._cobj));
end

function GApplication:quit()
	if self._cobj == nil then return; end

	C.g_application_quit(G_APPLICATION(self._cobj));
end

function GApplication:activate()
	if self._cobj == nil then return; end

	C.g_application_activate(G_APPLICATION(self._cobj));
end

terra _g_application_run(app : &C.GApplication, argc : int, argv : &rawstring)
	C.g_application_run(app, argc, argv);
end

function GApplication:run(argc, argv)
	if self._cobj == nil then return; end

	if type(argc) == "nil" then
		_g_application_run(G_APPLICATION(self._cobj), 0, nil);
	else
		_g_application_run(G_APPLICATION(self._cobj), argc, argv);
	end
end

function GApplication:set_default()
	if self._cobj == nil then return; end

	C.g_application_set_default(G_APPLICATION(self._cobj));
end

function GApplication:mark_busy()
	if self._cobj == nil then return; end

	C.g_application_mark_busy(G_APPLICATION(self._cobj));
end

function GApplication:unmark_busy()
	if self._cobj == nil then return; end

	C.g_application_unmark_busy(G_APPLICATION(self._cobj));
end

function GApplication:get_is_busy()
	if self._cobj == nil then return; end

	return not not C.g_application_get_is_busy(G_APPLICATION(self._cobj));
end

GTK.GApplication = GApplication;

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
end

GTK.GdkScreen = GdkScreen;

--Gtk
local GtkWindow;

local GtkApplication = {};
GtkApplication.__index = GtkApplication;

setmetatable(GtkApplication, {
	__index = GApplication,
	__call = _call_gobject
});

function GtkApplication:_init(app_id, flags)
	if type(app_id) == "cdata" then
		self._cobj = app_id;
		return;
	end
	
	self._cobj = C.gtk_application_new(app_id, flags or 0);
end

function GtkApplication.get_default()
	local tmpApp = C.g_application_get_default();
	if tmpApp == nil then
		return nil;
	else
		return GtkApplication(tmpApp);
	end
end

function GtkApplication:add_window(win)
	if self._cobj == nil then return; end

	C.gtk_application_add_window(GTK_APPLICATION(self._cobj), GTK_WINDOW(win));
end

function GtkApplication:remove_window(win)
	if self._cobj == nil then return; end

	C.gtk_application_remove_window(GTK_APPLICATION(self._cobj), GTK_WINDOW(win));
end

function GtkApplication:get_window_by_id(id)
	if self._cobj == nil then return; end

	local tmpWin = C.gtk_application_get_window_by_id(GTK_APPLICATION(self._cobj), id);

	if tmpWin == nil then
		return nil;
	else
		return GtkWindow(tmpWin);
	end
end

function GtkApplication:get_active_window()
	if self._cobj == nil then return; end

	local tmpWin = C.gtk_application_get_active_window(GTK_APPLICATION(self._cobj));

	if tmpWin == nil then
		return nil;
	else
		return GtkWindow(tmpWin);
	end
end

function GtkApplication:prefers_app_menu()
	if self._cobj == nil then return; end

	return not not C.gtk_application_prefers_app_menu(GTK_APPLICATION(self._cobj));
end

function GtkApplication:get_app_menu()
	if self._cobj == nil then return; end
	
	local tmpMenu = C.gtk_application_get_app_menu(GTK_APPLICATION(self._cobj));

	if tmpMenu == nil then
		return nil;
	else
		return GMenuModel(app_menu);
	end
end

function GtkApplication:set_app_menu(app_menu)
	if self._cobj == nil then return; end

	local toCallWith;
	
	if app_menu == nil then
		toCallWith = nil;
	else
		toCallWith = G_MENU_MODEL(app_menu);
	end
	
	C.gtk_application_set_app_menu(GTK_APPLICATION(self._cobj), toCallWith);
end

function GtkApplication:get_menubar()
	if self._cobj == nil then return; end
	
	local tmpMenu = C.gtk_application_get_menubar(GTK_APPLICATION(self._cobj));

	if tmpMenu == nil then
		return nil;
	else
		return GMenuModel(app_menu);
	end
end

function GtkApplication:set_menubar(app_menu)
	if self._cobj == nil then return; end

	local toCallWith;
	
	if app_menu == nil then
		toCallWith = nil;
	else
		toCallWith = G_MENU_MODEL(app_menu);
	end
	
	C.gtk_application_set_menubar(GTK_APPLICATION(self._cobj), toCallWith);
end

function GtkApplication:window_new()
	if self._cobj == nil then return; end

	local tmpWin = C.gtk_application_window_new(GTK_APPLICATION(self._cobj));

	if tmpWin == nil then
		return nil;
	else
		return GtkWindow(tmpWin);
	end
end

GTK.GtkApplication = GtkApplication;

local GtkWidget = {};
GtkWidget.__index = GtkWidget;

setmetatable(GtkWidget, {
	__index = GObject,
	__call = _call_gobject
});

function GtkWidget:_init(cobj)
	self._cobj = cobj;
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
		
function GtkContainer:add(widget)
	if self._cobj == nil then return; end
	C.gtk_container_add(GTK_CONTAINER(self._cobj), widget._cobj);
end

GTK.GtkContainer = GtkContainer;
GTK.Container = GtkContainer;

GtkBox = {};
GtkBox.__index = GtkBox;

setmetatable(GtkBox, {
	__index = GtkContainer,
	__call = _call_gobject
});

function GtkBox:_init(orientation, spacing)
	if type(orientation) == "cdata" then
		self._cobj = orientation;
		return;
	end

	self._cobj = C.gtk_box_new(orientation, spacing);
end
		
function GtkBox:pack_start(child, expand, fill, padding)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end

	C.gtk_box_pack_start(GTK_BOX(self._cobj), GTK_WIDGET(child._cobj), expand, fill, padding);
end

function GtkBox:pack_end(child, expand, fill, padding)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end

	C.gtk_box_pack_end(GTK_BOX(child._cobj), expand, fill, padding);
end

function GtkBox:get_homogeneous()
	if self._cobj == nil then return; end

	return not not C.gtk_box_get_homogeneous(GTK_BOX(child._cobj));
end

function GtkBox:set_homogeneous(homogeneous)
	if self._cobj == nil then return; end

	C.gtk_box_set_homogeneous(GTK_BOX(child._cobj), homogeneous);
end

function GtkBox:get_spacing()
	if self._cobj == nil then return; end

	return C.gtk_box_get_spacing(GTK_BOX(child._cobj));
end

function GtkBox:set_spacing(spacing)
	if self._cobj == nil then return; end

	C.gtk_box_set_spacing(GTK_BOX(child._cobj), spacing);
end

function GtkBox:reorder_child(child, pos)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end

	C.gtk_box_reorder_child(GTK_BOX(child._cobj), pos);
end

GTK.GtkBox = GtkBox;
GTK.Box = GtkBox;

GtkMenuShell = {};
GtkMenuShell.__index = GtkMenuShell;

setmetatable(GtkMenuShell, {
	__index = GtkContainer,
	__call = _call_gobject
});

function GtkMenuShell:_init()
	error("Do not create a GtkMenuShell directly.");
end

function GtkMenuShell:prepend(child)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end
	
	C.gtk_menu_shell_prepend(GTK_MENU_SHELL(self._cobj), GTK_WIDGET(child._cobj));
end

function GtkMenuShell:append(child)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end
	
	C.gtk_menu_shell_append(GTK_MENU_SHELL(self._cobj), GTK_WIDGET(child._cobj));
end

function GtkMenuShell:insert(child, pos)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end
	
	C.gtk_menu_shell_insert(GTK_MENU_SHELL(self._cobj), GTK_WIDGET(child._cobj), pos);
end

function GtkMenuShell:deactivate()
	if self._cobj == nil then return; end
	
	C.gtk_menu_shell_deactivate(GTK_MENU_SHELL(self._cobj));
end

function GtkMenuShell:select_item(child)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end
	
	C.gtk_menu_shell_select_item(GTK_MENU_SHELL(self._cobj), GTK_WIDGET(child._cobj));
end

function GtkMenuShell:select_first(search_sensitive)
	if self._cobj == nil then return; end
	
	C.gtk_menu_shell_select_first(GTK_MENU_SHELL(self._cobj), search_sensitive);
end

function GtkMenuShell:deselect()
	if self._cobj == nil then return; end
	
	C.gtk_menu_shell_deselect(GTK_MENU_SHELL(self._cobj));
end

function GtkMenuShell:activate_item(child, force_deactivate)
	if self._cobj == nil then return; end
	if not child or child._cobj == nil then return; end
	
	C.gtk_menu_shell_activate_item(GTK_MENU_SHELL(self._cobj), GTK_WIDGET(child._cobj), force_deactivate);
end

function GtkMenuShell:cancel()
	if self._cobj == nil then return; end
	
	C.gtk_menu_shell_cancel(GTK_MENU_SHELL(self._cobj));
end

function GtkMenuShell:set_take_focus(take_focus)
	if self._cobj == nil then return; end
	
	C.gtk_menu_shell_set_take_focus(GTK_MENU_SHELL(self._cobj), take_focus);
end

function GtkMenuShell:get_take_focus()
	if self._cobj == nil then return; end
	
	return not not C.gtk_menu_shell_get_take_focus(GTK_MENU_SHELL(self._cobj));
end

function GtkMenuShell:get_selected_item()
	if self._cobj == nil then return; end
	
	local tmpWidget = C.gtk_menu_shell_get_selected_item(GTK_MENU_SHELL(self._cobj));

	if tmpWidget == nil then
		return nil;
	else
		return GtkWidget(tmpWidget);
	end
end

function GtkMenuShell:get_parent_shell()
	if self._cobj == nil then return; end
	
	local tmpWidget = C.gtk_menu_shell_get_parent_shell(GTK_MENU_SHELL(self._cobj));

	if tmpWidget == nil then
		return nil;
	else
		return GtkWidget(tmpWidget);
	end
end

GTK.GtkMenuShell = GtkMenuShell;
GTK.MenuShell = GtkMenuShell;

local GtkMenu = {};
GtkMenu.__index = GtkMenu;

setmetatable(GtkMenu, {
	__index = GtkMenuShell,
	__call = _call_gobject
});

function GtkMenu:_init(un)
	if type(un) == "cdata" then
		self._cobj = un;
		return;
	end

	self._cobj = C.gtk_menu_new();
end

GTK.Menu = GtkMenu;
GTK.GtkMenu = GtkMenu;

GtkMenuBar = {};
GtkMenuBar.__index = GtkMenuBar;

setmetatable(GtkMenuBar, {
	__index = GtkMenuShell,
	__call = _call_gobject
});

function GtkMenuBar:_init(item)
	if type(item) == "cdata" then
		self._cobj = item;
		return;
	end
	
	self._cobj = C.gtk_menu_bar_new();
end

GTK.GtkMenuBar = GtkMenuBar;
GTK.MenuBar = GtkMenuBar;

GtkMenu = {};
GtkMenu.__index = GtkMenu;

setmetatable(GtkMenu, {
	__index = GtkMenuShell,
	__call = _call_gobject
});

function GtkMenu:_init(item)
	if type(item) == "cdata" then
		self._cobj = item;
		return;
	end
	
	self._cobj = C.gtk_menu_new();
end

GTK.GtkMenu = GtkMenu;
GTK.Menu = GtkMenu;

function GtkMenuShell:_init()
	error("Do not create a GtkMenuShell directly.");
end

Orientation = {};
Orientation.Horizontal = C.GTK_ORIENTATION_HORIZONTAL;
Orientation.Veritical = C.GTK_ORIENTATION_VERTICAL;

GTK.Orientation = Orientation;

GtkButtonBox = {};
GtkButtonBox.__index = GtkButtonBox;

setmetatable(GtkButtonBox, {
	__index = GtkContainer,
	__call = _call_gobject
});

function GtkButtonBox:_init(orientation)
	if type(orientation) == "cdata" then
		self._cobj = orientation;
		return;
	end

	self._cobj = C.gtk_button_box_new(orientation);
end

GTK.GtkButtonBox = GtkButtonBox;
GTK.ButtonBox = GtkButtonBox;

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

local GtkMenuItem = {};
GtkMenuItem.__index = GtkMenuItem;

setmetatable(GtkMenuItem, {
	__index = GtkBin,
	__call = _call_gobject
});

function GtkMenuItem:_init(label, detailed_action)
	if type(label) == "cdata" then
		self._cobj = label;
		return;
	end

	self._cobj = C.gtk_menu_item_new(label, detailed_action);
end

function GtkMenuItem.new_with_label(label)
	local tmpMenuItem = C.gtk_menu_item_new_with_label(label);

	if tmpMenuItem == nil then
		return nil;
	else
		return GtkMenuItem(tmpMenuItem);
	end
end

function GtkMenuItem.new_with_mnemonic(label)
	local tmpMenuItem = C.gtk_menu_item_new_with_mnemonic(label);

	if tmpMenuItem == nil then
		return nil;
	else
		return GtkMenuItem(tmpMenuItem);
	end
end

function GtkMenuItem:set_label(label)
	if self._cobj == nil then return; end

	C.gtk_menu_item_set_label(G_MENU_ITEM(self._cobj), label);
end

function GtkMenuItem:get_label()
	if self._cobj == nil then return; end

	return C.gtk_menu_item_get_label(G_MENU_ITEM(self._cobj));
end

function GtkMenuItem:set_use_underline(setting)
	if self._cobj == nil then return; end

	C.gtk_menu_item_set_use_underline(G_MENU_ITEM(self._cobj), setting);
end

function GtkMenuItem:get_use_underline()
	if self._cobj == nil then return; end

	return not not C.gtk_menu_item_get_use_underline(G_MENU_ITEM(self._cobj));
end

function GtkMenuItem:set_submenu(submenu)
	if self._cobj == nil then return; end
	if not submenu or submenu._cobj == nil then return; end

	C.gtk_menu_item_set_submenu(GTK_MENU_ITEM(self._cobj), GTK_WIDGET(submenu._cobj));
end

function GtkMenuItem:get_submenu()
	if self._cobj == nil then return; end

	local tmpWidget = C.gtk_menu_item_get_submenu(GTK_MENU_ITEM(self._cobj));
	if tmpWidget == nil then
		return nil;
	else
		return GtkWidget(tmpWidget);
	end
end

GTK.MenuItem = GtkMenuItem;
GTK.GtkMenuItem = GtkMenuItem;

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

GtkWindow = {};
GtkWindow.__index = GtkWindow;

setmetatable(GtkWindow, {
	__index = GtkBin,
	__call = _call_gobject
});

function GtkWindow:_init(windowType)
	if type(windowType) == "cdata" then
		self._cobj = windowType;
		return;
	end
	
	local useWinType;
	if windowType ~= WindowType.TopLevel and windowType ~= WindowType.Popup then
		useWinType = 0;
	else
		useWinType = windowType;
	end

	self._cobj = C.gtk_window_new(useWinType);
	return;
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

--BUILDER

local GtkBuilder = {};
GtkBuilder.__index = GtkBuilder;

setmetatable(GtkBuilder, {
	__index = GObject,
	__call = _call_gobject
});

function GtkBuilder:_init(un)
	if type(un) == "cdata" then
		self._cobj = un;
		return;
	end

	self._cobj = C.gtk_builder_new();
end

function GtkBuilder.new_from_file(file)
	local tmpBuilder = C.gtk_builder_new_from_file(file);
	if tmpBuilder == nil then
		return nil;
	else
		return GtkBuilder(tmpBuilder);
	end
end

function GtkBuilder:add_from_file(file_name)
	if self._cobj == nil then return; end
	
	return C.gtk_builder_add_from_file(GTK_BUILDER(self._cobj), file_name, nil);
end

function GtkBuilder:get_object(name)
	if self._cobj == nil then return nil; end
	
	local reted = C.gtk_builder_get_object(GTK_BUILDER(self._cobj), name);
	if reted == nil then
		return nil;
	else
		return GtkWidget(reted);
	end
end

GTK.Builder = GtkBuilder;
GTK.GtkBuilder = GtkBuilder;

return GTK;
