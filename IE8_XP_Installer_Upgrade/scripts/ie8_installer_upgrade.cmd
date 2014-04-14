@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM ---------------------------------------------------------------------------
REM Copyright (C) 2013-2014 Kang-Che Sung <explorer09 @ gmail.com>

REM This program is free software; you can redistribute it and/or
REM modify it under the terms of the GNU Lesser General Public
REM License as published by the Free Software Foundation; either
REM version 2.1 of the License, or (at your option) any later version.

REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
REM Lesser General Public License for more details.

REM You should have received a copy of the GNU Lesser General Public
REM License along with this program; if not, write to the Free Software
REM Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
REM MA  02110-1301  USA
REM ---------------------------------------------------------------------------

REM These four global variables can be edited when needed.

REM Always use delayed expansion. This avoids command injection which is a 
REM security issue.

REM BASE_DIR is where the necessary files for this script are located.
IF "X!BASE_DIR!"=="X" (
    SET BASE_DIR=!CD!
)
REM PATH_TO_INSTALLER is the directory that contains the IE8 installers.
IF "X!PATH_TO_INSTALLER!"=="X" (
    SET PATH_TO_INSTALLER="..\ie8_installers"
)
REM PATH_TO_UPDATES is the directory that contains the IE8 updates.
IF "X!PATH_TO_UPDATES!"=="X" (
    SET PATH_TO_UPDATES="..\ie8_updates"
)
REM BRANCH could be either GDR or QFE. The default is GDR.
IF "X!BRANCH!"=="X" (
    SET BRANCH=GDR
)

REM ---------------------------------------------------------------------------

REM Command-line switch "repack-only" tells this script to repack all IE8
REM installers and ignore the updates.
SET g_repack_only=false
IF /I "X%1"=="Xrepack-only" (
    SET g_repack_only=true
)

REM These variables store the list of languages that has updates detected.
REM Variables are unused in "repack-only" mode.
SET g_languages_2003_x64=
SET g_languages_2003_x86=
SET g_languages_xp_x86=

REM The list of installers that need to be upgraded or repacked.
SET g_installers_list=

SET has_errors=false

REM Detects the presence of Java and 7-zip.
REM Poor man's 'which' command for batch script.
SET P7ZIP=
FOR %%i IN (7z.exe 7za.exe 7zr.exe) DO (
    IF "X!P7ZIP!"=="X" (
        SET P7ZIP=%%~$PATH:i
    )
)
IF "X!P7ZIP!"=="X" (
    ECHO ERROR: 7-zip is not found. Please download and install 7-zip here
    ECHO ^(http://www.7-zip.org/^).
    SET has_errors=true
)

SET JAVA=
IF "!g_repack_only!"=="false" (
    FOR %%i IN (java.exe) DO (
        IF "X!JAVA!"=="X" (
            SET JAVA=%%~$PATH:i
        )
    )
    IF "X!JAVA!"=="X" (
        ECHO ERROR: Java runtime is not found. Please download and install Java here
        ECHO ^(http://www.java.com/^).
        SET has_errors=true
    )
)

REM Use absolute paths in path global variables. Also strip quotes in paths.
IF "!g_repack_only!"=="false" (
    CD /D !BASE_DIR!
    IF EXIST !PATH_TO_UPDATES! (
        CD !PATH_TO_UPDATES!
        SET PATH_TO_UPDATES=!CD!
    ) ELSE (
        ECHO ERROR: "!BASE_DIR!\!PATH_TO_UPDATES:"=!" does not exist.
        SET has_errors=true
    )
)

CD /D !BASE_DIR!
IF EXIST !PATH_TO_INSTALLER! (
    CD !PATH_TO_INSTALLER!
    SET PATH_TO_INSTALLER=!CD!
) ELSE (
    ECHO ERROR: "!BASE_DIR!\!PATH_TO_INSTALLER:"=!" does not exist.
    SET has_errors=true
)

REM Check whether the required files exists in BASE_DIR.
FOR %%f IN (7zSD_upxed.sfx sfx_conf.txt PatchUpdateVer.class) DO (
    IF NOT EXIST "!BASE_DIR!\%%f" (
        ECHO ERROR: "!BASE_DIR!\%%f" does not exist.
        SET has_errors=true
    )
)

SET BRANCH=!BRANCH:"=!
IF /I "X!BRANCH!" == "XQFE" (
    SET BRANCH=QFE
) ELSE (
    SET BRANCH=GDR
)

IF "!has_errors!"=="true" (
    ECHO An error occurred. Aborting.
    GOTO :EOF
)

ECHO.
ECHO BASE_DIR = !BASE_DIR!
ECHO.
IF "!g_repack_only!"=="false" (
    ECHO PATH_TO_UPDATES = !PATH_TO_UPDATES!
) ELSE (
    ECHO Repack installers only. Ignoring updates.
)
ECHO.
ECHO PATH_TO_INSTALLER = !PATH_TO_INSTALLER!
ECHO.
ECHO Using !BRANCH! branch.
ECHO.
PAUSE

IF "!g_repack_only!"=="false" (
    ECHO.
    ECHO Extracting the updates... (step 1 of 6)
    ECHO ---------------------------------------
    CALL :ExtractUpdates
) ELSE (
    CALL :MakeInstallersList
)

ECHO.
ECHO Extracting IE8 installers... (step 2 of 6)
ECHO ------------------------------------------
CALL :ExtractInstallers

IF "!g_repack_only!"=="false" (
    ECHO.
    ECHO Patching IE8 installers... (step 3 of 6)
    ECHO ------------------------------------
    CALL :PatchInstaller
)

ECHO.
ECHO Creating 7z archives... (step 4 of 6)
ECHO -------------------------------------
CALL :Make7z

ECHO.
ECHO Adding SFX modules and converting to EXE... (step 5 of 6)
ECHO ---------------------------------------------------------
CALL :ConvertToExe

ECHO.
ECHO Deleting temporary files... (step 6 of 6)
ECHO -----------------------------------------
CALL :DelTempFiles

ECHO.
ECHO All done.
PAUSE

GOTO :EOF

REM ---------------------------------------------------------------------------

:ExtractUpdates
    REM The IE8 installer is provided in more languages than the updates are.
    REM By extracting the updates first, we can know which languages are
    REM supported by Microsoft and which are not.
    SET LANGUAGE_LIST=ARA CHS CHT CSY DAN DEU ELL ENU ESN FIN FRA HEB HUN ITA
    SET LANGUAGE_LIST=!LANGUAGE_LIST! JPN KOR NLD NOR PLK PTB PTG RUS SVE TRK

    CD /D !PATH_TO_UPDATES!
    REM 2003-x64
    FOR %%l IN (!LANGUAGE_LIST!) DO (
        IF EXIST IE8-WindowsServer2003.WindowsXP-KB*-x64-%%l.exe (
            SET g_languages_2003_x64=!g_languages_2003_x64! %%l
            SET g_installers_list=!g_installers_list! IE8-WindowsServer2003-x64-%%l
        )
        FOR %%f IN (IE8-WindowsServer2003.WindowsXP-KB*-x64-%%l.exe) DO (
            ECHO %%f
            SET filename=%%f
            REM To remove the strings "IE8-WindowsServer2003.WindowsXP-KB" and
            REM "-x86-XXX.exe".
            SET kb_number=!filename:~34,-12!
            REM Prefix a "0" when kb_number has only 6 digits.
            IF "X!kb_number:~6!" == "X" (
                SET kb_number=0!kb_number!
            )
            %%f /passive /extract:2003-x64-tmp-%%l\!kb_number!
        )
    )
    REM 2003-x86
    FOR %%l IN (!LANGUAGE_LIST!) DO (
        IF EXIST IE8-WindowsServer2003-KB*-x86-%%l.exe (
            SET g_languages_2003_x86=!g_languages_2003_x86! %%l
            SET g_installers_list=!g_installers_list! IE8-WindowsServer2003-x86-%%l
        )
        FOR %%f IN (IE8-WindowsServer2003-KB*-x86-%%l.exe) DO (
            ECHO %%f
            SET filename=%%f
            REM To remove the strings "IE8-WindowsServer2003-KB" and "-x86-XXX.exe".
            SET kb_number=!filename:~24,-12!
            REM Prefix a "0" when kb_number has only 6 digits.
            IF "X!kb_number:~6!" == "X" (
                SET kb_number=0!kb_number!
            )
            %%f /passive /extract:2003-x86-tmp-%%l\!kb_number!
        )
    )
    REM xp-x86
    FOR %%l IN (!LANGUAGE_LIST!) DO (
        IF EXIST IE8-WindowsXP-KB*-x86-%%l.exe (
            SET g_languages_xp_x86=!g_languages_xp_x86! %%l
            SET g_installers_list=!g_installers_list! IE8-WindowsXP-x86-%%l
        )
        FOR %%f IN (IE8-WindowsXP-KB*-x86-%%l.exe) DO (
            ECHO %%f
            SET filename=%%f
            REM To remove the strings "IE8-WindowsXP-KB" and "-x86-XXX.exe".
            SET kb_number=!filename:~16,-12!
            REM Prefix a "0" when kb_number has only 6 digits.
            IF "X!kb_number:~6!" == "X" (
                SET kb_number=0!kb_number!
            )
            %%f /passive /extract:xp-x86-tmp-%%l\!kb_number!
        )
    )
GOTO :EOF

REM MakeInstallersList only runs in "repack-only" mode.
:MakeInstallersList
    CD /D !PATH_TO_INSTALLER!
    REM 2003-x64
    FOR %%f IN (IE8-WindowsServer2003-x64-*.exe) DO (
        SET filename=%%f
        REM To remove the trailing string ".exe".
        SET g_installers_list=!g_installers_list! !filename:~0,-4!
    )
    REM 2003-x86
    FOR %%f IN (IE8-WindowsServer2003-x86-*.exe) DO (
        SET filename=%%f
        REM To remove the trailing string ".exe".
        SET g_installers_list=!g_installers_list! !filename:~0,-4!
    )
    REM xp-x86
    FOR %%f IN (IE8-WindowsXP-x86-*.exe) DO (
        SET filename=%%f
        REM To remove the trailing string ".exe".
        SET g_installers_list=!g_installers_list! !filename:~0,-4!
    )
GOTO :EOF

:ExtractInstallers
    CD /D !PATH_TO_INSTALLER!
    FOR %%f IN (!g_installers_list!) DO (
        ECHO %%f.exe
        "!P7ZIP!" x -o"%%f" %%f.exe
    )
GOTO :EOF

:PatchInstaller
    REM 2003-x64
    FOR %%l IN (!g_languages_2003_x64!) DO (
        CD /D "!PATH_TO_UPDATES!\2003-x64-tmp-%%l"
        FOR /D %%i IN (*) DO (
            CD /D "!PATH_TO_UPDATES!\2003-x64-tmp-%%l"
            CD %%i

            REM Check if GDR is available. If not, fallback to QFE.
            SET this_branch=QFE
            IF "!BRANCH!"=="GDR" (
                IF EXIST "SP2GDR" (
                    SET this_branch=GDR
                )
            )

            CD "SP2!this_branch!"
            ECHO.
            ECHO Moving files from 2003-x64-tmp-%%l\%%i\SP2!this_branch!\* ...

            REM "wow\wieuinit.inf" is not present in the installer and should be
            REM removed. The installer uses "ieuinit.inf" for both x64 and WoW64.
            DEL /F /Q wow\wieuinit.inf
            FOR %%f IN (wow\*) DO (
                ECHO %%f
                MOVE /Y %%f "!PATH_TO_INSTALLER!\IE8-WindowsServer2003-x64-%%l\%%f" >NUL
            )
            DEL /F /Q wow
            FOR %%f IN (*) DO (
                ECHO %%f
                MOVE /Y %%f "!PATH_TO_INSTALLER!\IE8-WindowsServer2003-x64-%%l\%%f" >NUL
            )

            CD /D "!PATH_TO_INSTALLER!\IE8-WindowsServer2003-x64-%%l\update"
            ECHO.
            ECHO Patching update.ver with 2003-x64-tmp-%%l\%%i\update\update.ver ...
            FOR %%f IN ("!PATH_TO_UPDATES!\2003-x64-tmp-%%l\%%i\update\update.ver") DO (
                ECHO %%f
                "!JAVA!" -classpath "!BASE_DIR!" PatchUpdateVer update.ver %%f !this_branch! >update-patched.ver
                IF ERRORLEVEL 1 (
                    ECHO Error detected in "java PatchUpdateVer". Aborting.
                    GOTO :EOF
                )
                MOVE /Y update-patched.ver update.ver >NUL
            )
        )
    )
    REM 2003-x86
    FOR %%l IN (!g_languages_2003_x86!) DO (
        CD /D "!PATH_TO_UPDATES!\2003-x86-tmp-%%l"
        FOR /D %%i IN (*) DO (
            CD /D "!PATH_TO_UPDATES!\2003-x86-tmp-%%l"
            CD %%i

            REM Check if GDR is available. If not, fallback to QFE.
            SET this_branch=QFE
            IF "!BRANCH!"=="GDR" (
                IF EXIST "SP2GDR" (
                    SET this_branch=GDR
                )
            )

            CD "SP2!this_branch!"
            ECHO.
            ECHO Moving files from 2003-x86-tmp-%%l\%%i\SP2!this_branch!\* ...
            FOR %%f IN (*) DO (
                ECHO %%f
                MOVE /Y %%f "!PATH_TO_INSTALLER!\IE8-WindowsServer2003-x86-%%l\%%f" >NUL
            )

            CD /D "!PATH_TO_INSTALLER!\IE8-WindowsServer2003-x86-%%l\update"
            ECHO.
            ECHO Patching update.ver with 2003-x86-tmp-%%l\%%i\update\update.ver ...
            FOR %%f IN ("!PATH_TO_UPDATES!\2003-x86-tmp-%%l\%%i\update\update.ver") DO (
                ECHO %%f
                "!JAVA!" -classpath "!BASE_DIR!" PatchUpdateVer update.ver %%f !this_branch! >update-patched.ver
                IF ERRORLEVEL 1 (
                    ECHO Error detected in "java PatchUpdateVer". Aborting.
                    GOTO :EOF
                )
                MOVE /Y update-patched.ver update.ver >NUL
            )
        )
    )
    REM xp-x86
    FOR %%l IN (!g_languages_xp_x86!) DO (
        CD /D "!PATH_TO_UPDATES!\xp-x86-tmp-%%l"
        FOR /D %%i IN (*) DO (
            CD /D "!PATH_TO_UPDATES!\xp-x86-tmp-%%l"
            CD %%i

            REM Check if GDR is available. If not, fallback to QFE.
            SET this_branch=QFE
            IF "!BRANCH!"=="GDR" (
                IF EXIST "SP3GDR" (
                    SET this_branch=GDR
                )
            )

            CD "SP3!this_branch!"
            ECHO.
            ECHO Moving files from xp-x86-tmp-%%l\%%i\SP3!this_branch!\* ...
            FOR %%f IN (*) DO (
                ECHO %%f
                MOVE /Y %%f "!PATH_TO_INSTALLER!\IE8-WindowsXP-x86-%%l\%%f" >NUL
            )

            CD /D "!PATH_TO_INSTALLER!\IE8-WindowsXP-x86-%%l\update"
            ECHO.
            ECHO Patching update.ver with xp-x86-tmp-%%l\%%i\update\update.ver ...
            FOR %%f IN ("!PATH_TO_UPDATES!\xp-x86-tmp-%%l\%%i\update\update.ver") DO (
                ECHO %%f
                "!JAVA!" -classpath "!BASE_DIR!" PatchUpdateVer update.ver %%f !this_branch! >update-patched.ver
                IF ERRORLEVEL 1 (
                    ECHO Error detected in "java PatchUpdateVer". Aborting.
                    GOTO :EOF
                )
                MOVE /Y update-patched.ver update.ver >NUL
            )
        )
    )
GOTO :EOF

REM /**
REM  * Create a 7z archive for every directory in %g_installers_list%.
REM  */
:Make7z
    CD /D !PATH_TO_INSTALLER!
    FOR %%f in (!g_installers_list!) DO (
        CD "%%f"
        "!P7ZIP!" a -mx=9 -m0=LZMA2 -mmt=2 ..\%%f.7z *
        CD ..
    )
GOTO :EOF

:ConvertToExe
    CD /D !PATH_TO_INSTALLER!
    FOR %%f in (!g_installers_list!) DO (
        IF EXIST "%%f.exe" (
            ECHO %%f.bak
            DEL /F /Q "%%f.bak"
            MOVE "%%f.exe" "%%f.bak"
        )
        ECHO %%f.exe
        COPY /B "!BASE_DIR!\7zSD_upxed.sfx"+"!BASE_DIR!\sfx_conf.txt"+"%%f.7z" "%%f.exe"
    )
GOTO :EOF

:DelTempFiles
    CD /D !PATH_TO_UPDATES!
    FOR %%l IN (!g_languages_2003_x64!) DO (
        ECHO RMDIR /S /Q "2003-x64-tmp-%%l"
        RMDIR /S /Q "2003-x64-tmp-%%l"
    )
    FOR %%l IN (!g_languages_2003_x86!) DO (
        ECHO RMDIR /S /Q "2003-x86-tmp-%%l"
        RMDIR /S /Q "2003-x86-tmp-%%l"
    )
    FOR %%l IN (!g_languages_xp_x86!) DO (
        ECHO RMDIR /S /Q "xp-x86-tmp-%%l"
        RMDIR /S /Q "xp-x86-tmp-%%l"
    )

    CD /D !PATH_TO_INSTALLER!
    FOR %%f IN (!g_installers_list!) DO (
        ECHO RMDIR /S /Q "%%f"
        RMDIR /S /Q "%%f"
        ECHO DEL /F /Q "%%f.7z"
        DEL /F /Q "%%f.7z"
    )
GOTO :EOF

