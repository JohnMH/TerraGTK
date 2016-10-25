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
This is specific to my Gentoo install, and is not confirmed to work
on all distros! TODO: Test for OS and change as appropriate.
]]
terralib.includepath = terralib.includepath ..
	";/usr/include/gtk-3.0" ..
	";/usr/include/glib-2.0" ..
	";/usr/lib/glib-2.0/include" ..
	";/usr/include/pango-1.0" ..
	";/usr/include/cairo" ..
	";/usr/include/gdk-pixbuf-2.0" ..
	";/usr/include/atk-1.0";

return {
	lib_path = "/usr/lib/libgtk-3.so";
};
