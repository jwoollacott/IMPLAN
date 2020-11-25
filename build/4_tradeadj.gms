$title  Adjustment program to produce a dataset in which domestic trade flows balance

$if not set target $set target medaggr

*   Define and load source sets:
SET f(*)    Factors,
    t(*)    Accounts,
    i(*)    Institutions
    g(*)    Goods and sectors
    r(*)    Regions
    j(*)    Aggregated SAM accounts;

$GDXIN 'data\%target%\%target%.gdx'
$load f t i g j r

SET h(i)    Households
    pub(i)  Public entities
    corp(i) Corporate entities;

$load h pub corp

alias (s,g) , (h,hh) , (i,ii) , (r,rr);

SET mkt /dmkt,ftrd,dtrd/,
    trd(mkt)/ftrd,dtrd/;

*   Load basic parameters this time with region index:

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
    trnsfer(r,i,t,ii)   Inter-institutional transfers
    empl(*,*)           Employment by region and sector;

$load  vdxm vdfm vifm vfm vxm vdpm vipm vdim viim vdgm vigm vprf evom evpm vtrn 
$load  vom vim vx vgm vinv vpm vdmi trnsfer empl

*   Check if domestic trade flows balance:

PARAMETER   dtrdchk     Cross check on domestic trade flows;
dtrdchk(g,"dtrd") = sum(r, vxm(r,g,"dtrd") - vim(r,g,"dtrd"));
DISPLAY dtrdchk;

parameter chk_adj;

chk_adj(r,g,"m_dtrd_pre")   = vim(r,g,"dtrd");
chk_adj(r,g,"m_ftrd_pre")   = vim(r,g,"ftrd");

chk_adj(r,g,"x_dtrd_pre")   = vxm(r,g,"dtrd");
chk_adj(r,g,"x_ftrd_pre")   = vxm(r,g,"ftrd");

*   Adjust trade data to produce a dataset in which domestic trade flows balance:

PARAMETER   mchk    Cross check of import markets
        id  Identifier;

*   Identify commodities for which the sum of domestic exports or imports
*   is zero:
        
id(g,"vxm") = yes$(sum(r,vxm(r,g,"dtrd")) eq 0);
id(g,"vim") = yes$(sum(r,vim(r,g,"dtrd")) eq 0);

*   Correction factor for commodities markets which have a non-zero total
*   domestic exports and imports:

LOOP(g$(not id(g,"vxm") and not id(g,"vim")),
mchk(g) = sum(r,vim(r,g,"dtrd"))/sum(r,vxm(r,g,"dtrd"));
);

*   When mchk(g) < 1, then domestic exports exceed domestic imports.
*   The solution is to proportionally reduce domestic exports and 
*   increase international exports, holding aggregate exports constant.

LOOP(g$(0 < mchk(g)  and mchk(g) < 1),
    vxm(r,g,"dtrd") = mchk(g)*vxm(r,g,"dtrd");
    vxm(r,g,"ftrd") = vxm(r,g,"ftrd") + vxm(r,g,"dtrd") * (1/mchk(g) - 1);
);

*   When mchk(g) > 1, then domestic imports exceed domestic exports.
*   We then proportionally reduce domestic imports and increase
*   international imports, so that aggregate imports remain constant.

vim(r,g,"dtrd")$(mchk(g) gt 1) = vim(r,g,"dtrd")/mchk(g);
vim(r,g,"ftrd")$(mchk(g) gt 1) = vim(r,g,"ftrd") + vim(r,g,"dtrd") * (mchk(g) - 1);

*   Balance domestic trade flows for commodities for which either total
*   domestic imports or exports are zero (ie if id(g)=yes):

LOOP(g$(id(g,"vxm") and not id(g,"vim")),
vim(r,g,"dtrd")$(sum(rr, vxm(rr,g,"dtrd") le vim(rr,g,"dtrd")))
             = vim(r,g,"dtrd") 
             + (sum(rr, vxm(rr,g,"dtrd") - vim(rr,g,"dtrd")))
                * 1/card(r);    
vim(r,g,"ftrd")$(sum(rr, vxm(rr,g,"dtrd") le vim(rr,g,"dtrd"))) 
             = vim(r,g,"ftrd") 
             - (sum(rr, vxm(rr,g,"dtrd") - vim(rr,g,"dtrd")))
       * (vxm(r,g,"dtrd") - vim(r,g,"dtrd"))/(sum(rr, vxm(rr,g,"dtrd") - vim(rr,g,"dtrd")));
);

LOOP(g$(id(g,"vim") and not id(g,"vxm")),
vxm(r,g,"dtrd")$(sum(rr, vxm(rr,g,"dtrd") ge vim(rr,g,"dtrd")))
             = vxm(r,g,"dtrd") 
             - (sum(rr, vxm(rr,g,"dtrd") - vim(rr,g,"dtrd")))
                * 1/card(r);    
vxm(r,g,"ftrd")$(sum(rr, vxm(rr,g,"dtrd") ge vim(rr,g,"dtrd"))) 
             = vxm(r,g,"ftrd") 
             + (sum(rr, vxm(rr,g,"dtrd") - vim(rr,g,"dtrd")))
       * (vxm(r,g,"dtrd") - vim(r,g,"dtrd"))/(sum(rr, vxm(rr,g,"dtrd") - vim(rr,g,"dtrd")));
);

*   Recalibrate aggregate exports:

vx(r,s) = sum(trd, vxm(r,s,trd));

PARAMETER mktchk;
mktchk(g,"dtrd") = sum(r, vxm(r,g,"dtrd") - vim(r,g,"dtrd"));
DISPLAY mktchk;

abort$(smax(s, abs(mktchk(s,"dtrd"))) gt 1.e-5) "Error -- domestic markets are not in balance";


chk_adj(r,g,"m_dtrd_post")  = vim(r,g,"dtrd");
chk_adj(r,g,"m_ftrd_post")  = vim(r,g,"ftrd");

chk_adj(r,g,"x_dtrd_post")  = vxm(r,g,"dtrd");
chk_adj(r,g,"x_ftrd_post")  = vxm(r,g,"ftrd");
  
display chk_adj;

execute_unload 'data\%target%\%target%_dtrdbal.gdx', f,t,i,j,g,r,h,pub,corp,vdxm,vdfm,
    vifm,vfm,vxm,vdpm,vipm,vdim,viim,vdgm,vigm,vprf,evom,evpm,vtrn,
    vom,vim,vx,vgm,vinv,vpm,vdmi,trnsfer, empl;
