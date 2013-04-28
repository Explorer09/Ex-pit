@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

ECHO Last updated: 2013-04-10 (April 2013 Patch Tuesday)
ECHO.
ECHO This script removes the registry entries of Windows updates you have installed.
ECHO Before continuing, make sure you have admistrator rights and turn off your
ECHO anti-virus software.
PAUSE

SET updates_count=1
SET obsolete_updates_count=0

REM Post-SP3 updates
SET update_list=
FOR %%i in (
KB943232-v2 KB944043-v3 KB946648 KB950762 KB950974 KB951376-v2 KB951978
KB952004 KB952287 KB952954 KB953155 KB954550-v5 KB954920-v2 KB955704 KB956572
KB956744 KB956802 KB956844 KB960680-v2 KB960859 KB961451-v2 KB961503 KB969059
KB970430 KB970483 KB971029 KB971657 KB972270 KB973507 KB973815 KB973869
KB973904 KB974112 KB974318 KB974392 KB974571 KB975025 KB975254 KB975467
KB975560 KB975713 KB976323 KB977816 KB977914 KB978338 KB978542 KB978601
KB978706 KB979309 KB979482 KB979687 KB981322 KB981997 KB982132 KB982665
KB2115168
KB2124261
KB2229593
KB2290570
KB2296011
KB2345886
KB2347290
KB2360937
KB2387149
KB2393802
KB2419632
KB2423089
KB2440591
KB2443105
KB2478960
KB2478971
KB2479943
KB2481109
KB2483185
KB2485663
KB2491683
KB2492386
KB2506212
KB2508429
KB2509553
KB2510581
KB2535512
KB2536276-v2
KB2544893-v2
KB2564958
KB2566454
KB2584146
KB2585542
KB2592799
KB2598479
KB2619339
KB2620712
KB2624667
KB2631813
KB2653956
KB2655992
KB2661254-v2
KB2661637
KB2691442
KB2698365
KB2705219-v2
KB2712808
KB2719985
KB2723135-v2
KB2727528
KB2736233
KB2749655
KB2753842-v2
KB2757638
KB2758857
KB2770660
KB2779562
KB2780091
KB2802968
KB2807986
KB2808735
KB2813170
KB2813345
KB2817183
KB2820917
) DO (
    SET update_list=!update_list! %%i
    SET /A updates_count+=1
)

REM Updates that requires this value to be preserved:
REM   "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i" "Installed"
REM If the key is deleted, the Automatic Update checker will assume the update is not installed.
SET keep_installed_update_list=
FOR %%i in (
KB961118 KB968389 KB2570947 KB2603381 KB2659262 KB2686509
) DO (
    SET keep_installed_update_list=!keep_installed_update_list! %%i
    SET /A updates_count+=1
)

REM IE8 updates
SET ie8_update_list=
FOR %%i in (
KB2510531-IE8 KB2598845-IE8 KB2632503-IE8 KB2817183-IE8
) DO (
    SET ie8_update_list=!ie8_update_list! %%i
    SET /A updates_count+=1
)

REM WMP updates
SET wmp_update_list=
FOR %%i in (
KB952069_WM9 KB954155_WM9 KB973540_WM9 KB975558_WM8 KB978695_WM9 KB2378111_WM9
) DO (
    SET wmp_update_list=!wmp_update_list! %%i
    SET /A updates_count+=1
)

SET obsolete_update_list=
REM These updates are obsolete.
REM (KB951376 KB2536276 KB2544893 KB2661254 KB2705219 KB2723135 replaced by their v2 updates.)
FOR %%i in (
KB923561
KB938464
KB938464-v2
KB942763
KB950759
KB950760
KB951066
KB951072
KB951072-v2
KB951376
KB951698
KB951748
KB953838
KB953839
KB954211
KB954459
KB954600
KB955069
KB955839
KB956390
KB956391
KB956803
KB956841
KB957095
KB957097
KB958215
KB958644
KB958687
KB958690
KB958869
KB959426
KB960225
KB960714
KB960715
KB960803
KB961371
KB961371-v2
KB961373
KB961501
KB963027
KB967715
KB968537
KB969897
KB969898
KB969947
KB970238
KB970653-v3
KB971468
KB971486
KB971557
KB971633
KB971737
KB972260
KB973346
KB973354
KB973525
KB973687
KB974455
KB975561
KB975562
KB976098-v2
KB976325
KB976749
KB977165
KB978037
KB978207
KB978251
KB978262
KB979306
KB979559
KB979683
KB980182
KB980195
KB980218
KB980232
KB980436
KB981349
KB981793
KB981852
KB981957
KB982214
KB982381
KB982802
KB2079403
KB2121546
KB2141007
KB2158563
KB2160329
KB2183461
KB2259922
KB2279986
KB2286198
KB2296199
KB2360131
KB2412687
KB2416400
KB2436673
KB2443685
KB2467659
KB2476490
KB2476687
KB2479628
KB2482017
KB2485376
KB2497640
KB2503658
KB2503665
KB2506223
KB2507618
KB2507938
KB2508272
KB2511455
KB2524375
KB2530548
KB2536276
KB2541763
KB2544521
KB2544893
KB2555917
KB2559049
KB2562937
KB2567053
KB2567680
KB2570222
KB2570791
KB2586448
KB2607712
KB2616676
KB2616676-v2
KB2618444
KB2618451
KB2621440
KB2633171
KB2633952
KB2639417
KB2641653
KB2641690
KB2646524
KB2647516
KB2647518
KB2657025
KB2660465
KB2661254
KB2675157
KB2676562
KB2681116
KB2685939
KB2695962
KB2698707
KB2699988
KB2705219
KB2707511
KB2709162
KB2718523
KB2718704
KB2722913
KB2723135
KB2724197
KB2731847
KB2731847-v2
KB2732052
KB2744842
KB2753842
KB2756822
KB2761226
KB2761465
KB2778344
KB2779030
KB2792100
KB2797052
KB2799329
KB2799494
KB2809289
) DO (
    SET obsolete_update_list=!obsolete_update_list! %%i
    SET /A obsolete_updates_count+=1
)

SET obsolete_ie8_update_list=
REM JScript 5.8 obsolete updates: KB971961-IE8 KB981332-IE8
FOR %%i in (
KB969897-IE8 KB971961-IE8 KB972260-IE8 KB974455-IE8 KB976325-IE8 KB976749-IE8
KB978207-IE8 KB980182-IE8 KB981332-IE8 KB982381-IE8 KB2183461-IE8 KB2360131-IE8
KB2416400-IE8 KB2482017-IE8 KB2497640-IE8 KB2530548-IE8 KB2544521-IE8
KB2559049-IE8 KB2586448-IE8 KB2618444-IE8 KB2647516-IE8 KB2675157-IE8
KB2699988-IE8 KB2722913-IE8 KB2744842-IE8 KB2761465-IE8 KB2792100-IE8
KB2797052-IE8 KB2799329-IE8 KB2809289-IE8
) DO (
    SET obsolete_ie8_update_list=!obsolete_ie8_update_list! %%i
    SET /A obsolete_updates_count+=1
)

SET obsolete_wmp_update_list=
FOR %%i in (
KB968816_WM9
KB979402_WM9
) DO (
    SET obsolete_wmp_update_list=!obsolete_wmp_update_list! %%i
    SET /A obsolete_updates_count+=1
)

REM ---------------------------------------------------------------------------

SET g_counter=1
ECHO Removing uninstall information from registry...
ECHO.

REM KB898461
FOR %%i in (KB898461) DO (
    SET keys_deleted_status=NOTFOUND
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows XP\SP3\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %updates_count%
    SET /A g_counter+=1
)

ECHO.
FOR %%i in (%update_list%) DO (
    SET keys_deleted_status=NOTFOUND
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows XP\SP4\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %updates_count%
    SET /A g_counter+=1
)

ECHO.
FOR %%i in (%keep_installed_update_list%) DO (
    SET has_hotfix_entry=0
    SET keys_deleted_status=NOTFOUND
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows XP\SP4\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=CLEANED
    ) >nul 2>nul
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i"
    ) DO (
        reg query %%k /v Installed
        IF NOT ERRORLEVEL 1 SET has_hotfix_entry=1
        IF "!has_hotfix_entry!"=="1" (
            reg delete %%k /f
            reg add %%k /v Installed /t REG_DWORD /d 1 /f
            SET keys_deleted_status=CLEANED
        )
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %updates_count%
    SET /A g_counter+=1
)

ECHO.
FOR %%i in (%ie8_update_list%) DO (
    SET keys_deleted_status=NOTFOUND
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows XP\SP0\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %updates_count%
    SET /A g_counter+=1
)

ECHO.
FOR %%i in (%wmp_update_list%) DO (
    SET keys_deleted_status=NOTFOUND
    (
        reg delete "HKLM\SOFTWARE\Microsoft\Multimedia\WMPlayer\WMPQFEBackup" /v %%i /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED
    ) >nul 2>nul
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows Media Player\%%i"
        "HKLM\SOFTWARE\Microsoft\Updates\Windows Media Player\SP0\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %updates_count%
    SET /A g_counter+=1
)

REM ---------------------------------------------------------------------------

SET g_counter=1
ECHO.
ECHO Searching for obsolete updates... ^(%obsolete_updates_count% total^)
ECHO.
FOR %%i in (%obsolete_update_list%) DO (
    SET keys_deleted_status=NOTFOUND_OBSOLETE
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows XP\SP4\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED_OBSOLETE
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %obsolete_updates_count%
    FOR %%d in (
        "%windir%\$NtUninstall%%i$"
        "%windir%\$hf_mig$\%%i"
    ) DO (
        CALL :PromptAndRemoveDir %%d
    )
    SET /A g_counter+=1
)
FOR %%i in (%obsolete_ie8_update_list%) DO (
    SET keys_deleted_status=NOTFOUND_OBSOLETE
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows XP\SP0\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED_OBSOLETE
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %obsolete_updates_count%
    FOR %%d in (
        "%windir%\ie8updates\%%i"
        "%windir%\$hf_mig$\%%i"
    ) DO (
        CALL :PromptAndRemoveDir %%d
    )
    SET /A g_counter+=1
)
FOR %%i in (%obsolete_wmp_update_list%) DO (
    SET keys_deleted_status=NOTFOUND_OBSOLETE
    (
        reg delete "HKLM\SOFTWARE\Microsoft\Multimedia\WMPlayer\WMPQFEBackup" /v %%i /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED_OBSOLETE
    ) >nul 2>nul
    FOR %%k in (
        "HKLM\SOFTWARE\Microsoft\Updates\Windows Media Player\%%i"
        "HKLM\SOFTWARE\Microsoft\Updates\Windows Media Player\SP0\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%%i"
        "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Hotfix\%%i"
    ) DO (
        reg delete %%k /f
        IF NOT ERRORLEVEL 1 SET keys_deleted_status=DELETED_OBSOLETE
    ) >nul 2>nul
    CALL :DisplayDeletedMessage %%i !keys_deleted_status! !g_counter! %obsolete_updates_count%
    FOR %%d in (
        "%windir%\$NtUninstall%%i$"
        "%windir%\$hf_mig$\%%i"
    ) DO (
        CALL :PromptAndRemoveDir %%d
    )
    SET /A g_counter+=1
)

ECHO.
ECHO Done.
ENDLOCAL
PAUSE
GOTO End

REM ---------------------------------------------------------------------------

REM /**
REM  * Prompt the user to remove a specified directory.
REM  *
REM  * Note that this subroutine maintains a global variable: g_delete_confirmed.
REM  *
REM  * @param %1  Directory to remove.
REM  * @return    0 if the deletion is successful, 1 otherwise.
REM  */
:PromptAndRemoveDir
IF EXIST %1 (
    IF "!g_delete_confirmed!"=="ALL" (
        ECHO Deleting directory %1 ...
    ) ELSE (
        SET g_delete_confirmed=UNSET
        :PromptAndRemoveDirPrompt
            REM Prompt the message.
            SET /P prompt=Delete this directory %1 [Yes/No/All]? 
            IF /I "!prompt!"=="Y"   SET g_delete_confirmed=YES
            IF /I "!prompt!"=="YES" SET g_delete_confirmed=YES
            IF /I "!prompt!"=="N"   SET g_delete_confirmed=NO
            IF /I "!prompt!"=="NO"  SET g_delete_confirmed=NO
            IF /I "!prompt!"=="A"   SET g_delete_confirmed=ALL
            IF /I "!prompt!"=="ALL" SET g_delete_confirmed=ALL
        IF "!g_delete_confirmed!"=="UNSET" GOTO PromptAndRemoveDirPrompt
    )

    REM Delete the directory.
    IF NOT "!g_delete_confirmed!"=="NO" (
        ATTRIB -R -H -S %1
        DEL /F /Q %1
        RMDIR /S /Q %1
        EXIT /B 0
    )
)
EXIT /B 1
GOTO :EOF

REM /**
REM  * Display a message about what update is deleted, cleaned, or not found.
REM  * 
REM  * @param %1 The name of the update (usually KB number).
REM  * @param %2 Status text, which must be one of the following: DELETED, DELETED_OBSOLETE, CLEANED, or NOTFOUND.
REM  * @param %3 Number indicating this is update # N, which is shown in the message.
REM  * @param %4 Total number of updates, which is shown in the message.
REM  */
:DisplayDeletedMessage
    SET /A percentage=%3*100/%4
    IF /I "%2"=="DELETED" (
        ECHO Registry Deleted  : %1 ^(%3 of %4 - %percentage%%%^)
    ) ELSE IF /I "%2"=="DELETED_OBSOLETE" (
        ECHO Registry Deleted  : obsolete %1 ^(%3 of %4 - %percentage%%%^)
    ) ELSE IF /I "%2"=="CLEANED" (
        ECHO Registry Cleaned  : %1 ^(%3 of %4 - %percentage%%%^)
    ) ELSE IF /I "%2"=="NOTFOUND_OBSOLETE" (
        ECHO Registry Not Found: obsolete %1 ^(%3 of %4 - %percentage%%%^)
    ) ELSE IF /I "%2"=="NOTFOUND" (
        ECHO Registry Not Found: %1 ^(%3 of %4 - %percentage%%%^)
    )
GOTO :EOF

:End
