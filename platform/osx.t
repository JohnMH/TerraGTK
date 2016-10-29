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

--[[
TODO: Test for OS and change as appropriate.
]]
terralib.includepath = terralib.includepath ..
	";/usr/local/include/gtk-3.0" ..
	";/usr/local/include/glib-2.0" ..
	";/usr/local/lib/glib-2.0/include" ..
	";/usr/local/include/pango-1.0" ..
	";/usr/local/include/cairo" ..
	";/usr/local/include/gdk-pixbuf-2.0" ..
	";/usr/local/include/atk-1.0";

return {
	lib_path = "/usr/local/lib/libgtk-3.so";
};
