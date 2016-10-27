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

local GTK = require("../gtk");
GTK.loadlib();

local app;

function activate()
	local win, box, menubar, file_item, filemenu, quit_item;

	win = app:window_new();
	win:set_title("My title");
	win:set_default_size(200, 200);

	menubar = GTK.MenuBar();
	file_item = GTK.MenuItem.new_with_label("File");
	quit_item = GTK.MenuItem.new_with_label("Quit");
	
	filemenu = GTK.Menu();
	filemenu:append(quit_item);
	
	file_item:set_submenu(filemenu);
	menubar:append(file_item);

	box = GTK.Box(GTK.Orientation.Veritical, 5);
	box:pack_start(menubar, false, false, 3);
	win:add(box);

	win:show_all();
end

app = GTK.GtkApplication("org.gtk.example", GTK.ApplicationFlags.NONE);
app:connect("activate", activate);
app:run();
app:unref();

print("Done.");
