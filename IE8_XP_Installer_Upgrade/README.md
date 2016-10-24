IE8 XP Installer Upgrade
========================

Part of Ex-pit (Explorer's XP Post-Installation Tools).

The IE8 XP Installer Upgrade script upgrades the Internet Explorer 8
installer. It integrates IE8 updates so that the installer have the latest
files.

The script is useful if you want to mass-deploy IE8 on a group of computers
with the stock Windows XP installed. This script also supports Windows Server
2003 or WinXP x64 Edition, but not Windows Vista or 7.

Notice before using
-------------------

* IE is an INSECURE browser. The user should know this before using. I advise
  that you use a safer browser (such as Firefox or Chrome) rather than IE on
  a regular basis. Even though IE8 is more secure than IE6, it's still unsafe.

* Microsoft will end the support of Windows XP family of operating systems by
  the end of April 2014. As soon as they ends the support, the author will no
  longer update this script.

* The author is not responsible for any use or misuse of this script. NO
  WARRANTY IS PROVIDED. USE AT YOUR OWN RISK.

How to use
----------

1. Download and install Java and 7-zip.
   <http://www.java.com/> <http://www.7-zip.org/>

2. Download the IE8 installers and the updates of your languages.
   Store the installers in the "ie8_installers" directory and the updates in
   "ie8_updates" directory.

3. Set the PATH environment variable to where the Java and 7-zip executable
   are found. If you don't know what to do in this step, open a Command
   Prompt and run this:

        SET PATH=%PATH%;C:\Program Files\Java\jre7\bin;C:\Program Files\7-Zip

4. Run "scripts\ie8_installer_upgrade.cmd" in the Command Prompt.

5. The installers in the "ie8_installers" directory will include the updated
   files. However, due to a technical limitation (see below) it is impossible
   to integrate the registry changes in the IE8 security update. When you
   install IE8 using the upgraded installer, use the registry file
   IE8-cumulative-update-x86.reg to update the registry. (For 64-bit IE, Use
   IE8-cumulative-update-x64.reg instead.)

The IE8-cumulative-update registry file
---------------------------------------

The registry entries that are applied during IE8 installation are stored in
the "update.inf" file in the IE8 installer. The file's SHA1 hash is stored in
"ie8.cat" which is signed by Microsoft to prevent malicious edits. This means
that I can't integrate registry updates into the file, because the installer
will stop installation when it fails the file hash check.

Fortunately all IE8 cumulative security updates carry the same set of registry
changes, and the changes are not many. They can be stored in a REG file which
can be applied after the IE8 installation.

Sometimes you'll be prompted to restart the computer when the installation
finishes. You may choose to apply the .reg file before or after the restart.
It doesn't matter either way.

Authors and License
-------------------

The IE8 XP Installer Upgrade script is written by Kang-Che Sung ("Explorer").

Copyright (C) 2013,2014,2016 Kang-Che Sung < explorer09 at gmail dot com >

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License (GNU LGPL) as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

The Upgrade script depends on a self-extraction module (7zSD.sfx) by
Igor Pavlov. The module is placed in the public domain.
7-Zip Copyright (C) 1999-2016 Igor Pavlov.
