$TITLE   Translate the IMPLAN SOE Framework into GTAP-Style Data Structures

$if not set tol $set tol 9
$if not set ds $set ds ak
$if not set subdir $set subdir \WA_county

scalar tol  Tolerance parameter for filtering data /1e-%tol%/;

$ontext

This program reads an IMPLAN dataset for a single state and

    (i)  verifies IMPLAN dataset identities
    (ii) interprets the resulting data in the form of a 
         highly simplified general equilibrium model formulated
         with MPSGE
    (iii) outputs the dataset to an mrn datafile
    

$offtext

SET f(*)    Factors,
    t(*)    Accounts,
    i(*)    Institutions
    j(*)    Aggregated SAM accounts;

$GDXIN '.\Data\tempdata\%ds%.gdx'
$load f t i j

SET g(t)    Sectors and commodities;
$load g 

SET mkt /dmkt,ftrd,dtrd/,
    trd(mkt)/ftrd,dtrd/;

ALIAS (i,ii), (trd,ttrd), (g,s,gg,ss), (f,ff), (t,tt);

PARAMETER
    output(s,mkt)   Domestic industry make matrix
    use(g,t,s)  Industry use matrix
    iuse(g,t,i) Institutional use matrix
    fd(f,t,s)   Industry use of factors
    imake(i,t,g)    Institutional make matrix
    fs(i,t,f)   Factor disbursement matrix
    trnsfer(i,t,ii) Inter-institutional transfers    

    fexprt(f,t,trd) Factor exports 
    fimprt(trd,t,f) Factor imports
    simport(trd,t,s) Sectoral imports

    iexport(i,t,trd) Institutional exports
    iimport(trd,t,i) Institutional imports

    trnshp(trd,t,ttrd)  Transhipments;

$load output use iuse fd fexprt imake fs trnsfer fimprt trnshp simport iexport iimport 

*
parameter   gdp, zerotol;
gdp = sum((f,t,s), fd(f,t,s));
display gdp;

*   Drop sectors which has a neglible share of GDP:

zerotol = gdp*tol/10;
output(s,mkt)$(abs(output(s,mkt)) < zerotol) = 0;

*   Drop inputs to production which are a negligible share of cost:

use(g,t,s)$(use(g,t,s)          < tol*sum(mkt,output(g,mkt))) = 0;
iuse(g,t,i)$(iuse(g,t,i)        < tol*sum(mkt,output(g,mkt))) = 0;
fd(f,t,s)$(fd(f,t,s)            < tol*sum(mkt,output(s,mkt))) = 0;
simport(trd,t,s)$(abs(simport(trd,t,s)) < tol*sum(mkt,output(s,mkt))) = 0;

*   Drop institutional output which is neglibly small relative to
*   sectoral output:

imake(i,t,g)$(abs(imake(i,t,g))     < tol*output(g,"dmkt")) = 0;

*   Drop factor endowments which are small relative to total supply:

fs(i,t,f)$(abs(fs(i,t,f)) < tol*sum((tt,ff),fs(i,tt,ff))) = 0;
fexprt(f,t,trd)$(abs(fexprt(f,t,trd)) < tol*sum((i,tt),fs(i,tt,f))) = 0;
fimprt(trd,t,f)$(abs(fimprt(trd,t,f)) < tol*sum((i,tt),fs(i,tt,f))) = 0;

*   Drop other terms which are small in an absolute sense:

zerotol = tol;
trnsfer(i,t,ii)$(abs(trnsfer(i,t,ii)) < zerotol) = 0;
iexport(i,t,trd)$(abs(iexport(i,t,trd)) < zerotol) = 0;
iimport(trd,t,i)$(abs(iimport(trd,t,i)) < zerotol) = 0;
trnshp(trd,t,ttrd)$(abs(trnshp(trd,t,ttrd)) < zerotol) = 0;

*   Alternative reference to the set of regions:

alias (g,gg), (s,ss), (i,ii);

SET h(i)    Private (household) institutions /
    hlt15     "Households LT15k    (10001)"
    h15_30    "Households 15-30k   (10002)"
    h30_40    "Households 30-40k   (10003)"
    h40_50    "Households 40-50k   (10004)"
    h50_70    "Households 50-70k   (10005)"
    h70_100   "Households 70-100k  (10006)"
    h100_150  "Households 100-150k (10007)"
    h150_200  "Households 150-200k (10008)"
    hgt200    "Households 200k+    (10009)"/,

    pub(i)  Public (government) institutions /
        FND "Federal Government NonDefense (11001)"
        FDF "Federal Government Defense (11002)"
        FIN "Federal Government Investment (11003)"
        SLN "State Local Govt NonEducation (12001)"
        SLE "State Local Govt Education (12002)"
        SIN "State Local Govt Investment (12003)" /,

    corp(i) Corporate institutions  /
        ENT Enterprises (Corporations) (13001)
        INV Gross Private Fixed Investment (Capital) (14001)
        STK Inventory Sales Deletions (14002)/,

    fk(f)   Factors allocated to the capital account /
        PROP Proprietary Income (6001)
        OTHP Other Property Income (7001) /;

ALIAS  (trd,ttrd),(f,ff), (h,hh);

set acctcat Account categories /
        GOODS,
        INCOME,
        TRANSF,
        SOCINS,
        BUSTAX,
        PERTAX,
        OTHER/;

$onembedded
set mapcat(acctcat,t) /

    INCOME.(
        cprf    "Corporate Profits with IVA (15001)"
        ncmp    "Emp Comp (Wages/salary w/o soc sec) (15002)"
        ecmp    "Employee Comp (other labor income) (15003)"
        prop    "Proprietors Inc (w/o soc sec & CCA) (15004)"
        rent    "Rent with capital consumption Adj (15005)"
        btrn    "Business transfers (15006)"
        divd    "Dividends (15007)"
        nint    "Interest (net-from industries) (15008)"
        gint    "Interest (gross) (15009)"
    ),
    TRANSF.(
        trns    "Transfers (15010)"
        srpl    "Surplus or Deficit (15011)"
        save    "Savings (Surplus) -- not use (15012)"
        wage    "Wage Accruals Less Surplus (15013)"
    ),
    SOCINS.(
        sstw    "Social Ins Tax- Employee Contribution (15014)"
        sstf    "Social Ins Tax- Employer Contribution (15015)"
    ),
    BUSTAX.(
        sgov    "Surplus-Subsidy- Govt Enterprises (15016)"
        excs    "Indirect Bus Tax: Excise Taxes (15017)"
        duty    "Indirect Bus Tax: Custom Duty (15018)"
        nont    "Indirect Bus Tax: Fed NonTaxes (15019)"
        stax    "Indirect Bus Tax: Sales Tax (15020)"
        bptx    "Indirect Bus Tax: Property Tax (15021)"
        bmvt    "Indirect Bus Tax: Motor Vehicle Lic (15022)"
        sevt    "Indirect Bus Tax: Severance Tax (15023)"
        otax    "Indirect Bus Tax: Other Taxes (15024)"
        slnt    "Indirect Bus Tax: S/L NonTaxes (15025)"
        ctax    "Corporate Profits Tax (15026)"
    ),
    PERTAX.(
        pitx    "Personal Tax: Income Tax (15027)"
        egtx    "Personal Tax: Estate and Gift Tax (15028)"
        fees    "Personal Tax: NonTaxes (Fines- Fees (15029)"
        pmvt    "Personal Tax: Motor Vehicle License (15030)"
        pptx    "Personal Tax: Property Taxes (15031)"
        fish    "Personal Tax: Other Tax (Fish/Hunt) (15032)"
    ),
    OTHER.(
        capc    "Capital Consumption Allowance (15033)"
        retp    "Retained Profits (Profits w/IVA&CCA) (15034)"
        disc    "NIPA Statistical Discrepency (15035)"
        fint    "Interest (Net-from RoW) (15036)"
        fact    "Factor Trade (15037)"
        radj    "Adjustment to retained earnings (15038)"
        cuse    "Commodity Use (15050)"
        ctrd    "Commodity Trade (15051)"
        cmke    "Commodity Make (15052)"
        frpt    "Factor Receipts (15053)"
        ftrn    "Foreign Commodity Transshipments (15054)"
        iuse    "Industry Use (15055)"
        itrd    "Industry Trade (15056)" 
    )/;

*   Commodities:

mapcat("goods",g) = yes;
display mapcat;

*   1. Illustrate identities implicit in the IMPLAN statistics.

parameter   bmkchk  Handshake on benchmark consistency;

*   Profitability of sectoral production:

bmkchk(s,"profit") = round(sum(mkt, output(s,mkt)) - sum((g,t), use(g,t,s))
        - sum((trd,t), simport(trd,t,s)) - SUM((f,t), fd(f,t,s)), 6);

*   Demand and supply in the market for domestic goods:

bmkchk(g,"market") = round(output(g,"dmkt") - sum((t,s), use(g,t,s)) +
                  sum((i,t), imake(i,t,g) - iuse(g,t,i)), 6);

*   Trade balance:

bmkchk(trd,"trade") = round(sum(s, output(s,trd)) - sum((s,t), simport(trd,t,s)) 
            + sum((f,t), fexprt(f,t,trd) - fimprt(trd,t,f)) 
            + sum((i,t), iexport(i,t,trd) - iimport(trd,t,i)) 
            + sum((ttrd,t), trnshp(ttrd,t,trd) - trnshp(trd,t,ttrd)), 6);
*   Factor markets:

bmkchk(f,"market") =    round(sum((i,t), fs(i,t,f)) 
            + sum((trd,t), fimprt(trd,t,f)) 
            - sum((s,t), fd(f,t,s)) 
            - sum((trd,t), fexprt(f,t,trd)), 6);

*   Income and expenditure:

bmkchk(i,"income") = round( sum((g,t), imake(i,t,g)-iuse(g,t,i))
               + sum((trd,t), iexport(i,t,trd)-iimport(trd,t,i))
               - sum((ii,t), trnsfer(ii,t,i)-trnsfer(i,t,ii))
               + sum((f,t), fs(i,t,f)), 6);
display bmkchk;

parameter
    vom(s)      Aggregate output
    vdm(s)      Output to the domestic market
    vdxm(s,trd) Output to export markets
    vdfm(g,s)   Domestic intermediate demand
    vifm(g,trd,s)   Imported intermediate demand
    vfm(f,s)    Factor demand
    vxm(s,trd)  National and international exports
    vx(s)       Aggregate exports
    vim(g,trd)  Aggregate imports
    vpm(h)      Aggregate consumption
    vdpm(g,h)   Domestic consumption demand
    vipm(g,trd,h)   Imported consumption demand
    vinv        Aggregate investment
    vdim(g)     Domestic investment demand
    viim(g,trd) Imported investment demand
    vgm(pub)    Public sector demand
    vdgm(g,pub) Domestic public demand
    vigm(g,trd,pub) Imported public demand
    evom(f,i,t) Factor supply,
    evpm(g,i)   Goods supply (make and export),
    vprf(i)     Corporate profit
    vtrn(i,t)   Transfers
    vdmi(s)     Domestic output (including institutional make);

*   First read the data verbatim and report consistency:

vdm(s)      = output(s,"dmkt")              ;
vdxm(s,trd) = output(s,trd)                 ;
vom(s)      = vdm(s) + sum(trd,vdxm(s,trd)) ;

vdmi(g)     = vdm(g) + sum((i,t),imake(i,t,g))  ;

vdfm(g,s)       = sum(t,use(g,t,s));
vifm(g,trd,s)   = simport(trd,g,s);
vfm(f,s)        = sum(t, fd(f,t,s));

vxm(s,trd)      = vdxm(s,trd) + sum(i,iexport(i,s,trd));
vim(g,trd)      = sum(s, simport(trd,g,s)) + sum(i, iimport(trd,g,i));

vdpm(g,h)       = sum(t, iuse(g,t,h));
vipm(g,trd,h)   = iimport(trd,g,h);
vpm(h)          = sum(g,vdpm(g,h) + sum(trd, vipm(g,trd,h)));

*   Currently assume that the composition of investment 
*   includes all inputs to enterprises, fixed investment
*   and inventory sales (set CORP = ENT,INV,STK). 
*   Alternatively, might only include INV and let ENT and 
*   STK enter in the FIRMS endowment vector: 

vdim(g)     = sum((t,corp), iuse(g,t,corp));
viim(g,trd) = sum(corp, iimport(trd,g,corp));
vinv        = sum(g, vdim(g) + sum(trd, viim(g,trd)));

vdgm(g,pub)     = sum(t, iuse(g,t,pub));
vigm(g,trd,pub) = iimport(trd,g,pub);
vgm(pub)        = sum(g, vdgm(g,pub) + sum(trd, vigm(g,trd,pub)));

evom(f,i,t)     = fs(i,t,f);

evpm(g,i)       = sum(t,imake(i,t,g)) + sum(trd,iexport(i,g,trd));
vprf(i)$(not corp(i)) = sum((t,corp), trnsfer(i,t,corp));

*   Impose market consistency using the corporate agent:
evpm(g,"ent") = 0;
evpm(g,"ent") = sum(s,   vdfm(g,s)) + sum(h,   vdpm(g,h)) + 
    sum(pub, vdgm(g,pub)) + vdim(g) + sum(trd,vxm(g,trd)) - sum(i, evpm(g,i)) - vom(g);
evpm(g,"ent")$(abs(evpm(g,"ent")) < zerotol) = 0;

*   Transfers:

vtrn(i,t) =  sum((trd)$(not g(t)), iexport(i,t,trd)) 
       - sum((trd)$(not g(t)), iimport(trd,t,i)) +
      sum((ii), trnsfer(i,t,ii)$(not corp(ii)) -trnsfer(ii,t,i));

parameter budget;
budget(h,"vpm") = vpm(h) - sum((g,t), iuse(g,t,h)) - sum((trd,g), iimport(trd,g,h));
budget(h,"evom") = sum((f,t), evom(f,h,t)) - sum((f,t), fs(h,t,f));
budget(h,"evpm") = sum(g, evpm(g,h)) - sum((g,t), imake(h,t,g)) 
    - sum((trd,g), iexport(h,g,trd));
budget(h,"total") = vpm(h) - vprf(h) - sum((f,t), evom(f,h,t)) 
    - sum(g, evpm(g,h)) - sum(t,vtrn(h,t));

budget(pub,"total") = vgm(pub) - vprf(pub) - sum((f,t), evom(f,pub,t)) 
    - sum(g, evpm(g,pub))-sum(t,vtrn(pub,t));
budget(pub,"vgm")= vgm(pub) - sum((g,t), iuse(g,t,pub)) - sum((trd,g), iimport(trd,g,pub)); 
budget(pub,"evom")= sum((f,t), evom(f,pub,t)) - sum((f,t), fs(pub,t,f));
budget(pub,"evpm") = sum(g, evpm(g,pub)) - sum((g,t), imake(pub,t,g)) 
        - sum((trd,g), iexport(pub,g,trd));

display budget;

*   Drop negative values from production:

vdm(s) = max(0, vdm(s));
vdmi(s) = max(0, vdmi(s));
vdxm(s,trd) = max(0, vdxm(s,trd));
vom(s) = vdm(s) + sum(trd,vdxm(s,trd));
vdfm(g,s) = max(0,vdfm(g,s))$(vdm(g)>0 and vom(s)>0);
vifm(g,trd,s) = max(0,vifm(g,trd,s))$vom(s);
vfm(f,s) = max(0,vfm(f,s))$vom(s);

*   Constrain factor endowments to be non-negative:

evom(f,i,t) = max(0, evom(f,i,t));
vfm(f,s)$vom(s) = 5*vom(s) * round(vfm(f,s)/(5*vom(s)),3);

variable    fd_(f,s)    Factor demand
        fs_(f,i,t)  Factor supply
        lsobj       Least-squares objective;

positive variable fd_,fs_;

equations   fdbal,fsmkt,objdef;

objdef..    lsobj =e= sum((f,s)$vfm(f,s), vfm(f,s)*sqr(fd_(f,s)/vfm(f,s)-1))
        + sum((f,i,t)$evom(f,i,t), evom(f,i,t)*sqr(fs_(f,i,t)/evom(f,i,t)-1))
        + sum((f,i,t)$(evom(f,i,t)=0), 100 *fs_(f,i,t))
        + sum((f,s)$(vfm(f,s)=0), 100 * fd_(f,s));

fdbal(s)$vom(s)..  sum(f, fd_(f,s)) =e= vom(s) - sum(g,vdfm(g,s)+sum(trd,vifm(g,trd,s)));

fsmkt(f)..  sum((i,t), fs_(f,i,t)) =e= sum(s, fd_(f,s));

fs_.l(f,i,t)                = evom(f,i,t);
fd_.l(f,s)                  = vfm(f,s);
fd_.fx(f,s)$(vfm(f,s) = 0)  = 0;
fd_.up("empl",s)$(smax(f, fd_.up(f,s))=0) = inf;
fd_.fx(f,s)$(vom(s) = 0)    = 0;

model fbal /all/;
option nlp = pathnlp ;
solve  fbal using nlp minimizing lsobj;

vfm(f,s)    = fd_.l(f,s);
evom(f,i,t) = fs_.l(f,i,t);

*   Omit exports which are not produced:

zerotol = gdp*tol/10;
evpm(s,i)$(vom(s)<zerotol) = 0;
vxm(g,trd)$(vom(g)<zerotol) = 0;
vxm(g,trd)$(vxm(g,trd) < tol/10 * vom(g)) = 0;
evpm(s,i)$(evpm(s,i) <  tol/10 * vom(s)) = 0;

*   Suppress negative demands:

vdpm(g,h) = max(0,vdpm(g,h))$vdm(g);
vipm(g,trd,h) = max(0,vipm(g,trd,h));
vpm(h) = sum(g,vdpm(g,h) + sum(trd, vipm(g,trd,h)));

vdgm(g,pub) = max(0,vdgm(g,pub))$vdm(g);
vigm(g,trd,pub) = max(0,vigm(g,trd,pub));
vgm(pub) = sum(g, vdgm(g,pub) + sum(trd, vigm(g,trd,pub)));

vdim(g) = max(0,vdim(g))$vdm(g);
viim(g,trd)  = max(0,viim(g,trd));
vinv = sum(g, vdim(g) + sum(trd, viim(g,trd)));

*   Recalibrate import demand:

vim(g,trd) = sum(s, vifm(g,trd,s)) + sum(h, vipm(g,trd,h)) + viim(g,trd) + sum(pub, vigm(g,trd,pub));

*   Aggregate export demand:

vx(s) = sum(trd, vxm(s,trd));

*   Cinch up market clearance:

evpm(g,"ent")$vom(g) = evpm(g,"ent") - (vom(g) + sum(i,evpm(g,i))
         - sum(s, vdfm(g,s))-sum(h,vdpm(g,h))-vdim(g)-sum(pub,vdgm(g,pub))
         - vx(g));

*   Cinch up incomes:

vtrn(h,"trns") = vtrn(h,"trns") +
    vpm(h)   - vprf(h) - sum((f,t), evom(f,h,t)) - sum(g, evpm(g,h)) - sum(t, vtrn(h,t));
        
vtrn(pub,"trns") = vtrn(pub,"trns") + 
    vgm(pub) - vprf(pub) - sum((f,t), evom(f,pub,t)) - sum(g, evpm(g,pub)) - sum(t,vtrn(pub,t));

vtrn("ent","trns") = vtrn("ent","trns") + 
    vinv + sum(i, vprf(i)) - sum((f,corp,t),evom(f,corp,t)) - sum((g,corp),evpm(g,corp))
    - sum((corp,t), vtrn(corp,t));

parameter   benchchk    Benchmark consistency check;

benchchk(s,"profit") = vom(s) - sum(g,vdfm(g,s)) 
        - sum((g,trd),vifm(g,trd,s)) - sum(f, vfm(f,s));

benchchk(g,"market") = vom(g) + sum(i,evpm(g,i))
         - sum(s, vdfm(g,s))-sum(h,vdpm(g,h))-vdim(g)-sum(pub,vdgm(g,pub))
         - vx(g);

display benchchk,vprf;

*   Unload data:
$call 'if not exist data\noaggr%subdir%\nul mkdir data\noaggr%subdir%'
execute_unload 'data\noaggr%subdir%\%ds%.gdx', f,t,i,j,g,h,pub,corp,vdxm,vdfm,vifm,
    vfm,vxm,vdpm,vipm, vdim,viim,vdgm,vigm,vprf,evom,evpm,vtrn,
    vdmi,trnsfer;