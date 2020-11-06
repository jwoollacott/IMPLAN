$IF not set ST set ST AK
PARAMETER   ID0, FD0, VA0, ID0_, FD0_, VA0_ ;
SET         r, g, fdcol, varow ;
ALIAS       (g,s)   ;
$GDXIN     ./data/%target%/IMPLAN_data_%target%.gdx
$LOAD       ID0 FD0 VA0 r g fdcol varow
$GDXIN  

ID0_(g,s)       = ID0("%ST%",g,s)    ;
FD0_(g,fdcol)   = FD0("%ST%",g,fdcol);
VA0_(varow,s)   = VA0("%ST%",varow,s);

execute_unload './data/%target%/IMPLAN_data_%target%_STtmp.gdx', ID0_ FD0_ VA0_ ;
$onecho > out.txt
PAR=ID0_    RNG=%ST%_ID!A1
PAR=VA0_    RNG=%ST%_VA!A1
PAR=FD0_    RNG=%ST%_FD!A1
$offecho
execute 'gdxxrw.exe ./data/%target%/IMPLAN_data_%target%_STtmp.gdx o=./data/%target%/%target%_SAMs.xlsx @out.txt' ;
execute 'rm out.txt'
execute 'rm ./data/%target%/IMPLAN_data_%target%_STtmp.gdx'




