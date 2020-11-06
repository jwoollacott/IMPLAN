$if not set target $set target gtap

*	Define sets and parameters:

SET	f(*)	Factors,
	t(*)	Accounts,
	i(*)	Institutions
	g(*)	Goods and sectors
	r(*)    Aggregate regions
	j(*)	Aggregated SAM accounts;
$GDXIN 'data\%target%\%target%_dtrdbal.gdx'
$load f t i j g r

SET	h(i)	Households
	pub(i)	Public entities
	corp(i)	Corporate entities;
$load h pub corp

ALIAS (s,g,ss,gg) , (h,hh) , (i,ii) , (r,rr) , (f,ff);

SET	mkt /dmkt,ftrd,dtrd/,
	trd(mkt)/ftrd,dtrd/;

PARAMETER
	vom(r,s)	Aggregate output
	vx(r,s)		Aggregate exports
	vdxm(r,s,trd)	Output to export markets
	vdfm(r,g,s)	2Domestic intermediate demand
	vifm(r,g,trd,s) Imported intermediate demand
	vfm(r,f,s)	Factor demand
	vxm(r,s,trd)	National and international exports
	vim(r,g,trd)	Aggregate imports
	vpm(r,h)	Aggregate consumption
	vdpm(r,g,h)	Domestic consumption demand
	vipm(r,g,trd,h) Imported consumption demand
	vinv(r)		Aggregate investment
	vdim(r,g)	Domestic investment demand
	viim(r,g,trd)	Imported investment demand
	vgm(r,pub)	Public sector demand
	vdgm(r,g,pub)	Domestic public demand
	vigm(r,g,trd,pub) Imported public demand
	evom(r,f,i,t)	Factor supply,
	evpm(r,g,i)	Goods supply (make and export),
	vprf(r,i)	Corporate profit
	vtrn(r,i,t)	Transfers
	vdmi(r,s)	Domestic output including institutional imake
	trnsfer(r,i,t,ii)	Inter-institutional transfers;

*	Read benchmark data:

$load vom vx vdxm vdfm vifm vfm vxm vim vpm vdpm vipm vinv vdim viim vgm vdgm vigm evom evpm
$load vprf vtrn vdmi trnsfer

