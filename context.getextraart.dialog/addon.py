# -*- coding: utf-8 -*-
#
# Copyright (C) 2015 S
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import xbmc

def main():
    if xbmc.getCondVisibility("Container.Content(movies)"):
        xbmc.executebuiltin("RunScript(script.artwork.downloader, mode=gui, mediatype=movie, dbid=%s)" % (xbmc.getInfoLabel("ListItem.DBID")))
    elif xbmc.getCondVisibility("Container.Content(tvshows)"):
        xbmc.executebuiltin("RunScript(script.artwork.downloader, mode=gui, mediatype=tvshow, dbid=%s)" % (xbmc.getInfoLabel("ListItem.DBID")))

if __name__ == '__main__':
    main()
