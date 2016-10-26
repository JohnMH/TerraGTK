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
	local win, btn, btn_box;

	win = app:window_new();
	win:set_title("My title");
	win:set_default_size(200, 200);

	btn_box = GTK.ButtonBox(GTK.Orientation.Horizontal);
	win:add(btn_box);

	btn = GTK.Button.new_with_label("Hello World");
	btn_box:add(btn);

	win:show_all();
end

app = GTK.GtkApplication("org.gtk.example", GTK.ApplicationFlags.NONE);
app:connect("activate", activate);
app:run();
app:unref();

print("Done.");
