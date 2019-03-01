ZEFA Suite
==========

Designed for Zimbra version 8.8.

Bugs and feedback: https://github.com/btactic/zefa-suite/issues


========================================================================

### Obtain ZEFA Source code

TODO

```
git clone --recurse-submodules git://github.com/btactic/zefa-suite
```

### Install prerequisites
  - No special requirements

### Build your own ZEFA plugins

TODO

### Installing

TODO


========================================================================

### Screenshot of generated extensions
No need to have CLI access to create/revoke root shares.
![alt tag](https://raw.githubusercontent.com/btactic/zefa-suite/master/zefa-common/zefa-btactic-getaccount/help/admin-zimlet.png)

### CLI Commands
Installed in /usr/local/sbin an can be run as user `zimbra`:
Check each plugin help page.


### Enable the ZEFA Admin Zimlet for delegated admins

    zmprov ma testadmin@example.com +zimbraAdminConsoleUIComponents zimbraClientUploadView
    zmprov grr global usr testadmin@example.com adminConsoleClientUploadRights
    zmprov fc all

### License

Copyright (C) 2019 BTACTIC,SCCL [BTACTIC](http://www.btactic.com/)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.
