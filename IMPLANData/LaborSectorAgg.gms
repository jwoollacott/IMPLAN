$SETGLOBAL st NY

$CALL       'csv2gdx ./IMPLAN18/%st%_Labor.csv ID=%st%_labor UseHeader=y index=1,9 values=3..8' ;
$INCLUDE    ../Defines/USCA_%st%.set
$INCLUDE    ../Defines/USCA_%st%.map

PARAMETER   %st%_Labor ;
SET         r   county regions 
            s   IMPLAN sectors  ;
$GDXIN      ./IMPLAN18/%st%_Labor.gdx
$LOAD       %st%_Labor r=dim2 s=dim1
$GDXIN      

PARAMETER   labor   ;
    labor(reg,ss)   = sum((s,r)$(mapr(reg,r) and maps(ss,s)), %st%_labor(s,r,"employment") ) ;

DISPLAY NY_labor, labor ;
EXECUTE_UNLOAD '%st%_labor.gdx', labor ;
EXECUTE 'gdxxrw.exe ./%st%_labor.gdx o=%st%_labor.xlsx par=labor rng=Labor!A1' ;



