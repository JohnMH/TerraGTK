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

GTK.init();

local builder = GTK.Builder();
builder:add_from_file("window.glade");

--[[
local win = GTK.Window(GTK.WindowType.TopLevel);
win:set_title("Hi, I'm a title! How cool is that?");
win:set_default_size(500, 70);
win:set_position(GTK.WindowPosition.Center);
local btn = GTK.Button.new_with_label("Click me");
win:add(btn);
win:show_all();

terra window_delete() : GTK.C.gboolean
	GTK.C.gtk_main_quit();
	return 0;
end

win:connect("delete-event", window_delete:getpointer());
]]

GTK.main();
