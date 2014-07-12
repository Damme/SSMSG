SSMSG
=====

Small shellscript gateway between mysensors (www.mysensors.org) and SQL-database.

               SSMSG v0.1
    Single file SQL MySensors* Gateway
    * see www.mysensors.org for more information

    Copyright (C) 2014 Daniel Wiegert

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>


Example to set relay on node:
```
INSERT INTO sendrequest SET nodeid=3, childid=3, messagetype=1, subtype=2, payload=1;
```

ssmsg.sh options:
```
 Option                       Meaning
  (no option)                 Run in background
  -f                          Run in foreground
  -x                          Kill script
```
