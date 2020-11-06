$title  Read a single state file

$set diagonal yes
$set year 18 
$if  not set ds $set ds ak

SET R Rows and columns in the SAM /

*   1*509       Industries,
    1*546       Industries,

*   3001*3509   Commodities,
    3001*3546   Commodities,

    5001 Employee Compensation                      
    6001 Proprietary Income                         
    7001 Other Property Income                      
    8001 Indirect Business Taxes                    

    10001*10009 Households

    11001 Federal Government NonDefense
    11002 Federal Government Defense
    11003 Federal Government Investment

    12001 State Local Govt NonEducation 
    12002 State Local Govt Education
    12003 State Local Govt Investment

    13001 Enterprises (Corporations)

    14001 Gross Private Fixed Investment (Capital)
    14002 Inventory Additions - Deletions

    25001 Foreign trade
    28001 Domestic Trade/;

set T  Account codes  /
*   3001*3509   Commodities,
    3001*3546   Commodities,

    15001       "Corporate Profits with IVA"
    15002       "Emp Comp (Wages/Salary w/o Soc Sec)"
    15003       "Employee Comp (Other Labor Income)"
    15004       "Proprietors Inc (w/o Soc Sec & CCA)"
    15005       "Rent with Capital Consumption Adj"
    15006       "Business Transfers"
    15007       "Dividends"
    15008       "Interest (Net-from Industries)"
    15009       "Interest (Gross)"
    15010       "Transfers"
    15011       "Surplus or Deficit"
    15012       "Savings (Surplus)           not use"
    15013       "Wage Accruals Less Surplus"
    15014       "Social Ins Tax- Employee Contribution"
    15015       "Social Ins Tax- Employer Contribution"
    15016       "Surplus-Subsidy- Govt Enterprises"
    15017       "Indirect Bus Tax: Excise Taxes"
    15018       "Indirect Bus Tax: Custom Duty"
    15019       "Indirect Bus Tax: Fed NonTaxes"
    15020       "Indirect Bus Tax: Sales Tax"
    15021       "Indirect Bus Tax: Property Tax"
    15022       "Indirect Bus Tax: Motor Vehicle Lic"
    15023       "Indirect Bus Tax: Severance Tax"
    15024       "Indirect Bus Tax: Other Taxes"
    15025       "Indirect Bus Tax: S/L NonTaxes"
    15026       "Corporate Profits Tax"
    15027       "Personal Tax: Income Tax"
    15028       "Personal Tax: Estate and Gift Tax"
    15029       "Personal Tax: NonTaxes (Fines- Fees"
    15030       "Personal Tax: Motor Vehicle License"
    15031       "Personal Tax: Property Taxes"
    15032       "Personal Tax: Other Tax (Fish/Hunt)"
    15033       "Capital Consumption Allowance"
    15034       "Retained Profits (Profits w/IVA&CCA"
    15035       "NIPA Statistical Discrepency"
    15036       "Interest (Net-from RoW)"
    15037       "Factor Trade"
    15038       "Adjustment to retained earnings"
    15050       "Commodity Use"
    15051       "Commodity Trade"
    15052       "Commodity Make"
    15053       "Factor Receipts"
    15054       "Foreign Commodity Transshipments"
    15055       "Industry Use"
    15056       "Industry Trade"  /;

alias (r,c);

*   Unzip the data file, read it and then delete it:
$if  exist .\IMPLANData\%ds%.GMS  $goto readdata

$set dataset .\st%year%-%ds%.zip
$if  exist .\IMPLANData\%dataset% $goto unzip

$log   "Error -- cannot find IMPLANData\%dataset%"
$call   pause 'Program will now abort.'
$abort "Error -- cannot find IMPLANData\%dataset%"

$label unzip
$call 'unzip -j ..\IMPLANData\%dataset%'

$label readdata
PARAMETER sam(r,t,c)  Base year social accounts /
$offlisting
$include .\IMPLANData\%ds%.GMS
$onlisting
/;
$if exist .\IMPLANData\%dataset% $call 'del st%year%-%ds%.gms'

*   Extract non-zero domain and scale the data here:

set samdomain(r,t,c);
*$libinclude domain sam samdomain
*$libinclude sam samdomain

samdomain(r,t,c)$sam(r,t,c) = YES ;
sam(samdomain(r,t,c)) = sam(r,t,c)*(1/1000);

parameter   rowsum  Row sums
        colsum  Column sums
        check   Balance;

rowsum(r) = sum(samdomain(r,t,c), sam(r,t,c));
colsum(c) = sum(samdomain(r,t,c), sam(r,t,c));

check(r,"rowsum") = rowsum(r);
check(r,"colsum") = colsum(r);
check(r,"tolerance") = round(rowsum(r) - colsum(r),5);
set chkcol /rowsum, colsum, tolerance/;
display check;

*   Correct imbalances through transfers from domestic
*   to foreign trade accounts:

if (rowsum("25001")>colsum("25001"),
  samdomain("28001","15010","25001") = yes;
  sam("28001","15010","25001")
    = sam("28001","15010","25001") + rowsum("25001")-colsum("25001");
else
  samdomain("25001","15010","28001") = yes;
  sam("25001","15010","28001")
    = sam("25001","15010","28001") + colsum("25001")-rowsum("25001");
);

rowsum(r) = sum(samdomain(r,t,c), sam(r,t,c));
colsum(c) = sum(samdomain(r,t,c), sam(r,t,c));

check(r,"rowsum") = rowsum(r);
check(r,"colsum") = colsum(r);
check(r,"tolerance") = round(rowsum(r) - colsum(r),5);
display check;


*   Check subtotal accounts:
set st  Subtotal accounts /Industries,Commodities,Factor,Households,Fed,State,Corp,Invest,Foreign,Domestic/;
set stmap(st,r) /
*       Industries.(1*509),
        Industries.(1*546),
*       Commodities.(3001*3509),
        Commodities.(3001*3546),
        Factor.(5001,6001,7001,8001),
        Households.(10001*10009),
        Fed.(11001,11002,11003),
        State.(12001,12002,12003),
        Corp.13001,
        Invest.(14001,14002),
        Foreign.25001,
        Domestic.28001/;
alias   (st,rt,ct);

parameter   stsam   Subtotals of SAM values;
stsam(rt,ct) = sum((r,c)$(stmap(rt,r) and stmap(ct,c)),sum(t, sam(r,t,c)));
stsam(rt,"total") = sum(ct, stsam(rt,ct));
stsam("total",ct) = sum(rt, stsam(rt,ct));
stsam("chk",ct) = stsam(ct,"total") - stsam("total",ct);
display stsam;

stsam(rt,"totchk") = stsam(rt,"total") - sum(stmap(rt,r), rowsum(r));
stsam("totchk",ct) = stsam("total",ct) - sum(stmap(ct,c), colsum(c));
display stsam;

*   The following sets are always used:
SET     S(R) Industries     /1*546/,
*       S(R) Industries     /1*509/,
        G(R) Commodities    /3001*3546/,
*       G(R) Commodities    /3001*3509/,

        F(R) Factors        /5001,6001,7001,8001 /
        I(R) Institutions   /10001*10009,11001*11003,12001*12003,13001,14001*14002/
        TRD(R) Trade        /25001   Foreign, 28001  Domestic/;

SET  J Aggregated SAM accounts /

*   Goods and sectors:
(1*546)
*(1*509)

*   The following labels are always used:
*   Factors:
empl    Employee Compensation (5001)
prop    Proprietary Income (6001)
othp    Other Property Income (7001)
btax    Indirect Business Taxes (8001)

*   Institutions:
hlt15     Households LT15k   (10001)
h15_30    Households 15-30k  (10002)
h30_40    Households 30-40k  (10003)
h40_50    Households 40-50k  (10004)
h50_70    Households 50-70k  (10005)
h70_100   Households 70-100k (10006)
h100_150  Households 100-150k (10007)
h150_200  Households 150-200k (10008)
hgt200    Households 200k+   (10009)
fnd     Federal Government NonDefense (11001)
fdf     Federal Government Defense (11002)
fin     Federal Government Investment (11003)
sln     State Local Govt NonEducation (12001)
sle     State Local Govt Education (12002)
sin     State Local Govt Investment (12003)

ent     Enterprises (Corporations) (13001)
inv     Gross Private Fixed Investment (Capital) (14001)
stk     Inventory Additions Deletions (14002)

*   Trade flows:
ftrd    Foreign Trade (25001)
dtrd    Domestic Trade (28001) /;

SET MAP(j,*) /

empl.5001    Employee Compensation
prop.6001    Proprietary Income
othp.7001    Other Property Income
btax.8001    Indirect Business Taxes
hlt15.10001    Households LT15k
h15_30.10002   Households 15-30k   
h30_40.10003   Households 30-40k  
h40_50.10004   Households 40-50k  
h50_70.10005   Households 50-70k  
h70_100.10006   Households 70-100k  
h100_150.10007   Households 100-150k 
h150_200.10008  Households 150-200k
hgt200.10009  Households 200k+   
fnd.11001    Federal Government NonDefense
fdf.11002    Federal Government Defense
fin.11003    Federal Government Investment
sln.12001    State Local Govt NonEducation
sle.12002    State Local Govt Education
sin.12003    State Local Govt Investment
ent.13001    Enterprises (Corporations)
inv.14001    Gross Private Fixed Investment (Capital)
stk.14002    Inventory Additions Deletions

ftrd.25001   Foreign Trade
dtrd.28001   Domestic Trade  /;


ALIAS (j,jj);

SET implan(j) /1*546/;
*   implan(j) /1*509/;
map(implan,implan) = YES;

*   Add commodities to the mapping in accordance with the industry
*   mapping:

LOOP((s,g)$(ORD(g) EQ ORD(s)),  map(j,g) = map(j,s););

PARAMETER   ASUM        Sum of nonzeros in the SAM;

* 'Checking mapping';

SET     MAPERROR(*)     Identifies rows which are improperly mapped;
MAPERROR(R) = YES$(SUM(j$MAP(j,R), 1) - 1);
ABORT$CARD(MAPERROR) " Type 1 error in mapping -- good not mapped:",MAPERROR;
MAPERROR(j) = YES$(SUM(R$MAP(j,R), 1) EQ 0);
ABORT$CARD(MAPERROR) " Type 2 error in mapping -- target not used:",MAPERROR;

SET sj(j), gj(j), fj(j), ij(j), tj(j);

sj(j) = YES$SUM(s$map(j,s),1);
gj(j) = YES$SUM(g$map(j,g),1);
fj(j) = YES$SUM(f$map(j,f),1);
ij(j) = YES$SUM(i$map(j,i),1);
tj(j) = YES$SUM(trd$map(j,trd),1);

set tt  Account acronyms /
    (1*546) Commodities,
*   (1*509) Commodities,
    cprf    "Corporate Profits with IVA (15001)"
    ncmp    "Emp Comp (Wages/Salary w/o Soc Sec) (15002)"
    ecmp    "Employee Comp (Other Labor Income) (15003)"
    prop    "Proprietors Inc (w/o Soc Sec & CCA) (15004)"
    rent    "Rent with Capital Consumption Adj (15005)"
    btrn    "Business Transfers (15006)"
    divd    "Dividends (15007)"
    nint    "Interest (Net-from Industries) (15008)"
    gint    "Interest (Gross) (15009)"
    trns    "Transfers (15010)"
    srpl    "Surplus or Deficit (15011)"
    save    "Savings (Surplus) not use (15012)"
    wage    "Wage Accruals Less Surplus (15013)"
    sstw    "Social Ins Tax- Employee Contribution (15014)"
    sstf    "Social Ins Tax- Employer Contribution (15015)"
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
    pitx    "Personal Tax: Income Tax (15027)"
    egtx    "Personal Tax: Estate and Gift Tax (15028)"
    fees    "Personal Tax: NonTaxes (Fines- Fees (15029)"
    pmvt    "Personal Tax: Motor Vehicle License (15030)"
    pptx    "Personal Tax: Property Taxes (15031)"
    fish    "Personal Tax: Other Tax (Fish/Hunt) (15032)"
    capc    "Capital Consumption Allowance (15033)"
    retp    "Retained Profits (Profits w/IVA&CCA (15034)"
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
    itrd    "Industry Trade (15056)" /;

set mapt(tt,t)  Mapping from account codes to acronyms /
    cprf.15001  "Corporate Profits with IVA (15001)"
    ncmp.15002  "Emp Comp (Wages/Salary w/o Soc Sec) (15002)"
    ecmp.15003  "Employee Comp (Other Labor Income) (15003)"
    prop.15004  "Proprietors Inc (w/o Soc Sec & CCA) (15004)"
    rent.15005  "Rent with Capital Consumption Adj (15005)"
    btrn.15006  "Business Transfers (15006)"
    divd.15007  "Dividends (15007)"
    nint.15008  "Interest (Net-from Industries) (15008)"
    gint.15009  "Interest (Gross) (15009)"
    trns.15010  "Transfers (15010)"
    srpl.15011  "Surplus or Deficit (15011)"
    save.15012  "Savings (Surplus)           not use (15012)"
    wage.15013  "Wage Accruals Less Surplus (15013)"
    sstw.15014  "Social Ins Tax- Employee Contribution (15014)"
    sstf.15015  "Social Ins Tax- Employer Contribution (15015)"
    sgov.15016  "Surplus-Subsidy- Govt Enterprises (15016)"
    excs.15017  "Indirect Bus Tax: Excise Taxes (15017)"
    duty.15018  "Indirect Bus Tax: Custom Duty (15018)"
    nont.15019  "Indirect Bus Tax: Fed NonTaxes (15019)"
    stax.15020  "Indirect Bus Tax: Sales Tax (15020)"
    bptx.15021  "Indirect Bus Tax: Property Tax (15021)"
    bmvt.15022  "Indirect Bus Tax: Motor Vehicle Lic (15022)"
    sevt.15023  "Indirect Bus Tax: Severance Tax (15023)"
    otax.15024  "Indirect Bus Tax: Other Taxes (15024)"
    slnt.15025  "Indirect Bus Tax: S/L NonTaxes (15025)"
    ctax.15026  "Corporate Profits Tax (15026)"
    pitx.15027  "Personal Tax: Income Tax (15027)"
    egtx.15028  "Personal Tax: Estate and Gift Tax (15028)"
    fees.15029  "Personal Tax: NonTaxes (Fines- Fees (15029)"
    pmvt.15030  "Personal Tax: Motor Vehicle License (15030)"
    pptx.15031  "Personal Tax: Property Taxes (15031)"
    fish.15032  "Personal Tax: Other Tax (Fish/Hunt) (15032)"
    capc.15033  "Capital Consumption Allowance (15033)"
    retp.15034  "Retained Profits (Profits w/IVA&CCA (15034)"
    disc.15035  "NIPA Statistical Discrepency (15035)"
    fint.15036  "Interest (Net-from RoW) (15036)"
    fact.15037  "Factor Trade (15037)"
    radj.15038  "Adjustment to retained earnings (15038)"
    cuse.15050  "Commodity Use (15050)"
    ctrd.15051  "Commodity Trade (15051)"
    cmke.15052  "Commodity Make (15052)"
    frpt.15053  "Factor Receipts (15053)"
    ftrn.15054  "Foreign Commodity Transshipments (15054)"
    iuse.15055  "Industry Use (15055)"
    itrd.15056  "Industry Trade (15056)" /;

$onuni
mapt(tt,g)$(ord(g) = ord(tt)) = yes;
display mapt;
$offuni

*       Aggregate submatrices and assign new labels:
PARAMETER
         make(j,tt,jj)     Domestic industry make matrix
         use(j,tt,jj)      Domestic industry use matrix
         iuse(j,tt,jj)     Domestic institutional use matrix
         fd(j,tt,jj)       Factor input matrix : industry use of factors
         fexprt(j,tt,jj)   Factor exports
         imake(j,tt,jj)    Domestic institutional make matrix
         fs(j,tt,jj)       Factor disbursement matrix
         trnsfer(j,tt,jj)  Inter-institutional transfers
         fimprt(j,tt,jj)   Factor imports
         trnshp(j,tt,jj)   Transhipments
         sexport(j,tt,jj)  Exports by sector
         iexport(j,tt,jj)  Exports by institution
         simport(j,tt,jj)  Imports by sector
         iimport(j,tt,jj)  Imports by institution;

ALIAS (i,ii), (ij,iij),(tj,ttj), (trd,ttrd);

FILE KCON/con/; PUT KCON;

SET maps(s,j), mapg(g,j), mapi(i,j), mapf(f,j), 
maptrd(trd,j), mapii(i,j), maptrdt(trd,j);
maps(s,sj) = map(sj,s);
mapg(g,gj) = map(gj,g);
mapi(i,ij) = map(ij,i);
mapf(f,fj) = map(fj,f);
maptrd(trd,tj) = map(tj,trd);
maptrdt(trd,tj) = map(tj,trd);
mapii(i,ij) = mapi(i,ij);
display maps, mapg, s, sj, g, gj;

SET unread(r,t,c);
unread(r,t,c) = samdomain(r,t,c);

*   Set up a tuple for more rapid execution:

SET jdomain(r,t,c,j,tt,jj);
jdomain(r,t,c,j,tt,jj) = no;

loop(samdomain(r,t,c),
    loop((j,tt,jj)$(map(j,r)*mapt(tt,t)*map(jj,c)),
      jdomain(r,t,c,j,tt,jj) = yes;
));

PARAMETER dcount;
dcount("r") = card(r);
dcount("j") = card(j);
dcount("map") = card(map);
dcount("t") = card(t);
dcount("tt") = card(tt);
dcount("mapt") = card(mapt);
dcount("samdomain") = card(samdomain);
dcount("jdomain") = card(jdomain);
*.DISPLAY dcount;


PUTCLOSE 'Aggregating MAKE'/;
loop(samdomain(s,t,g),
    make(sj,tt,gj)$jdomain(s,t,g,sj,tt,gj) = sam(s,t,g);

);
unread(samdomain(s,t,g)) = no;

PUTCLOSE 'Aggregating USE'/;
loop(samdomain(g,t,s),
    use(gj,tt,sj)$jdomain(g,t,s,gj,tt,sj) = sam(g,t,s);
);
unread(samdomain(g,t,s)) = no;

PUTCLOSE /,'Aggregating IUSE'/;
loop(samdomain(g,t,i),
    iuse(gj,tt,ij)$jdomain(g,t,i,gj,tt,ij) = sam(g,t,i);
);
unread(samdomain(g,t,i)) = no;

PUTCLOSE 'Aggregating FD'/;
loop(samdomain(f,t,s),
    fd(fj,tt,sj)$jdomain(f,t,s,fj,tt,sj) = sam(f,t,s);
);
unread(samdomain(f,t,s)) = no;

PUTCLOSE 'Aggregating FEXPRT'/;
loop(samdomain(f,t,trd),
    FEXPRT(fj,tt,tj)$jdomain(f,t,trd,fj,tt,tj) = sam(f,t,trd);
);
unread(samdomain(f,t,trd)) = no;

PUTCLOSE 'Aggregating IMAKE'/;
loop(samdomain(i,t,g),
    imake(ij,tt,gj)$jdomain(i,t,g,ij,tt,gj) = sam(i,t,g);
);
unread(samdomain(i,t,g)) = no;

PUTCLOSE 'Aggregating FS'/;
loop(samdomain(i,t,f),
    fs(ij,tt,fj)$jdomain(i,t,f,ij,tt,fj) = sam(i,t,f);
);
unread(samdomain(i,t,f)) = no;

PUTCLOSE 'Aggregating TRNSFER'/;
loop(samdomain(i,t,ii),
    trnsfer(ij,tt,iij)$jdomain(i,t,ii,ij,tt,iij) = sam(i,t,ii);
);
unread(samdomain(i,t,ii)) = no;

PUTCLOSE 'Aggregating FIMPRT'/;
loop(samdomain(trd,t,f),
    fimprt(tj,tt,fj)$jdomain(trd,t,f,tj,tt,fj) = sam(trd,t,f);
);
unread(samdomain(trd,t,f)) = no;

PUTCLOSE 'Aggregating TRNSHP'/;
loop(samdomain(trd,t,ttrd),
    trnshp(tj,tt,ttj)$jdomain(trd,t,ttrd,tj,tt,ttj) = sam(trd,t,ttrd);
);
unread(samdomain(trd,t,ttrd)) = no;

PUTCLOSE 'Aggregating SEXPORT'/;
loop(samdomain(s,t,trd),
    SEXPORT(sj,tt,tj)$jdomain(s,t,trd,sj,tt,tj) = sam(s,t,trd);
);
unread(samdomain(s,t,trd)) = no;

PUTCLOSE 'Aggregating IEXPORT'/;
loop(samdomain(i,t,trd),
    IEXPORT(ij,tt,tj)$jdomain(i,t,trd,ij,tt,tj) = sam(i,t,trd);
);
unread(samdomain(i,t,trd)) = no;

PUTCLOSE 'Aggregating SIMPORT'/;
loop(samdomain(trd,t,s),
    SIMPORT(tj,tt,sj)$jdomain(trd,t,s,tj,tt,sj) = sam(trd,t,s);
);
unread(samdomain(trd,t,s)) = no;

PUTCLOSE 'Aggregating IIMPORT'/;
loop(samdomain(trd,t,i),
    IIMPORT(tj,tt,ij)$jdomain(trd,t,i,tj,tt,ij) = sam(trd,t,i);
);
unread(samdomain(trd,t,i)) = no;

*$if not set runtrace $goto bmkchk

PARAMETER trace(*,*)  Comparison of submatrix trace with full SAM;
trace("total","data") =
    SUM((j,tt,jj),  make(j,tt,jj)    + imake(j,tt,jj) +
            sexport(j,tt,jj) + iexport(j,tt,jj) + 
            simport(j,tt,jj) + iimport(j,tt,jj) +
            use(j,tt,jj)     + iuse(j,tt,jj) +
                        fd(j,tt,jj)      + fs(j,tt,jj) + 
            fexprt(j,tt,jj)  + fimprt(j,tt,jj) +
                        trnsfer(j,tt,jj) + trnshp(j,tt,jj));
trace("total","SAM") = sum(samdomain(r,t,c), sam(r,t,c));
trace("make","sam") = sum(samdomain(s,t,g), sam(s,t,g));
trace("make","data") = sum((j,tt,jj), make(j,tt,jj));
trace("use","sam") = sum(samdomain(g,t,s), sam(g,t,s));
trace("use","data") = sum((j,tt,jj), use(j,tt,jj));
trace("iuse","sam") = sum(samdomain(g,t,i), sam(g,t,i));
trace("iuse","data") = sum((j,tt,jj), iuse(j,tt,jj));
trace("fd","sam") = sum(samdomain(f,t,s), sam(f,t,s));
trace("fd","data") = sum((j,tt,jj), fd(j,tt,jj));
trace("FEXPRT","sam") = sum(samdomain(f,t,trd), sam(f,t,trd));
trace("FEXPRT","data") = sum((j,tt,jj), FEXPRT(j,tt,jj));
trace("imake","sam") = sum(samdomain(i,t,g), sam(i,t,g));
trace("imake","data") = sum((j,tt,jj), imake(j,tt,jj));
trace("fs","sam") = sum(samdomain(i,t,f), sam(i,t,f));
trace("fs","data") = sum((j,tt,jj), fs(j,tt,jj));
trace("trnsfer","sam") = sum(samdomain(i,t,ii), sam(i,t,ii));
trace("trnsfer","data") = sum((j,tt,jj), trnsfer(j,tt,jj));
trace("fimprt","sam") = sum(samdomain(trd,t,f), sam(trd,t,f));
trace("fimprt","data") = sum((j,tt,jj), fimprt(j,tt,jj));
trace("trnshp","sam") = sum(samdomain(trd,t,ttrd), sam(trd,t,ttrd));
trace("trnshp","data") = sum((j,tt,jj), trnshp(j,tt,jj));

trace("SEXPORT","sam") = sum(samdomain(s,t,trd), sam(s,t,trd));
trace("SEXPORT","data") = sum((j,tt,jj), SEXPORT(j,tt,jj));

trace("IEXPORT","sam") = sum(samdomain(i,t,trd), sam(i,t,trd));
trace("IEXPORT","data") = sum((j,tt,jj), IEXPORT(j,tt,jj));
trace("SIMPORT","sam") = sum(samdomain(trd,t,s), sam(trd,t,s));
trace("SIMPORT","data") = sum((j,tt,jj), SIMPORT(j,tt,jj));
trace("IIMPORT","sam") = sum(samdomain(trd,t,i), sam(trd,t,i));
trace("IIMPORT","data") = sum((j,tt,jj), IIMPORT(j,tt,jj));
DISPLAY trace, unread;

$label bmkchk

parameter   bmkchk  Handshake on benchmark consistency;

*   Profitability of sectoral production:

Bmkchk(sj,"profit") = round(SUM(tt,    SUM(gj, make(sj,tt,gj) - use(gj,tt,sj))
        + SUM(tj, sexport(sj,tt,tj) - simport(tj,tt,sj)) - SUM(fj, fd(fj,tt,sj))), 6);

*   Demand and supply in the market for domestic goods:

bmkchk(gj,"market") = round(sum(tt, sum(sj, make(sj,tt,gj) - use(gj,tt,sj)) +
                  sum(ij, imake(ij,tt,gj) - iuse(gj,tt,ij))), 6);

*   Trade balance:

bmkchk(tj,"trade") = round(sum((sj,tt), sexport(sj,tt,tj) - simport(tj,tt,sj)) 
            + sum((fj,tt), fexprt(fj,tt,tj) - fimprt(tj,tt,fj)) 
            + sum((ij,tt), iexport(ij,tt,tj) - iimport(tj,tt,ij)) 
            + sum((ttj,tt), trnshp(ttj,tt,tj) - trnshp(tj,tt,ttj)), 6);
*   Factor markets:

bmkchk(fj,"market") =   round(sum((ij,tt), fs(ij,tt,fj)) 
            + sum((tj,tt), fimprt(tj,tt,fj)) 
            - sum((sj,tt), fd(fj,tt,sj)) 
            - sum((tj,tt), fexprt(fj,tt,tj)), 6);

*   Income and expenditure:

bmkchk(ij,"income") = round( sum((gj,tt), imake(ij,tt,gj)-iuse(gj,tt,ij))
               + sum((tj,tt), iexport(ij,tt,tj)-iimport(tj,tt,ij))
               - sum((iij,tt), trnsfer(iij,tt,ij)-trnsfer(ij,tt,iij))
               + sum((fj,tt), fs(ij,tt,fj)), 6);
display bmkchk;

set acctcat Account categories /
        GOODS,
        INCOME,
        TRANSF,
        SOCINS,
        BUSTAX,
        PERTAX,
        OTHER/;

$onembedded
set mapcat(acctcat,tt) /

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


parameter   echop   Echoprint of base year statistics;

echop(acctcat,"make")    = sum((mapcat(acctcat,tt),sj,gj), make(sj,tt,gj));
echop(acctcat,"use")     = sum((mapcat(acctcat,tt),gj,sj), use(gj,tt,sj));
echop(acctcat,"iuse")    = sum((mapcat(acctcat,tt),gj,ij), iuse(gj,tt,ij));
echop(acctcat,"fd")      = sum((mapcat(acctcat,tt),fj,sj), fd(fj,tt,sj));
echop(acctcat,"imake")   = sum((mapcat(acctcat,tt),ij,gj), imake(ij,tt,gj));
echop(acctcat,"fs")      = sum((mapcat(acctcat,tt),ij,fj), fs(ij,tt,fj));
echop(acctcat,"trnsfer") = sum((mapcat(acctcat,tt),ij,iij), trnsfer(ij,tt,iij));
echop(acctcat,"fexprt")  = sum((mapcat(acctcat,tt),fj,tj), fexprt(fj,tt,tj));
echop(acctcat,"fimprt")  = sum((mapcat(acctcat,tt),tj,fj), fimprt(tj,tt,fj));
echop(acctcat,"sexport") = sum((mapcat(acctcat,tt),sj,tj), sexport(sj,tt,tj));
echop(acctcat,"simport") = sum((mapcat(acctcat,tt),tj,sj), simport(tj,tt,sj));
echop(acctcat,"iexport") = sum((mapcat(acctcat,tt),ij,tj), iexport(ij,tt,tj));
echop(acctcat,"iimport") = sum((mapcat(acctcat,tt),tj,ij), iimport(tj,tt,ij));
echop(acctcat,"trnshp")  = sum((mapcat(acctcat,tt),tj,ttj), trnshp(tj,tt,ttj));

echop(tt,"make")    = sum((sj,gj),make(sj,tt,gj)); echop(gj,"make") = 0;
echop(tt,"use")     = sum((gj,sj),use(gj,tt,sj)); echop(gj,"use") = 0;
echop(tt,"iuse")    = sum((gj,ij), iuse(gj,tt,ij)); echop(gj,"iuse") = 0;
echop(tt,"fd")      = sum((fj,sj), fd(fj,tt,sj)); echop(gj,"fd") = 0;
echop(tt,"imake")   = sum((ij,gj),imake(ij,tt,gj)); echop(gj,"imake") = 0;
echop(tt,"fs")      = sum((ij,fj),fs(ij,tt,fj)); echop(gj,"fs") = 0;
echop(tt,"trnsfer") = sum((ij,iij),trnsfer(ij,tt,iij)); echop(gj,"trnsfer") = 0;
echop(tt,"fexprt")  = sum((fj,tj),fexprt(fj,tt,tj)); echop(gj,"fexprt") = 0;
echop(tt,"fimprt")  = sum((tj,fj),fimprt(tj,tt,fj)); echop(gj,"fimprt") = 0;
echop(tt,"sexport") = sum((sj,tj),sexport(sj,tt,tj)); echop(gj,"sexport") = 0;
echop(tt,"simport") = sum((tj,sj),simport(tj,tt,sj)); echop(gj,"simport") = 0;
echop(tt,"iexport") = sum((ij,tj),iexport(ij,tt,tj)); echop(gj,"iexport") = 0;
echop(tt,"iimport") = sum((tj,ij),iimport(tj,tt,ij)); echop(gj,"iimport") = 0;
echop(tt,"trnshp")  = sum((tj,ttj),trnshp(tj,tt,ttj)); echop(gj,"trnshp") = 0;

set datasym /make,use,imake,iuse,fd,fs,trnsfer,fexprt,fimprt,sexport,simport,
        iexport,iimport,trnshp/;
set ttdrop(tt) /
        trns    "Transfers (15010)"
        srpl    "Surplus or Deficit (15011)"
        fact    "Factor Trade (15037)"
        cuse    "Commodity Use (15050)"
        ctrd    "Commodity Trade (15051)"
        cmke    "Commodity Make (15052)"
        frpt    "Factor Receipts (15053)"/;
echop(ttdrop,datasym) = 0;

display echop;

parameter echodata;
echodata("fs",j,tt,jj) = fs(j,tt,jj);
echodata("trnsfer",j,tt,jj) = trnsfer(j,tt,jj);
set pivotitem /fs,trnsfer/;
set fij(*); fij(fj) =yes; fij(ij) = yes;
*.$setglobal workbook 'echop.xls'
*.$libinclude pivotdata echodata pivotitem ij tt fij

$if not set diagonal $goto suppress

*   Diagonalize the dataset:

parameter   output,supply,theta,use_,simport_,fd_;
alias (gj,ggj);

$onuni
output(gj,tj) = sum(sj, sexport(sj,gj,tj));
supply(sj) = sum((ggj,tt), make(sj,tt,ggj)) + sum((ggj,tj), sexport(sj,ggj,tj));

*   Fraction of production in sector s devoted to commodity g:

theta(gj,sj)$supply(sj)
    = (sum(tt, make(sj,tt,gj))+ sum(tj,sexport(sj,gj,tj))) / supply(sj);
$offuni

output(gj,"dmkt") = sum((sj,tt), make(sj,tt,gj));

*   Convert production structure into a commodity rather than industry basis:
 
use_(ggj,tt,gj)   = sum(sj, theta(gj,sj)*use(ggj,tt,sj));
simport_(tj,tt,gj) = sum(sj, theta(gj,sj)*simport(tj,tt,sj));
fd_(fj,tt,gj)     = sum(sj, theta(gj,sj)*fd(fj,tt,sj));

*   Write out the data to a temporary GDX file:

PUTCLOSE 'Writing .\Data\tempdata\%ds%.gdx'/;
$call 'if not exist .\Data\tempdata\nul mkdir .\Data\tempdata'
execute_unload '.\Data\tempdata\%ds%.gdx',gj=g,fj=f,tt=t,ij=i,j,output,use_=use,iuse,fd_=fd,
   fexprt,imake,fs,trnsfer,fimprt,trnshp,iexport,simport_=simport,iimport;

$EXIT

$label suppress

*       Suppress vacuous sectors:

SET     drops(j)        Sectors which are not used;
drops(sj) = YES$(SUM((tt,gj),make(sj,tt,gj))+SUM((tt,tj),sexport(sj,tt,tj)) EQ 0);
sj(drops) = NO;

*   Write out the data to a temporary GDX file:

PUTCLOSE 'Writing .\data\tempdata\%ds%.gdx'/;
$call 'if not exist .\data\tempdata\nul mkdir .\data\tempdata'
execute_unload '.\data\tempdata\%ds%.gdx',sj=s,gj=g,fj=f,tt=t,tj=trd,ij=i,j,make,use,iuse,fd,
   fexprt,imake,fs,trnsfer,fimprt,trnshp,sexport,iexport,simport,iimport;

make(j,tt,jj) = min(0, make(j,tt,jj));
use(j,tt,jj) = min(0, use(j,tt,jj));
iuse(j,tt,jj) = min(0, iuse(j,tt,jj));
fd(j,tt,jj) = min(0, fd(j,tt,jj));
fexprt(j,tt,jj) = min(0, fexprt(j,tt,jj));
imake(j,tt,jj) = min(0, imake(j,tt,jj));
fs(j,tt,jj) = min(0, fs(j,tt,jj));
trnsfer(j,tt,jj) = min(0, trnsfer(j,tt,jj));
fimprt(j,tt,jj) = min(0, fimprt(j,tt,jj));
trnshp(j,tt,jj) = min(0, trnshp(j,tt,jj));
sexport(j,tt,jj) = min(0, sexport(j,tt,jj));
iexport(j,tt,jj) = min(0, iexport(j,tt,jj));
simport(j,tt,jj) = min(0, simport(j,tt,jj));
iimport(j,tt,jj) = min(0, iimport(j,tt,jj));
display "Negative values:",make,use,iuse,fd,fexprt,imake,fs,trnsfer,
    fimprt,trnshp,sexport,iexport,simport,iimport;
