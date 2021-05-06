$title  Merge Individual State Data Files and Check Consistency 
$if not set subdir $set subdir 

*   Merge individual data files into one file:

$if exist data\noaggr\noaggr.gdx    $call 'del data\noaggr\noaggr*.gdx'
$call 'gdxmerge data\noaggr%subdir%\*.gdx output=data\noaggr%subdir%\noaggr.gdx'


*   Retrieve sets:
SET f(*)    Factors,
    t(*)    Accounts,
    i(*)    Institutions
    g(*)    Goods and sectors
    j(*)    Aggregated SAM accounts;

$GDXIN 'data\noaggr%subdir%\%ds1%.gdx'
$load f t i g j

set h(i)    Households
    pub(i)  Public entities
    corp(i) Corporate entities;

$load h pub corp

*   Make state acronyms elements of a set:   

set r(*)    Regions;

$GDXIN 'data\noaggr%subdir%\noaggr.gdx'
$load   r=merged_set_1

alias (s,g) , (h,hh) , (i,ii);

SET mkt /dmkt,ftrd,dtrd/,
    trd(mkt)/ftrd,dtrd/;

PARAMETER
    vom(r,s)    Aggregate output
    vx(r,s)     Aggregate exports

    vdxm(r,s,trd)   Output to export markets
    vdfm(r,g,s) Domestic intermediate demand
    vifm(r,g,trd,s) Imported intermediate demand
    vfm(r,f,s)  Factor demand
    vxm(r,s,trd)    National and international exports
    vx(r,s)     Aggregate exports
    vim(r,g,trd)    Aggregate imports
    vpm(r,h)    Aggregate consumption
    vdpm(r,g,h) Domestic consumption demand
    vipm(r,g,trd,h) Imported consumption demand
    vinv(r)     Aggregate investment
    vdim(r,g)   Domestic investment demand
    viim(r,g,trd)   Imported investment demand
    vgm(r,pub)  Public sector demand
    vdgm(r,g,pub)   Domestic public demand
    vigm(r,g,trd,pub) Imported public demand
    evom(r,f,i,t)   Factor supply,
    evpm(r,g,i) Goods supply (make and export),
    vprf(r,i)   Corporate profit
    vtrn(r,i,t) Transfers
    vdmi(r,s)   Domestic output including institutional imake
    trnsfer(r,i,t,ii)   Inter-institutional transfers;

$load vdxm vdfm vifm vfm vxm vdpm vipm  
$load vdim viim vdgm vigm vprf evom evpm vtrn vdmi trnsfer

vom(r,s) = sum(g,vdfm(r,g,s)) + sum((g,trd),vifm(r,g,trd,s)) + sum(f, vfm(r,f,s));
vim(r,g,trd) = sum(s, vifm(r,g,trd,s)) + sum(h, vipm(r,g,trd,h)) + viim(r,g,trd) 
        + sum(pub, vigm(r,g,trd,pub));
vx(r,s) = sum(trd, vxm(r,s,trd));
vgm(r,pub) = sum(g, vdgm(r,g,pub) + sum(trd, vigm(r,g,trd,pub)));
vinv(r) = sum(g, vdim(r,g) + sum(trd, viim(r,g,trd)));
vpm(r,h) = sum(g,vdpm(r,g,h) + sum(trd, vipm(r,g,trd,h)));

PARAMETER   benchchk    Benchmark consistency check;
benchchk(r,g,"market") = vom(r,g) + sum(i,evpm(r,g,i))
         - sum(s, vdfm(r,g,s))-sum(h,vdpm(r,g,h))-vdim(r,g)-sum(pub,vdgm(r,g,pub))
         - vx(r,g);
benchchk(r,g,"mkt%")$vom(r,g) = benchchk(r,g,"market")/vom(r,g);
DISPLAY benchchk;

PARAMETER   dtrdchk     Cross check on domestic trade flows;
dtrdchk(g,"exports") = sum(r, vxm(r,g,"dtrd"));
dtrdchk(g,"imports") = sum(r, vim(r,g,"dtrd"));
DISPLAY dtrdchk;

display vom;