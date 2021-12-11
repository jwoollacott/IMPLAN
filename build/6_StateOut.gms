$IF not set ST set ST AK
PARAMETER   Y0, ID0, FD0, VA0, Y0_, ID0_, FD0_, VA0_, empl, ty, tl, tk ;
SET         r, g, fdcol, varow, h ;
ALIAS       (g,s), (h, hh)   ;
$GDXIN      ./data/%target%/IMPLAN_data_%target%.gdx
$LOAD       ID0 FD0 VA0 r g fdcol varow empl h ty tl tk
$GDXIN  

display ty, tl, tk ;

Y0(r,s)         = sum(g, ID0(r,g,s)) + sum(varow, VA0(r,varow,s))  ;


ID0_(g,s)       = ID0("%ST%",g,s)     + eps ;
FD0_(g,fdcol)   = FD0("%ST%",g,fdcol) + eps ;
VA0_(varow,s)   = VA0("%ST%",varow,s) + eps ;
Y0_(s)          = Y0("%ST%",s)        + eps ;

parameter   mult    multipliers
            amat    A matrix -- direct requirements
            i_ai    I-A matrix indirect
            i_au    I-A matrix induced
            leon    Leontief inverse
            lpc     local purchase coefficient    ; 
set         mt      mulitplier type         / dir, idr, idu /
            mq      multiplier quantity     / emp, lab, va  /
            im(fdcol) imports               / imd, imf /
            geo     geography of impacts    / loc, nat /
            gh      set g plus households for induced closure / set.g, "HH" / ;
ALIAS (gh, sh) ;

*   Direct
amat(g,s)$y0("%ST%",s)      = ID0("%ST%",g,s)                           / y0("%ST%",s) ;
amat("lab",s)$y0("%ST%",s)  = VA0("%ST%","LAB",s)                       / y0("%ST%",s) ;
amat("va",s)$y0("%ST%",s)   = sum(varow, VA0("%ST%",varow,s))           / y0("%ST%",s) ;
amat("hh",s)$y0("%ST%",s)   = (VA0("%ST%","KAP",s)+VA0("%ST%","LAB",s)) / y0("%ST%",s) ;
amat("emp",s)$y0("%ST%",s)  = empl("%ST%",s) * 1e-3                     / y0("%ST%",s) ;
amat(g,"hh")                = (sum(h, FD0("%ST%",g,h)) + FD0("%ST%",g,"INV")) / sum(s,VA0("%ST%","KAP",s)+VA0("%ST%","LAB",s));
amat("HH","HH")             = 1 - sum(g, amat(g,"hh")) ;

i_ai(g,s)       = -amat(g,s)    ;
i_ai(g,g)       = 1 + i_ai(g,g) ;

i_au(gh,sh)     = -amat(gh,sh)  ;
i_au(gh,gh)     = 1 + i_au(gh,gh);

display i_au ;

execute_unload './data/tempdata/i_ai.gdx', g i_ai gh i_au    ;
execute '=invert ./data/tempdata/i_ai.gdx g i_ai ./data/tempdata/idr.gdx idr'   ;
execute_unload './data/tempdata/i_au.gdx', gh i_au     ;
execute '=invert ./data/tempdata/i_au.gdx gh i_au ./data/tempdata/idu.gdx idu'   ;


PARAMETER   idr     indirect multipliers
            idu     induced multipliers ;
$gdxin ./data/tempdata/idr.gdx
$load  idr 
$gdxin ./data/tempdata/idu.gdx
$load  idu
$gdxin

lpc(r,g,"LOC")$y0("%ST%",g)  = max(0, 1 + sum(im, FD0("%ST%",g,im)) / y0("%ST%",g)) ;
lpc(r,g,"NAT")$y0("%ST%",g)  = max(0, 1 + FD0("%ST%",g,"imf")       / y0("%ST%",g)) ;

DISPLAY lpc; 
$exit

mult("out","dir",geo,s) = lpc("%ST%",s,geo) ;
mult("out","idr",geo,s) = sum(g, idr(g,s) * lpc("%ST%",g,geo)) - mult("out","dir",geo,s) ;
mult("out","idu",geo,s) = sum(g, idu(g,s) * lpc("%ST%",g,geo)) - mult("out","idr",geo,s) - mult("out","dir",geo,s);

mult(mq,"dir",geo,s) = lpc("%ST%",s,geo) * amat(mq,s);
mult(mq,"idr",geo,s) = sum(g, idr(g,s) * lpc("%ST%",g,geo) * amat(mq,g)) - mult(mq,"dir",geo,s);
mult(mq,"idu",geo,s) = sum(g, idu(g,s) * lpc("%ST%",g,geo) * amat(mq,g)) - mult("out","idr",geo,s) - mult(mq,"dir",geo,s);

display mult, idr, idu;

execute_unload './data/%target%/IMPLAN_data_%target%_%ST%.gdx', ID0_ FD0_ VA0_ mult ;
$onecho > out.txt
PAR=ID0_    RNG=%ST%_ID!A1
PAR=VA0_    RNG=%ST%_VA!A1
PAR=FD0_    RNG=%ST%_FD!A1
PAR=mult    RNG=%ST%_Mult!A1
$offecho
execute 'gdxxrw.exe ./data/%target%/IMPLAN_data_%target%_%ST%.gdx o=./data/%target%/%target%_SAMs.xlsx @out.txt' ;
execute 'rm out.txt'



