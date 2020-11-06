$TITLE  Aggregate ADAGE Model data to Census regions and aggregated industries

$if not set target $set target ADAGE

$INCLUDE ./defines/regions.gms  


* Aggregated items
set i /

*   Households
    HH  Households

*   Government agent
    gov Government

*   Energy
    COL Coal
    CRU Crude
    ELE Electric generation
    GAS Natural Gas Production and Distribution
    OIL Refined Petroleum

*------ INDUSTRIAL categories ------*
    AGR "Agriculture"
    FOO "Food and Kindred Products"
    PPP "Paper and Printing"
    NMM "Non-metallic minerals"
    CHM "Chemical and Allied Products"
    I_S "Iron and Steel Mills and Products"
    NFM "Non-ferrous metals"
    MAN "Manufacturing"

*------ SERVICE categories ------*
    SRV "Services"
    TRN "Transportation" 
/;


* All items
set ii /

gov

    hhl      Households LT10k    (10001)
    hh10     Households 10-15k   (10002)
    hh15     Households 15-25k   (10003)
    hh25     Households 25-35k   (10004)
    hh35     Households 35-50k   (10005)
    hh50     Households 50-75k   (10006)
    hh75     Households 75-100k  (10007)
    hh100    Households 100-150k (10008)
    hh150    Households 150k+    (10009)

*   Energy
    COL Coal
    CRU Crude
    ELE Electric generation
    GAS Natural Gas Production and Distribution
    OIL Refined Petroleum

*------ INDUSTRIAL categories ------*
    AGR "Agriculture"
    FOO "Food and Kindred Products"
    PPP "Paper and Printing"
    NMM "Non-metallic minerals"
    CHM "Chemical and Allied Products"
    I_S "Iron and Steel Mills and Products"
    NFM "Non-ferrous metals"
    MAN "Manufacturing"

*------ SERVICE categories ------*
    SRV "Services"
    TRN "Transportation" 
/;

set hhi(ii) /
    hhl      Households LT10k    (10001)
    hh10     Households 10-15k   (10002)
    hh15     Households 15-25k   (10003)
    hh25     Households 25-35k   (10004)
    hh35     Households 35-50k   (10005)
    hh50     Households 50-75k   (10006)
    hh75     Households 75-100k  (10007)
    hh100    Households 100-150k (10008)
    hh150    Households 150k+    (10009) /

    hh(i)   / hh /;

set mkt /ftrd,dtrd/,
    trd(mkt)/ftrd,dtrd/;


set s(i)    /
*   Energy
    COL Coal
    CRU Crude
    ELE Electric generation
    GAS Natural Gas Production and Distribution
    OIL Refined Petroleum

*------ INDUSTRIAL categories ------*
    AGR "Agriculture"
    FOO "Food and Kindred Products"
    PPP "Paper and Printing"
    NMM "Non-metallic minerals"
    CHM "Chemical and Allied Products"
    I_S "Iron and Steel Mills and Products"
    NFM "Non-ferrous metals"
    MAN "Manufacturing"

*------ SERVICE categories ------*
    SRV "Services"
    TRN "Transportation" 

    gov
/;

set mapS(s,ii) /
    COL.COL
    CRU.CRU
    ELE.ELE
    GAS.GAS
    OIL.OIL
    
    AGR.AGR
    FOO.FOO
    PPP.PPP
    NMM.NMM
    CHM.CHM
    I_S.I_S
    NFM.NFM
    MAN.MAN

    SRV.SRV
    TRN.TRN

    gov.gov
/;

set mapG(s,ii); mapG(s,ii) = mapS(s,ii);

set mapHH(hh,hhi) /
    HH.(hhl,hh10,hh15,hh25,hh35,hh50,hh75,hh100,hh150)/;


alias (s,g), (ii,iii);

*   Load basic parameters this time with region index:
PARAMETERS
    y0_         Industry supply ($billion)
    id0_            Intermediate demand ($ billion)
    ld0_            Labor demand ($ billion)
    kd0_            Capital demand ($ billion)

    a0_         Armington goods ($billion)
    x0_         Export goods ($billion)
    m0_         Import goods ($billion)
    i0_         Investment goods ($billion)

    ty_         Output tax rate (%)
    tl_         Labor tax rate (%)
    tk_         Capital tax rate (%)

    pld0_           Reference price for labor
    pkd0_           Reference price for capital

    le0_            Labor endowment ($billion)
    ke0_            Capital endowment ($billion)
    vke0_           Value of capital endowment ($billion)
    bopdef_         Balance of payments deficit ($billion)
    lstax_          Lump-sum tax ($billion) 
    evpm_           Goods supply (make and export) - SLOP FACTOR TO BE REMOVED ;

$gdxin 'data\%target%\IMPLAN_data.gdx'
$load y0_=y0 id0_=id0 ld0_=ld0 kd0_=kd0 a0_=a0 x0_=x0 m0_=m0 i0_=i0 ty_=ty tl_=tl tk_=tk pld0_=pld0 pkd0_=pkd0 le0_=le0 ke0_=ke0 vke0_=vke0 bopdef_=bopdef lstax_=lstax evpm_ 

*   Load basic parameters this time with region index:
PARAMETERS
    y0(r,*)         Industry supply ($billion)
    id0(r,*,g)      Intermediate demand ($ billion)
    ld0(r,s)        Labor demand ($ billion)
    kd0(r,s)        Capital demand ($ billion)

    a0(r,s)         Armington goods ($billion)
    x0(r,s,trd)     Export goods ($billion)
    m0(r,s,trd)     Import goods ($billion)
    i0(r,s)         Investment goods ($billion)

    ty(r,*)         Output tax rate (%)
    tl(r,s)         Labor tax rate (%)
    tk(r,s)         Capital tax rate (%)

    pld0(r,s)       Reference price for labor
    pkd0(r,s)       Reference price for capital

    le0(r,*)        Labor endowment ($billion)
    ke0(r)          Capital endowment ($billion)
    vke0(r,*)       Value of capital endowment ($billion)
    bopdef          Balance of payments deficit ($billion)
    lstax(r)        Lump-sum tax ($billion) 
    evpm(r,g)       Goods supply (make and export) - SLOP FACTOR TO BE REMOVED ;


*   Rescale data from 2013 to 2015 based on balanced growth and inflation (to 2015$)
SCALAR  scale   ;
    scale = 1.1025 * 1.02572  ;


y0(r,s)     = sum(mapCENSUS(r,st), sum(mapS(s,ii), y0_(st,ii))) * scale ;
id0(r,s,g)  = sum(mapCENSUS(r,st), sum(mapS(s,ii), sum(mapG(g,iii), id0_(st,ii,iii)))) * scale ;
ld0(r,s)    = sum(mapCENSUS(r,st), sum(mapS(s,ii), ld0_(st,ii))) * scale ;
kd0(r,s)    = sum(mapCENSUS(r,st), sum(mapS(s,ii), kd0_(st,ii))) * scale ;

a0(r,s)     = sum(mapCENSUS(r,st), sum(mapS(s,ii), a0_(st,ii)))     * scale ;
x0(r,s,trd) = sum(mapCENSUS(r,st), sum(mapS(s,ii), x0_(st,ii,trd))) * scale ;
m0(r,s,trd) = sum(mapCENSUS(r,st), sum(mapS(s,ii), m0_(st,ii,trd))) * scale ;
i0(r,s)     = sum(mapCENSUS(r,st), sum(mapS(s,ii), i0_(st,ii)))     * scale ;

ty(r,s)$sum(mapCENSUS(r,st), sum(mapS(s,ii), y0_(st,ii)))   = sum(mapCENSUS(r,st), sum(mapS(s,ii), ty_(st,ii)*y0_(st,ii))) / sum(mapCENSUS(r,st), sum(mapS(s,ii), y0_(st,ii)))  ;
tl(r,s)$sum(mapCENSUS(r,st), sum(mapS(s,ii), ld0_(st,ii)))  = sum(mapCENSUS(r,st), tl_(st)*sum(mapS(s,ii), ld0_(st,ii))) / sum(mapCENSUS(r,st), sum(mapS(s,ii), ld0_(st,ii)))   ;
tk(r,s)$sum(mapCENSUS(r,st), sum(mapS(s,ii), kd0_(st,ii)))  = sum(mapCENSUS(r,st), tk_(st)*sum(mapS(s,ii), kd0_(st,ii))) / sum(mapCENSUS(r,st), sum(mapS(s,ii), kd0_(st,ii)))   ;

pld0(r,s)   = 1 + tl(r,s);
pkd0(r,s)   = 1 + tk(r,s);

*   [JWE]: Added hhi
le0(r,hh)   = sum(mapCENSUS(r,st), sum(mapHH(hh,hhi), le0_(st,hhi))) * scale ;
le0(r,hhi)  = sum(mapCENSUS(r,st), le0_(st,hhi)) * scale ;

ke0(r)      = sum(mapCENSUS(r,st), ke0_(st)) * scale ;

*   [JWE]: Added hhi
vke0(r,hh)  = sum(mapCENSUS(r,st), sum(mapHH(hh,hhi), vke0_(st,hhi))) * scale ;
vke0(r,hhi) = sum(mapCENSUS(r,st), vke0_(st,hhi)) * scale ;

lstax(r)    = sum(mapCENSUS(r,st), lstax_(st)) * scale ;
evpm(r,s)   = sum(mapCENSUS(r,st), sum(mapS(s,ii), evpm_(st,ii))) * scale ;

*   [JWE]: Added hhi
y0(r,hh)    = sum(mapCENSUS(r,st), sum(mapHH(hh,hhi), y0_(st,hhi))) * scale ;
y0(r,hhi)   = sum(mapCENSUS(r,st), y0_(st,hhi)) * scale ;

id0(r,hh,g) = sum(mapCENSUS(r,st), sum(mapHH(hh,hhi), sum(mapG(g,iii), id0_(st,hhi,iii)))) * scale ;
id0(r,hhi,g)= sum(mapCENSUS(r,st), sum(mapG(g,iii), id0_(st,hhi,iii))) * scale ;

y0(r,"gov")     = sum(mapCENSUS(r,st), y0_(st,"gov")) * scale ;
id0(r,"gov",g)  = sum(mapCENSUS(r,st), sum(mapG(g,iii), id0_(st,"gov",iii))) * scale ;

bopdef      = bopdef_ * scale ;


set coms(s)     /srv/ 
    inds(s)     /col,cru,ele,gas,oil, AGR,FOO,PPP,NMM,CHM,I_S,NFM,MAN /
    trns(s)     /TRN/
    govi(i)     /gov/
    ;


*   Run model to test data
$ONTEXT
$model:cge

$sectors:
    RES(r,hh)$y0(r,hh)          ! Residential (household) consumption
    COM(r,s)$(y0(r,s) and coms(s))      ! Commercial sector output
    IND(r,s)$(y0(r,s) and inds(s))      ! Industrial sector output
    TRN(r,s)$(y0(r,s) and trns(s))      ! Transportation sector output
    GOV(r)$y0(r,"gov")          ! Government sector output
    A(r,g)$a0(r,g)              ! Armington goods

$commodities:
    py(r,i)$((y0(r,i) and g(i)) or hh(i) or govi(i))    ! Price of sector output
    pl(r)               ! Price of labor
    rk(r)               ! Price of capital rental
    pa(r,g)$a0(r,g)         ! Price of Armington good
    pfx             ! Price of foreign exchange
    pvk

$consumers:
    RH(r,hh)            ! Representative household
    GOVT(r)             ! Government agent
    NYSE                ! New York Stock Exchange (national capital markets)

*   Residential (household) consumption of goods:

$prod:RES(r,hh)     s:1
    o:py(r,hh)      q:y0(r,hh)
    i:pa(r,g)       q:id0(r,hh,g)

*   Commercial sector output:

$prod:COM(r,s)$(y0(r,s) and coms(s))    s:1
    o:py(r,s)       q:y0(r,s)       a:govt(r)               t:ty(r,s)
    i:pa(r,g)       q:id0(r,s,g)
    i:pl(r)         q:ld0(r,s)      a:govt(r)   p:pld0(r,s)     t:tl(r,s)
    i:rk(r)         q:kd0(r,s)      a:govt(r)   p:pkd0(r,s)     t:tk(r,s)

*   Industrial sector output:

$prod:IND(r,s)$(y0(r,s) and inds(s))    s:1
    o:py(r,s)       q:y0(r,s)       a:govt(r)               t:ty(r,s)
    i:pa(r,g)       q:id0(r,s,g)
    i:pl(r)         q:ld0(r,s)      a:govt(r)   p:pld0(r,s)     t:tl(r,s)
    i:rk(r)         q:kd0(r,s)      a:govt(r)   p:pkd0(r,s)     t:tk(r,s)

*   Transportation sector output:

$prod:TRN(r,s)$(y0(r,s) and trns(s))    s:1
    o:py(r,s)       q:y0(r,s)       a:govt(r)               t:ty(r,s)
    i:pa(r,g)       q:id0(r,s,g)
    i:pl(r)         q:ld0(r,s)      a:govt(r)   p:pld0(r,s)     t:tl(r,s)
    i:rk(r)         q:kd0(r,s)      a:govt(r)   p:pkd0(r,s)     t:tk(r,s)

*   Government demand:

$prod:GOV(r)$y0(r,"gov")    s:1
    o:py(r,"gov")   q:y0(r,"gov")
    i:pa(r,g)       q:id0(r,"gov",g)
    i:pl(r)         q:ld0(r,"gov")      a:govt(r)   p:pld0(r,"gov")     t:tl(r,"gov")
    i:rk(r)         q:kd0(r,"gov")      a:govt(r)   p:pkd0(r,"gov")     t:tk(r,"gov")

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
    e:pa(r,g)       q:evpm(r,g)
    
$offtext
$sysinclude mpsgeset cge


cge.iterlim = 0;
cge.workspace = 1000;
$include cge.gen
solve cge using mcp;

* relabel household data to match ADAGE (not DIEM)

PARAMETERS
    c0  total household consumption
    cd0 household consumption demand by good
    le1 labor endowment of households
    vke1    value of capital endowment of households;

c0(r,hh)        = y0(r,hh);
c0(r,hhi)       = y0(r,hhi);
cd0(r,hh,g)     = id0(r,hh,g);
cd0(r,hhi,g)    = id0(r,hhi,g);

y0(r,hh)        = 0;
y0(r,hhi)       = 0;
id0(r,hh,g)     = 0;
id0(r,hhi,g)    = 0;

le1(r,hhi)      = le0(r,hhi);
vke1(r,hhi)     = vke0(r,hhi);


execute_unload '.\Data\%target%\%target%_data.gdx',
    y0
    id0
    ld0
    kd0
    c0
    cd0
    ty
    tl
    tk
    pld0
    pkd0
    a0
    m0
    le1=le0
    vke1=vke0
    ke0
    bopdef
    lstax
    x0
    i0
    evpm;

execute 'rm CGE.gen' ;

