set target=%1
set reg=%2
set states=AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY
::  Sub-state regions from target.set
::  USCA: WA state regions
set sstreg=WRIA7 BLUES NEWA NCENT SCENT ROWWA COPLT
::  USCA: NY state regions
:: set sstreg=WESNY FNGLK STIER CENNY MHKVL CPREG MDHUD NYCLI NCNTY

@echo off

:: Set sub-directory for individual IMPLAN county files
if %REG% == USA (
    set sd 
) else (
    set sd=\%REG%_county
)


:: goto merge
goto aggregation
:: goto tradeadj
:: goto translate
:: goto census_agg
goto state_agg

: Whenever possible, skip the reading of individual state data files --
: it takes a while...

:run_all
if exist errors.txt del errors.txt
echo About to read the data sets...

if %REG% == USA (
    FOR %%s in (%states%) do (
        echo made it into the state %%s loop...
        call ./build/1_readstate %%s
    )
) else (
::  Set max county number for chosen state in 3rd position of parenthetical
    FOR /L %%c in (1,2,77) do (
        if %%c LSS 10                call ./build/1_readstate %REG%_00%%c
        if %%c GTR 10 if %%c LSS 100 call ./build/1_readstate %REG%_0%%c 
        if %%c GTR 100               call ./build/1_readstate %REG%_%%c  
    )
)
if exist errors.txt type errors.txt

:merge
if not exist data\nul mkdir data'
if not exist data\%target%\nul mkdir data\%target%
title Merge single data state files and check consistency:
call gams build\2_merge o=.\listings\merge.lst --ds1=%REG%_001 --subdir=%sd%

:aggregation
call gams build\3_aggregation o=.\listings\3_aggregation.lst --target=%target% --subdir=%sd% --ds1=%REG%_001

:tradeadj
call gams build\4_tradeadj o=.\listings\4_tradeadj.lst --target=%target% 

:translate
call gams build\5_translate o=.\listings\5_translate.lst --target=%target%

goto state_agg
:census_agg
call gams build\6_census_agg o=.\listings\6_census_agg.lst 

:state_agg
if %REG%==USA (
::  LIST COUNTRY REGION GROUPINGS FROM AGGREGATION SET YOU WANT EXPORTED
    FOR %%s in (%states%) do (    
        call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=%%s
    )
) else (
::  EXPORT ONCE FOR STATE AND THEN FOR EA STATE REGION
    call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=%REG% --AGG=Y
    FOR %%r in (%sstreg%) do (
        call gams build\6_StateOut.gms o=.\listings\6_StateOut.lst --target=%target% --ST=%%r
    )
)


:end
