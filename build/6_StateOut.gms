$IF not set ST set ST AK
PARAMETER   Y0, ID0, FD0, VA0, Y0_, ID0_, FD0_, VA0_, empl, labor ;
SET         r, g, fdcol, varow, h ;
ALIAS       (g,s), (h, hh)   ;
$GDXIN      ./data/%target%/IMPLAN_data_%target%.gdx
$LOAD       ID0 FD0 VA0 r g fdcol varow empl h
$GDXIN  

$GDXIN      ./IMPLANData/NY_labor.gdx
$LOAD       labor
$GDXIN      

$IFTHEN %AGG%=="Y"
    alias (r,r_) ;
$ELSE
    set r_ / %ST% / ;
$ENDIF

display r_ ;

Y0(r,s)         = sum(g, ID0(r,g,s)) + sum(varow, VA0(r,varow,s))  ;

ID0_(g,s)       = sum(r_, ID0(r_,g,s)    ) + eps ;
FD0_(g,fdcol)   = sum(r_, FD0(r_,g,fdcol)) + eps ;
VA0_(varow,s)   = sum(r_, VA0(r_,varow,s)) + eps ;
Y0_(s)          = sum(r_,  Y0(r_,s)      ) + eps ;

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
lpc(g,"REGS")$sum(r_, y0(r_,g)) = max(0, 1 + sum((r,im),  FD0(r,g,im))  / sum(r,  y0(r,g))) ;
lpc(g,"NATL")$sum(r_, y0(r_,g)) = max(0, 1 + sum(r_, FD0(r_,g,"imf"))   / sum(r_, y0(r_,g))) ;

*   Direct
amat(g,s,geo)$sum(r_, y0(r_,s))     = lpc(g,geo) * sum(r_, ID0(r_,g,s)) / sum(r_, y0(r_,s)) ;
amat("lab",s,geo)$sum(r_, y0(r_,s)) = sum(r_, VA0(r_,"LAB",s))          / sum(r_, y0(r_,s)) ;
amat("va",s,geo)$sum(r_, y0(r_,s))  = sum((r_,varow), VA0(r_,varow,s))  / sum(r_, y0(r_,s)) ;
amat("emp",s,geo)$sum(r_, y0(r_,s)) = sum(r_,empl(r_,s)) * 1e-3         / sum(r_, y0(r_,s)) ;

amat("hh",s,geo)$sum(r_, y0(r_,s))  = sum(r_,VA0(r_,"KAP",s)+VA0(r_,"LAB",s)) / sum(r_, y0(r_,s)) ;
amat(g,"hh",geo)                    = lpc(g,geo) * sum(r_, sum(h, FD0(r_,g,h))     + FD0(r_,g,"INV")) 
                                    / sum(s, sum(r_, sum(h, FD0(r_,s,h))     + FD0(r_,s,"INV"))) ; 

PARAMETER   idr indirect multipliers 
            idu induced multipliers  
            idr_, idu_  temporary params
            idr_1reg, idu_1reg, idr_regs, idu_regs    ;

i_ai(g,s)       = -amat(g,s,"1REG")     ;
i_ai(g,g)       = 1 + i_ai(g,g)         ;
i_au(gh,sh)     = -amat(gh,sh,"1REG")   ;
i_au(gh,gh)     = 1 + i_au(gh,gh)       ;

execute_unload './data/tempdata/i_1reg.gdx', g i_ai gh i_au    ;
execute 'invert ./data/tempdata/i_1reg.gdx    g  i_ai  ./data/tempdata/idr_1reg.gdx idr_1reg'   ;
execute 'invert ./data/tempdata/i_1reg.gdx    gh i_au  ./data/tempdata/idu_1reg.gdx idu_1reg'   ;

$GDXIN ./data/tempdata/idr_1reg.gdx
$LOAD  idr_1reg 
$GDXIN
$GDXIN ./data/tempdata/idu_1reg.gdx
$LOAD  idu_1reg
$GDXIN
idr("1REG",g,s)    = idr_1reg(g,s) ;
idu("1REG",g,s)    = idu_1reg(g,s) ;

i_ai(g,s)       = -amat(g,s,"REGS")     ;
i_ai(g,g)       = 1 + i_ai(g,g)         ;
i_au(gh,sh)     = -amat(gh,sh,"REGS")   ;
i_au(gh,gh)     = 1 + i_au(gh,gh)       ;

execute_unload './data/tempdata/i_regs.gdx', g i_ai gh i_au    ;
execute 'invert   ./data/tempdata/i_regs.gdx   g  i_ai ./data/tempdata/idr_regs.gdx idr_regs'   ;
execute 'invert   ./data/tempdata/i_regs.gdx   gh i_au ./data/tempdata/idu_regs.gdx idu_regs'   ;

$GDXIN ./data/tempdata/idr_regs.gdx
$LOAD  idr_regs=idr_regs 
$GDXIN
$GDXIN ./data/tempdata/idu_regs.gdx
$LOAD  idu_regs=idu_regs
$GDXIN
idr("REGS",g,s)    = idr_regs(g,s) ;
idu("REGS",g,s)    = idu_regs(g,s) ;

parameter test ;
    test(g,s) = idr("REGS",g,s) - idr("1REG",g,s) ;

display test ;
$exit

mult("out","dir",geo,s) = lpc(s,geo) ;
mult("out","idr",geo,s) = sum(g, idr(g,s) * (lpc(g,geo)$(not sameas(g,s)) + 1$sameas(g,s)) * lpc(s,geo)) - mult("out","dir",geo,s) ;
mult("out","idu",geo,s) = sum(g, idu(g,s) * (lpc(g,geo)$(not sameas(g,s)) + 1$sameas(g,s)) * lpc(g,geo)) - mult("out","idr",geo,s) - mult("out","dir",geo,s);

mult(mq,"dir",geo,s) = lpc(s,geo) * amat(mq,s);
mult(mq,"idr",geo,s) = sum(g, lpc(s,geo) * idr(g,s) * (lpc(g,geo)$(not sameas(g,s)) + 1$sameas(g,s)) * amat(mq,g)) - mult(mq,"dir",geo,s);
mult(mq,"idu",geo,s) = sum(g, lpc(s,geo) * idu(g,s) * (lpc(g,geo)$(not sameas(g,s)) + 1$sameas(g,s)) * amat(mq,g)) - mult(mq,"dir",geo,s) - mult(mq,"idr",geo,s);

display mult, idr, idu, lpc;
$exit
execute_unload './data/%target%/IMPLAN_data_%target%_%ST%.gdx', ID0_ FD0_ VA0_ Y0_ mult lpc;
$onecho > out.txt
PAR=ID0_    RNG=%ST%_ID!A1
PAR=VA0_    RNG=%ST%_VA!A1
PAR=FD0_    RNG=%ST%_FD!A1
PAR=Y0_     RNG=%ST%_Y!A1
PAR=mult    RNG=%ST%_Mult!A1
PAR=lpc     RNG=%ST%_LPC!A1
$offecho
execute 'gdxxrw.exe ./data/%target%/IMPLAN_data_%target%_%ST%.gdx o=./data/%target%/%target%_SAMs.xlsx epsout=0 @out.txt' ;
execute 'rm out.txt'



