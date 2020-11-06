SET	f(*)	Factors,
	t(*)	Accounts,
	i(*)	Institutions
	g(*)	Goods and sectors
	j(*)	Aggregated SAM accounts;
*$GDXIN '..\data\noaggr\%ds%.gdx'
$GDXIN 'data\noaggr\%ds%.gdx'
$load f t i g j

set	h(i)	Households
	pub(i)	Public entities
	corp(i)	Corporate entities;

$load h pub corp

alias (s,g) , (h,hh) , (i,ii);

SET	mkt /dmkt,ftrd,dtrd/,
	trd(mkt)/ftrd,dtrd/;

parameter
	vom(s)		Aggregate output
	vx(s)		Aggregate exports

	vdxm(s,trd)	Output to export markets
	vdfm(g,s)	Domestic intermediate demand
	vifm(g,trd,s)	Imported intermediate demand
	vfm(f,s)	Factor demand
	vxm(s,trd)	National and international exports
	vx(s)		Aggregate exports
	vim(g,trd)	Aggregate imports
	vpm(h)		Aggregate consumption
	vdpm(g,h)	Domestic consumption demand
	vipm(g,trd,h)	Imported consumption demand
	vinv		Aggregate investment
	vdim(g)		Domestic investment demand
	viim(g,trd)	Imported investment demand
	vgm(pub)	Public sector demand
	vdgm(g,pub)	Domestic public demand
	vigm(g,trd,pub)	Imported public demand
	evom(f,i,t)	Factor supply,
	evpm(g,i)	Goods supply (make and export),
	vprf(i)		Corporate profit
	vtrn(i,t)	Transfers
	vdmi(s)		Domestic output including institutional imake
	trnsfer(i,t,ii)	Inter-institutional transfers;

$load vdxm vdfm vifm vfm vxm vdpm vipm  
$load vdim viim vdgm vigm vprf evom evpm vtrn vdmi trnsfer

vom(s) = sum(g,vdfm(g,s)) + sum((g,trd),vifm(g,trd,s)) + sum(f, vfm(f,s));
vim(g,trd) = sum(s, vifm(g,trd,s)) + sum(h, vipm(g,trd,h)) + viim(g,trd) 
		+ sum(pub, vigm(g,trd,pub));
vx(s) = sum(trd, vxm(s,trd));
vgm(pub) = sum(g, vdgm(g,pub) + sum(trd, vigm(g,trd,pub)));
vinv = sum(g, vdim(g) + sum(trd, viim(g,trd)));
vpm(h) = sum(g,vdpm(g,h) + sum(trd, vipm(g,trd,h)));

PARAMETER	benchchk	Benchmark consistency check;

benchchk(g,"market") = vom(g) + sum(i,evpm(g,i))
		 - sum(s, vdfm(g,s))-sum(h,vdpm(g,h))-vdim(g)-sum(pub,vdgm(g,pub))
		 - vx(g);
benchchk(g,"mkt%")$vom(g) = benchchk(g,"market")/vom(g);

DISPLAY benchchk;

display vom;