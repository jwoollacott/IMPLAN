$if not set st $SETGLOBAL st WA
$if not set target $SETGLOBAL target USA

$CALL       'csv2gdx ./IMPLANData/IMPLAN18/state_labor/%st%.csv output=./IMPLANData/IMPLAN18/state_labor_gdx/%st%_labor.gdx ID=%st%_labor UseHeader=y index=1 values=3..8' ;
$INCLUDE    .\Defines\%target%.set
$INCLUDE    .\Defines\%target%.map

PARAMETER   %st%_Labor ;
SET         r   county regions 
            s   IMPLAN sectors  ;
$GDXIN      ./IMPLANData/IMPLAN18/state_labor_gdx/%st%_labor.gdx
$LOAD       %st%_labor s=dim1
$GDXIN      

PARAMETER   labor   ;
*    labor(reg,ss)   = sum((s,r)$(mapr(reg,r) and maps(ss,s)), %st%_labor(s,r,"employment") ) ;
    labor(ss) = eps + sum((s)$(maps(ss,s)), %st%_labor(s,"employment"));

DISPLAY %st%_labor, labor ;
EXECUTE_UNLOAD './IMPLANData/IMPLAN18/state_labor_gdx_bea/%st%_labor.gdx', labor ;
*EXECUTE 'gdxxrw.exe ./%st%_labor.gdx o=%st%_labor.xlsx par=labor rng=Labor!A1' ;



