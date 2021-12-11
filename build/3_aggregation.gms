$IF NOT SET target $SET target medaggr

*       Load previously defined sets:
SET     f(*)    Factors,
        t(*)    Accounts,
        i(*)    Institutions
        g(*)    Goods and sectors
        j(*)    Aggregated SAM accounts;

* original code
*$GDXIN 'data\noaggr%subdir%\%ds1%.gdx'

* when I change it to this from the merge script, I get a dimension mismatch error
*$GDXIN 'data\noaggr%subdir%\noaggr.gdx' 

* Temporarily reading in just alabama just so I can get past this point by fixing the dimension mismatches
$GDXIN 'data\noaggr%subdir%\AL.gdx'
$load f t i g j

SET     h(i)    Households
        pub(i)  Public entities
        corp(i) Corporate entities;

$load h pub corp

SET     r(*)    Regions (states);

$GDXIN 'data\noaggr%subdir%\noaggr.gdx'
$load r=merged_set_1

alias (s,g) , (h,hh) , (i,ii) , (r,rr);

SET     mkt /dmkt,ftrd,dtrd/,
        trd(mkt)/ftrd,dtrd/;

*       Define and load basic parameters:

PARAMETER
        vom(r,s)                Aggregate output
        vx(r,s)                 Aggregate exports
        vdxm(r,s,trd)           Output to export markets
        vdfm(r,g,s)             Domestic intermediate demand
        vifm(r,g,trd,s)         Imported intermediate demand
        vfm(r,f,s)              Factor demand
        vxm(r,s,trd)            National and international exports
        vx(r,s)                 Aggregate exports
        vim(r,g,trd)            Aggregate imports
        vpm(r,h)                Aggregate consumption
        vdpm(r,g,h)             Domestic consumption demand
        vipm(r,g,trd,h)         Imported consumption demand
        vinv(r)                 Aggregate investment
        vdim(r,g)               Domestic investment demand
        viim(r,g,trd)           Imported investment demand
        vgm(r,pub)              Public sector demand
        vdgm(r,g,pub)           Domestic public demand
        vigm(r,g,trd,pub)       Imported public demand
        evom(r,f,i,t)           Factor supply,
        evpm(r,g,i)             Goods supply (make and export),
        vprf(r,i)               Corporate profit
        vtrn(r,i,t)             Transfers
        vdmi(r,s)               Domestic output including institutional imake
        trnsfer(r,i,t,ii)       Inter-institutional transfers;

$load vdxm vdfm vifm vfm vxm vdpm vipm
$load vdim viim vdgm vigm vprf evom evpm vtrn vdmi trnsfer

vom(r,s) = sum(g,vdfm(r,g,s)) + sum((g,trd),vifm(r,g,trd,s)) + sum(f, vfm(r,f,s));
vim(r,g,trd) = sum(s, vifm(r,g,trd,s)) + sum(h, vipm(r,g,trd,h)) + viim(r,g,trd)
                + sum(pub, vigm(r,g,trd,pub));
vx(r,s) = sum(trd, vxm(r,s,trd));
vgm(r,pub) = sum(g, vdgm(r,g,pub) + sum(trd, vigm(r,g,trd,pub)));
vinv(r) = sum(g, vdim(r,g) + sum(trd, viim(r,g,trd)));
vpm(r,h) = sum(g,vdpm(r,g,h) + sum(trd, vipm(r,g,trd,h)));

*       Define target sets for aggregation:
SETS    reg     Map-to regions
        ss      Map-to sectors     
        maps    Sector mapping
        mapr    Region mapping  ;
*       Define sets & mappings:
$include defines\%target%.set
$include defines\%target%.map

ALIAS (gg,ss);

display maps,mapr;

parameter
        chk_map
        chk_agg;

chk_map(s)=sum(ss$maps(ss,s),1) + eps;

chk_agg(ss)=sum(s$maps(ss,s),1);

chk_agg("tot")  = sum(ss, chk_agg(ss));

display chk_map,chk_agg;

loop(s,
abort$(chk_map(s) ne 1) "bad mapping";
);

abort$(sum(ss, chk_agg(ss)) ne card(s)) "bad mapping";

*       Use mapping to load basic parameters:

PARAMETER
        vom_                    Aggregate output
        vx_(reg,ss)             Aggregate exports
        vdxm_(reg,ss,trd)       Output to export markets
        vdfm_(reg,gg,ss)        Domestic intermediate demand
        vifm_(reg,gg,trd,ss)    Imported intermediate demand
        vfm_(reg,f,ss)          Factor demand
        vxm_(reg,ss,trd)        National and international exports
        vx_(reg,ss)             Aggregate exports
        vim_(reg,gg,trd)        Aggregate imports
        vpm_(reg,h)             Aggregate consumption
        vdpm_(reg,gg,h)         Domestic consumption demand
        vipm_(reg,gg,trd,h)     Imported consumption demand
        vinv_(reg)              Aggregate investment
        vdim_(reg,gg)           Domestic investment demand
        viim_(reg,gg,trd)       Imported investment demand
        vgm_(reg,pub)           Public sector demand
        vdgm_(reg,gg,pub)       Domestic public demand
        vigm_(reg,gg,trd,pub)   Imported public demand
        evom_(reg,f,i,t)        Factor supply,
        evpm_(reg,gg,i)         Goods supply (make and export),
        vprf_(reg,i)            Corporate profit
        vtrn_(reg,i,t)          Transfers
        vdmi_(reg,ss)           Domestic output including institutional imake
        trnsfer_(reg,i,t,ii)    Inter-institutional transfers;

vom_(reg,ss) = sum((mapr(reg,r),maps(ss,s)), vom(r,s));
vx_(reg,ss) = sum((mapr(reg,r),maps(ss,s)), vx(r,s));
vdxm_(reg,ss,trd) = sum((mapr(reg,r),maps(ss,s)), vdxm(r,s,trd) );
vdfm_(reg,gg,ss) = sum(mapr(reg,r), sum(g$maps(gg,g), sum(maps(ss,s), vdfm(r,g,s))));
vifm_(reg,gg,trd,ss) = sum(mapr(reg,r),sum(g$maps(gg,g), sum(maps(ss,s), vifm(r,g,trd,s))));
vfm_(reg,f,ss) = sum((mapr(reg,r),maps(ss,s)), vfm(r,f,s));
vxm_(reg,ss,trd) = sum((mapr(reg,r),maps(ss,s)), vxm(r,s,trd));
vim_(reg,gg,trd) = sum((mapr(reg,r),maps(gg,g)), vim(r,g,trd));
vpm_(reg,h) = sum(mapr(reg,r), vpm(r,h));
vdpm_(reg,gg,h) = sum((mapr(reg,r),maps(gg,g)), vdpm(r,g,h));
vipm_(reg,gg,trd,h) = sum((mapr(reg,r),maps(gg,g)), vipm(r,g,trd,h));
vinv_(reg) = sum(mapr(reg,r), vinv(r));
vdim_(reg,gg) = sum((mapr(reg,r),maps(gg,g)), vdim(r,g));
viim_(reg,gg,trd) = sum((mapr(reg,r),maps(gg,g)), viim(r,g,trd));
vgm_(reg,pub) = sum(mapr(reg,r), vgm(r,pub));
vdgm_(reg,gg,pub) = sum((mapr(reg,r),maps(gg,g)), vdgm(r,g,pub));
vigm_(reg,gg,trd,pub) = sum((mapr(reg,r),maps(gg,g)), vigm(r,g,trd,pub));
evom_(reg,f,i,t) = sum(mapr(reg,r), evom(r,f,i,t));
evpm_(reg,gg,i) = sum((mapr(reg,r),maps(gg,g)), evpm(r,g,i));
vprf_(reg,i) = sum(mapr(reg,r), vprf(r,i));
vtrn_(reg,i,t) = sum(mapr(reg,r), vtrn(r,i,t));
vdmi_(reg,ss) = sum((mapr(reg,r),maps(ss,s)), vdmi(r,s));
trnsfer_(reg,i,t,ii) = sum(mapr(reg,r), trnsfer(r,i,t,ii));


*       AGGREGATE EMPLOYMENT COUNT DATA 
PARAMETER empl, lab, lab_con ;
$CALL  'csv2gdx ./Defines/EC_EMP.csv ID=./Data/labor.gdx UseHeader=y index=1 values=2,3' ;
$GDXIN ./data/labor.gdx
$LOAD  lab
$GDXIN ./data/labor.gdx

*$GDXIN ./Data/lab_con.gdx
*$LOAD  lab_con
*$GDXIN

*display lab_con ;
empl(reg,ss) = sum((mapr(reg,r),maps(ss,s)), lab(r,s)) ;

execute_unload 'data\%target%\%target%.gdx', f,t,i,j,gg=g,reg=r,h,pub,corp,vdxm_=vdxm,vdfm_=vdfm,
        vifm_=vifm,vfm_=vfm,vxm_=vxm,vdpm_=vdpm,vipm_=vipm,
        vdim_=vdim,viim_=viim,vdgm_=vdgm,vigm_=vigm,vprf_=vprf,evom_=evom,evpm_=evpm,vtrn_=vtrn,
        vdmi_=vdmi,trnsfer_=trnsfer,vom_=vom,vx_=vx,vim_=vim,vpm_=vpm,vinv_=vinv,vgm_=vgm,
        vprf_=vprf, empl;

$label end


