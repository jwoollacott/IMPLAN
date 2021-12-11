$IF not set ST set ST AK
PARAMETER   Y0, ID0, FD0, VA0, Y0_, ID0_, FD0_, VA0_, empl, ty, tl, tk ;
SET         r, g, fdcol, varow, h ;
ALIAS       (g,s), (h, hh)   ;
$GDXIN      ./data/%target%/IMPLAN_data_%target%.gdx
$LOAD       ID0 FD0 VA0 r g fdcol varow empl h ty tl tk
$GDXIN  

$GDXIN      ./IMPLANData/IMPLAN18/%ST%_labor.gdx
$LOAD       labor
$GDXIN  
   

$IFTHEN %AGG%=="Y"
    alias (r,r_) ;
$ELSE
    set r_ / %ST% / ;
$ENDIF

display r_, ty, tl, tk ;
parameter tax single parameter for tax rates ;

$exit
Y0(r,s)         = sum(g, ID0(r,g,s)) + sum(varow, VA0(r,varow,s))  ;

ID0_(g,s)       = sum(r_, ID0(r_,g,s)    ) + eps ;
FD0_(g,fdcol)   = sum(r_, FD0(r_,g,fdcol)) + eps ;
VA0_(varow,s)   = sum(r_, VA0(r_,varow,s)) + eps ;
Y0_(s)          = sum(r_,  Y0(r_,s)      ) + eps ;
tax(r,s,"Y")    = ty(r,s) ; 
tax(r,s,"L")    = tl(r,s) ;
tax(r,s,"K")    = tk(r,s) ;

parameter   mult    multipliers
            amat    A matrix -- direct requirements
            i_ai    I-A matrix indirect
            i_au    I-A matrix induced
            leon    Leontief inverse
            lpc     local purchase coefficient    ; 
set         mt      mulitplier type         / dir, idr, idu /
            mq      multiplier quantity     / emp, lab, va  /
            im(fdcol) imports               / imd, imf /
            geo     geography of impacts    / 1REG, REGS, NATL /
            gh      set g plus households for induced closure / set.g, "HH" / ;
ALIAS (gh, sh) ;

*   Local purchase coefficients
lpc(g,"1REG")$sum(r_, y0(r_,g)) = max(0, 1 + sum((r_,im), FD0(r_,g,im)) / sum(r_, y0(r_,g))) ;
*   Domestic bilateral trade flows are unknown 
*   -- If state-level domestic share is lower, stick with region-level
lpc(g,"REGS")$sum(r_, y0(r_,g)) = max(lpc(g,"1REG"), max(0, 1 + sum((r,im),  FD0(r,g,im))  / sum(r,  y0(r,g)))) ;
lpc(g,"NATL")$sum(r_, y0(r_,g)) = max(0, 1 + sum(r_, FD0(r_,g,"imf"))   / sum(r_, y0(r_,g))) ;

*   Direct
amat(g,s,geo)$sum(r_, y0(r_,s))     = lpc(g,geo) * sum(r_, ID0(r_,g,s)) / sum(r_, y0(r_,s)) ;
amat("lab",s,geo)$sum(r_, y0(r_,s)) = sum(r_, VA0(r_,"LAB",s))          / sum(r_, y0(r_,s)) ;
amat("va",s,geo)$sum(r_, y0(r_,s))  = sum((r_,varow), VA0(r_,varow,s))  / sum(r_, y0(r_,s)) ;
amat("emp",s,geo)$sum(r_, y0(r_,s)) = sum(r_,labor(r_,s)) * 1e-3        / sum(r_, y0(r_,s)) ;

amat("hh",s,geo)$sum(r_, y0(r_,s))  = sum(r_,VA0(r_,"KAP",s)+VA0(r_,"LAB",s)) / sum(r_, y0(r_,s)) ;
amat(g,"hh",geo)                    = lpc(g,geo) * sum(r_, sum(h, FD0(r_,g,h))     + FD0(r_,g,"INV")) 
                                    / sum(s, sum(r_, sum(h, FD0(r_,s,h))     + FD0(r_,s,"INV"))) ; 

PARAMETER   idr                     indirect multipliers 
            idu                     induced multipliers  
            idr_(*,*), idu_(*,*)    temporary params
            idr_1reg(g,s), idu_1reg(gh,sh), idr_regs(g,s), idu_regs(gh,sh)    ;

loop(geo,

i_ai(g,s)       = -amat(g,s,geo)    ;
i_ai(g,g)       = 1 + i_ai(g,g)     ;
i_au(gh,sh)     = -amat(gh,sh,geo)  ;
i_au(gh,gh)     = 1 + i_au(gh,gh)   ;

execute_unload './data/tempdata/i_geo.gdx', g i_ai gh i_au    ;
execute 'invert ./data/tempdata/i_geo.gdx   g  i_ai  ./data/tempdata/idr.gdx idr'   ;
execute 'invert ./data/tempdata/i_geo.gdx   gh i_au  ./data/tempdata/idu.gdx idu'   ;
execute_load './data/tempdata/idr.gdx', idr_=idr ;
execute_load './data/tempdata/idu.gdx', idu_=idu ;

idr(geo,g,s)    = idr_(g,s)  ;
idu(geo,gh,sh)  = idu_(gh,sh);

);

mult("out","dir",geo,s) = lpc(s,geo) ;
mult("out","idr",geo,s) = sum(g, idr(geo,g,s)) - mult("out","dir",geo,s) ;
mult("out","idu",geo,s) = sum(g, idu(geo,g,s)) - mult("out","idr",geo,s) - mult("out","dir",geo,s)  ;

mult(mq,"dir",geo,s) = lpc(s,geo) * amat(mq,s,geo);
mult(mq,"idr",geo,s) = sum(g, idr(geo,g,s) * amat(mq,g,geo)) - mult(mq,"dir",geo,s);
mult(mq,"idu",geo,s) = sum(g, idu(geo,g,s) * amat(mq,g,geo)) - mult(mq,"dir",geo,s) - mult(mq,"idr",geo,s);

Parameter 

DISPLAY mult, idr, idu, lpc;
execute_unload './data/%target%/IMPLAN_data_%target%_%ST%.gdx', ID0_ FD0_ VA0_ Y0_ mult lpc tax ;
$onecho > out.txt
PAR=ID0_    RNG=%ST%_ID!A1
PAR=VA0_    RNG=%ST%_VA!A1
PAR=FD0_    RNG=%ST%_FD!A1
PAR=Y0_     RNG=%ST%_Y!A1
PAR=mult    RNG=%ST%_Mult!A1
PAR=lpc     RNG=%ST%_LPC!A1
PAR=tax      RNG=%ST%_Tax!A1
$offecho
execute 'gdxxrw.exe ./data/%target%/IMPLAN_data_%target%_%ST%.gdx o=./data/%target%/%target%_SAMs.xlsx epsout=0 @out.txt' ;
execute 'rm out.txt'



