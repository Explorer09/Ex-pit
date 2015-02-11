Please put the IE8 updates in this directory.
The IE8 updates should have filenames like this:
    IE8-WindowsXP-KB2936068-x86-ENU.exe
    IE8-WindowsServer2003-KB3021952-x86-ENU.exe
    IE8-WindowsServer2003-KB3021952-x64-ENU.exe

You may integrate multiple updates into the installer. When you do this,
beware of the order of which updates are integrated. Update with a lower KB
number will be integrated first. If this is not what you want, you may rename
the files so that it has a higher number.
