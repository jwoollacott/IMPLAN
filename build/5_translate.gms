$title  Translate GTAP notation into SAM notation
$if not set target $set target medaggr

$oninline

*   Define and load source sets:
SET f(*)    Factors,
    ins(*)  institutions
    t(*)    Accounts,
    g(*)    Goods and sectors
    r(*)    Regions
    j(*)    Aggregated SAM accounts ;

$GDXIN 'data\%target%\%target%_dtrdbal.gdx'
$load f ins=i t g j r

SET h(*)        Households
    pub(ins)    Public entities
    corp(ins)   Corporate entities;

$load h pub corp
display h ;

alias (s,g) , (h,hh) , (r,rr), (ins,iins);

SET mkt         /dmkt,ftrd,dtrd/,
    trd(mkt)    /ftrd,dtrd/;

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
    evom(r,f,*,t)   Factor supply,
    evpm(r,g,ins)   Goods supply (make and export),
    vprf(r,ins) Corporate profit
    vtrn(r,ins,t)   Transfers
    vdmi(r,s)   Domestic output including institutional imake
    trnsfer(r,ins,t,iins)   Inter-institutional transfers
    empl(*,*)   Employment by region and sector     ;

$load  vdxm vdfm vifm vfm vxm vdpm vipm vdim viim vdgm vigm vprf evom evpm vtrn 
$load  vom vim vx vgm vinv vpm vdmi trnsfer empl

parameter chk_mktbal, chk_imp/*, chk_trns*/, chk_evpm2imp,chk_evpm2vom, chk_evpm2vomK/*, chk_pip*/;


chk_mktbal(r,g) = round(
      vom(r,g) 
    + sum(trd, vim(r,g,trd)) 
    + sum(ins, evpm(r,g,ins))
    - sum(trd, vxm(r,g,trd))
    - sum(s, vdfm(r,g,s) + sum(trd, vifm(r,g,trd,s)) )
    - sum(hh, vdpm(r,g,hh)+sum(trd,vipm(r,g,trd,hh)))
    - sum(pub, vdgm(r,g,pub)+sum(trd,vigm(r,g,trd,pub)))
    - vdim(r,g) 
    - sum(trd, viim(r,g,trd))
    , 3);



*benchchk(g,"market") = vom(g) + sum(i,evpm(g,i))
*        - sum(s, vdfm(g,s))-sum(h,vdpm(g,h))-vdim(g)-sum(pub,vdgm(g,pub))
*        - vx(g);


chk_imp(r,g) = round(
    + sum(trd, vim(r,g,trd)) 
    - sum(s, sum(trd, vifm(r,g,trd,s)) )
    - sum(hh, sum(trd,vipm(r,g,trd,hh)))
    - sum(pub, sum(trd,vigm(r,g,trd,pub)))
    - sum(trd, viim(r,g,trd))
    , 3);

$ontext
chk_trns(r,g)$( vom(r,g) + sum(trd, vim(r,g,trd)) )
     = 100 * round(
     sum(ins, evpm(r,g,ins))
    / ( vom(r,g) + sum(trd, vim(r,g,trd)) + sum(ins, evpm(r,g,ins)))
    , 3);
chk_trns(r,g)$(abs(chk_trns(r,g)) lt 2) = 0;
$offtext

chk_evpm2imp(r,g)$(sum(trd, vim(r,g,trd)) )
     = 100 * round(
     sum(ins, evpm(r,g,ins))
    / sum(trd, vim(r,g,trd))
    , 3);

chk_evpm2imp(r,g)$(abs(chk_evpm2imp(r,g)) lt 2) = 0;

chk_evpm2vom(r,g)$vom(r,g)
     = 100 * round(
     sum(ins, evpm(r,g,ins))
    / vom(r,g)
    , 3);

chk_evpm2vom(r,g)$(abs(chk_evpm2vom(r,g)) lt 10)    = 0;

chk_evpm2vomK(r,g)$(vfm(r,"prop",g) + vfm(r,"othp",g))
     = 100 * round(
     sum(ins, evpm(r,g,ins))
    / (vfm(r,"prop",g) + vfm(r,"othp",g))
    , 3);

chk_evpm2vomK(r,g)$(abs(chk_evpm2vomK(r,g)) lt 5)   = 0;

*chk_pip(r,f)   = vfm(r,f,"pip");
*chk_pip(r,"vom") = vom(r,"pip");

* option chk_trns:0;
option chk_evpm2imp:0;
option chk_evpm2vom:0;
option chk_evpm2vomK:0;
display vom/*,chk_mktbal,chk_imp,chk_evpm2imp,chk_evpm2vom,chk_evpm2vomK*/;

*   Define economic variables in CGE model:

parameter
    y0(r,*)         Industry supply ($billion)
    id0(r,g,*)      Intermediate demand ($ billion)
    ld0(r,*)        Labor demand ($ billion)
    kd0(r,*)        Capital demand ($ billion)

    a0(r,s)         Armington goods ($billion)
    d0(r,s)         Domestic goods production ($billion)
    x0(r,s,trd)     Export goods ($billion)
    n0(r,s)         National-market goods ($billion)
    m0(r,s,trd)     Import goods ($billion)
    i0(r,s)         Investment goods ($billion)
    w0(r)           Welfare (Hicksian EV)

    ty(r,*)         Output tax rate (%)
    tl(r)           Labor tax rate (%)
    tk(r)           Capital tax rate (%)

    pld0(r,*)       Reference price for labor
    pkd0(r,*)       Reference price for capital

    le0(r,hh)       Labor endowment ($billion)
    ke0(r)          Capital endowment ($billion)
    vke0(r,hh)      Value of capital endowment ($billion)
    bopdef          Balance of payments deficit ($billion)
    lstax(r)        Lump-sum tax ($billion) ;

$ontext
set coms(s)     /srv,pub/ 
    inds(s)     /col,cru,ele,gas,oil, AGR,FOO,PPP,NMM,CHM,I_S,NFM,MAN /
    trns(s)     /TRN/
    govs(s)     /pub/
    pubs(s)     /pub/;
$offtext

set govins(ins) /fnd,fdf,fin,sln,sle,sin/
    govi(*)     /gov/
    ss(t)       /
        sstw    "Social Ins Tax- Employee Contribution (15014)"
        sstf    "Social Ins Tax- Employer Contribution (15015)" /
    lab(t)      /
        ncmp    "Emp Comp (Wages/Salary w/o Soc Sec) (15002)"
        ecmp    "Employee Comp (Other Labor Income) (15003)"    /
    kap(t)      /
        prop    "Proprietors Inc (w/o Soc Sec & CCA) (15004)"
        rent    "Rent with Capital Consumption Adj (15005)"
        btrn    "Business Transfers (15006)"
        nint    "Interest (Net-from Industries) (15008)"        
        gint    "Interest (Gross)"        
    /
    ;


*-- Relabel GTAP variables --*

* Production

id0(r,g,s)      = vdfm(r,g,s) + sum(trd, vifm(r,g,trd,s));
ld0(r,s)        = vfm(r,"empl",s);
kd0(r,s)        = vfm(r,"prop",s) + vfm(r,"othp",s);
y0(r,s)         = vom(r,s);

ty(r,s)$vom(r,s)    = vfm(r,"btax",s) / vom(r,s);
ty(r,s)$y0(r,s)     = vfm(r,"btax",s) / y0(r,s);

* Social security taxes
tl(r)           = sum((ss,govins), evom(r,"empl",govins,ss)+evom(r,"prop",govins,ss)) / sum(s,ld0(r,s));
pld0(r,s)       = 1 + tl(r);
ld0(r,s)        = ld0(r,s) / pld0(r,s);
tk(r)           = 0;
pkd0(r,s)       = 1 + tk(r);
kd0(r,s)        = kd0(r,s) / pkd0(r,s);

* Households
id0(r,g,hh)     = vdpm(r,g,hh)+sum(trd,vipm(r,g,trd,hh));
y0(r,hh)        = sum(g, id0(r,g,hh));
display y0;

* Government
id0(r,g,"gov")      = sum(pub, vdgm(r,g,pub)+sum(trd,vigm(r,g,trd,pub)));
pld0(r,"gov")       = 1 + tl(r);
pkd0(r,"gov")       = 1;

y0(r,"gov")     = sum(g, id0(r,g,"gov")) + ld0(r,"gov")*pld0(r,"gov") + kd0(r,"gov")*pkd0(r,"gov");


* trade
x0(r,g,trd)     = vxm(r,g,trd);
m0(r,g,trd)     = vim(r,g,trd);
a0(r,g)         = y0(r,g) + sum(trd, m0(r,g,trd));


parameter chk_trd/*,chk_neg,chk_gov*/,chk_govinp, chk_gov2evpm;

chk_trd(g)      = sum(r, x0(r,g,"dtrd")) - sum(r, m0(r,g,"dtrd"));
display a0,x0,m0,chk_trd;

chk_gov2evpm(r,g,pub)$id0(r,g,"gov")    = 100 * evpm(r,g,pub) / id0(r,g,"gov");

display id0, chk_gov2evpm;


*chk_govinp(g,"demand")  = sum(pub, vdgm("ca",g,pub)+sum(trd,vigm("ca",g,trd,pub)));
chk_govinp(g,"demand")  =  0;

option chk_govinp:1;
display chk_govinp;

* endowments
parameter le0_shr   ;
le0_shr(r,hh)$sum(hh.local, sum(lab, evom(r,"empl",hh,lab)))
    = sum(lab, evom(r,"empl",hh,lab)) / sum(hh.local, sum(lab, evom(r,"empl",hh,lab)));

le0(r,hh)       = le0_shr(r,hh) * (sum(s, ld0(r,s)) + ld0(r,"gov")) ;
* ndw_diffs("LAB",r,hh)  = le0_evom(r,hh) - le0(r,hh)        ;

ke0(r)          = sum(s, kd0(r,s)) + kd0(r,"gov");

vke0(r,hh)      = y0(r,hh) - le0(r,hh);
bopdef          = sum((r,g,trd), m0(r,g,trd)-x0(r,g,trd));

* investment
i0(r,g)         = vdim(r,g) + sum(trd, viim(r,g,trd));
display i0,y0   ;

* redefine EVPM to balance markets (fix when combine with energy)
*   - add to domestic output and scale inputs (too big a problem to fix through trade)
evpm(r,g,ins)   = 0;

evpm(r,g,"sln") = - (
      y0(r,g)
    + sum(trd, m0(r,g,trd))
    - sum(s, id0(r,g,s))
    - id0(r,g,"gov")
    - sum(hh, id0(r,g,hh))
    - sum(trd, x0(r,g,trd))
    - i0(r,g)
    );

lstax(r)    
    = y0(r,"gov")
    - sum((g,ins), evpm(r,g,ins))
    - sum(s, tl(r) * ld0(r,s))
    - tl(r) * ld0(r,"gov")
    - sum(s, tk(r) * kd0(r,s))
    - tk(r) * kd0(r,"gov")
    - sum(s, ty(r,s) * y0(r,s))
;

parameter
    evpm_ ;

evpm_(r,g)  = sum(ins, evpm(r,g,ins));
set pys / "GOV", set.g, set.hh /;

*   Run model to test data
$ONTEXT
$model:cge

$sectors:
    RES(r,hh)$y0(r,hh)              ! Residential (household) consumption
    y(r,s)$y0(r,s)                  ! Commercial sector output
*    IND(r,s)$(y0(r,s) and inds(s))     ! Industrial sector output
*    TRN(r,s)$(y0(r,s) and trns(s))     ! Transportation sector output
    GOV(r)$y0(r,"gov")              ! Government sector output
    A(r,g)$a0(r,g)                  ! Armington goods

$commodities:
    py(r,pys)$y0(r,pys) ! Price of sector output
    pl(r)               ! Price of labor
    rk(r)               ! Price of capital rental
    pa(r,g)$a0(r,g)     ! Price of Armington good
    pfx                 ! Price of foreign exchange
    pvk

$consumers:
    RH(r,hh)            ! Representative household
    GOVT(r)             ! Government agent
    NYSE                ! New York Stock Exchange (national capital markets)

*   Residential (household) consumption of goods:

$prod:RES(r,hh)     s:1
    o:py(r,hh)      q:y0(r,hh)
    i:pa(r,g)       q:id0(r,g,hh)

*   Commercial sector output:

$prod:y(r,s)$y0(r,s)    s:1
    o:py(r,s)       q:y0(r,s)       a:govt(r)                   t:ty(r,s)
    i:pa(r,g)       q:id0(r,g,s)
    i:pl(r)         q:ld0(r,s)      a:govt(r)   p:pld0(r,s)     t:tl(r)
    i:rk(r)         q:kd0(r,s)      a:govt(r)   p:pkd0(r,s)     t:tk(r)

$prod:GOV(r)$y0(r,"gov")    s:1
    o:py(r,"gov")       q:y0(r,"gov")
    i:pa(r,g)       q:id0(r,g,"gov")
    i:pl(r)         q:ld0(r,"gov")      a:govt(r)   p:pld0(r,"gov")     t:tl(r)
    i:rk(r)         q:kd0(r,"gov")      a:govt(r)   p:pkd0(r,"gov")     t:tk(r)

*   Armington aggregation of domestic goods and imports:
$prod:A(r,g)$a0(r,g)        s:1
    o:pa(r,g)       q:a0(r,g)
    i:py(r,g)       q:y0(r,g)
    i:pfx           q:(sum(trd,m0(r,g,trd)))

*   Expenditure and Income of Representative Households:
$demand:RH(r,hh)
* expenditures
    d:py(r,hh)      q:y0(r,hh)
* income
    e:pl(r)         q:le0(r,hh)
    e:pvk           q:vke0(r,hh)

*   New York Stock Exchange
$demand:NYSE
    d:pvk           q:(sum((r,hh),vke0(r,hh)))
* capital
    e:rk(r)         q:ke0(r)
* balance of payments deficit
    e:pfx           q:bopdef
* lump-sum tax to balance government revenues
    e:pfx           q:(-sum(r, lstax(r)))
* exogenous exports of goods
    e:pa(r,g)       q:(-sum(trd, x0(r,g,trd)))
    e:pfx           q:(sum((r,g,trd), x0(r,g,trd)))
* exogenous investment demand
    e:pa(r,g)       q:(-i0(r,g))


*   Expenditure (and Income) of Government Agent:

$demand:GOVT(r)
    d:py(r,"gov")   q:y0(r,"gov")
    e:pfx           q:lstax(r)
    e:pa(r,g)       q:evpm_(r,g)
    
$OFFTEXT
$sysinclude mpsgeset cge

cge.iterlim = 0;
cge.workspace = 1000;
$include cge.gen
solve cge using mcp;

cge.iterlim = 1e3;
$include cge.gen
solve cge using mcp;

parameter   FD0     final demand 
            VA0     value add   ;

set         fdcol   / set.hh, inv, gov, gove, exd, exf, imd, imf /
            varow   / lab, kap, tax / ;

FD0(r,g,hh)         = id0(r,g,hh)   ;
FD0(r,g,"INV")      = i0(r,g)       ;
FD0(r,g,"GOV")      = id0(r,g,"gov");
FD0(r,g,"GOVe")     = -evpm_(r,g)   ;
FD0(r,g,"EXD")      = x0(r,g,"dtrd");
FD0(r,g,"EXF")      = x0(r,g,"ftrd");
FD0(r,g,"IMD")      = -m0(r,g,"dtrd");
FD0(r,g,"IMF")      = -m0(r,g,"ftrd");

VA0(r,"lab",g)     = ld0(r,g)      ;
VA0(r,"lab","GOV") = ld0(r,"GOV")  ;
VA0(r,"kap",g)     = kd0(r,g)      ;
VA0(r,"kap","GOV") = kd0(r,"GOV")  ;
VA0(r,"tax",s)     = ty(r,s) * y0(r,s) + tl(r) * ld0(r,s) + tk(r) * kd0(r,s) ;
VA0(r,"tax","GOV") = tl(r) * ld0(r,"GOV") + tk(r) * kd0(r,"GOV") ;

execute_unload './data/%target%/IMPLAN_data_%target%.gdx', ID0, FD0, VA0, r, g, h, fdcol, varow, empl ;

