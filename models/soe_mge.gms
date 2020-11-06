$title  Simple Static Small Open Economy Model with Intra-national Trade

$if not set target $set target gtap

*       Read the dataset using the utility program:

$batinclude models\regionaldata

*       Define set for primary factor of production and taxes:

SET  fa(f) /empl,prop,othp/
     ft(f) /btax/;

*       Install parameters for model specification:

PARAMETER
        vdifm(r,g,s)    Total intermediate demand
        evo(r,i,f)      Factor endowment by institution
        va(r,s)         Armington supply including imports
        vn(g)           Intra-national trade
        vinvd(r,g)      Investment demand by commodity
        vinvh(r,h)      Investment demand by household
        incadj(r,h)     Base year net transfer
        tc(r,s)         Carbon tax rate
        carbontarget    Carbon emissions target
        emit(r,s)       Base year emissions;	

vdifm(r,g,s) = vdfm(r,g,s) + sum(trd, vifm(r,g,trd,s));
evo(r,i,f) = sum(t, evom(r,f,i,t));
va(r,s) = sum(trd,vim(r,s,trd)) +  vdmi(r,s);
vn(g) = sum(r, vxm(r,g,"dtrd"));

*       Impute investment demand to households:

vinvd(r,g) = va(r,g)  - (sum(h,vdpm(r,g,h))+sum((trd,h),vipm(r,g,trd,h)))
                - (sum(pub,vdgm(r,g,pub))+sum((trd,pub),vigm(r,g,trd,pub)))
                - sum(s, vdifm(r,g,s));

*       Impute wage payments, capital payments:

vfm(r,"empl",s) = max(vdmi(r,s)+sum(trd,vxm(r,s,trd))
                  - (vfm(r,"prop",s) + vfm(r,"othp",s)) - vfm(r,"btax",s)
                  - sum(g, vdifm(r,g,s)), 0);
vfm(r,"prop",s) = max(vdmi(r,s)+sum(trd,vxm(r,s,trd))
                  - (vfm(r,"empl",s) + vfm(r,"othp",s)) - vfm(r,"btax",s)
                  - sum(g, vdifm(r,g,s)), 0);
vfm(r,"othp",s) = max(vdmi(r,s)+sum(trd,vxm(r,s,trd))
                  - (vfm(r,"empl",s) + vfm(r,"prop",s)) - vfm(r,"btax",s)
                  - sum(g, vdifm(r,g,s)), 0);
vfm(r,"btax",s) = vdmi(r,s)+sum(trd,vxm(r,s,trd))
                  - (vfm(r,"prop",s) + vfm(r,"othp",s)) - vfm(r,"empl",s)
                  - sum(g, vdifm(r,g,s));

*       Scale labor endowments to match imputed wage payments:

evo(r,h,"empl") = evo(r,h,"empl")/sum(hh, evo(r,hh,"empl"))
                  * sum(s, vfm(r,"empl",s));
evo(r,h,"prop") = evo(r,h,"prop")/sum(hh,evo(r,hh,"prop"))
                  * sum(s, vfm(r,"prop",s));
evo(r,h,"othp") = evo(r,h,"othp")/sum(hh,evo(r,hh,"othp"))
                  * sum(s, vfm(r,"othp",s));

*       Impute aggregate investment and investment demand by household:

vinv(r) = sum(g, vinvd(r,g));
vinvh(r,h)$sum(hh, max(0, sum(t,trnsfer(r,"inv",t,hh) - trnsfer(r,hh,t,"inv"))))
                = max(0, sum(t, trnsfer(r,"inv",t,h) - trnsfer(r,h,t,"inv"))) /
                    sum(hh, max(0, sum(t, trnsfer(r,"inv",t,hh)
                   - trnsfer(r,hh,t,"inv"))))* vinv(r);

*       Adjust household income:

incadj(r,h) = sum(g,vdpm(r,g,h)+sum(trd,vipm(r,g,trd,h)))
              + vinvh(r,h) - sum(f,evo(r,h,f));

*       Base year emissions:

emit(r,s) = 1e-4 * (vdmi(r,s) + sum(trd,vxm(r,s,trd)));
carbontarget(r) = sum(s,emit(r,s));

*        Define elasticity parameters:

PARAMETER
        eta     ES of transformation /2/
        es_a    EOS bw domestic and traded goods /4/
        es_t    EOS bw domestically and foreign traded goods /8/;

*--------------------------------------------------------------------------
*       Formulate a stylized SOE US regional model in GAMS/MPSGE based on
*       hese statistics and verify that the resulting data represents
*       an equilibrium:

$ontext

$model:soe

$sectors:
        y(r,s)$(vdmi(r,s)+sum(trd,vxm(r,s,trd))) ! Sectoral production
        a(r,s)$va(r,s)                 ! Armington aggregation
        c(r,h)                          ! Consumption by household
        gov(r,pub)                      ! Public output
        inv(r)                          ! Investment

$commodities:
        p(r,s)$(vdmi(r,s)+sum(trd,vxm(r,s,trd)))  ! Sectoral output prices
        pc(r,h)                               ! Consumption by household
        pa(r,s)$va(r,s)                       ! Armington aggregate prices
        pn(s)$vn(s)                     ! Intra-national trade price
        pinv(r)                               ! New investment
        pgov(r,pub)                     ! Public output
        pf(r,fa)$(sum(s,vfm(r,fa,s)))   ! Factor prices
        pfx                             ! Foreign exchange
        pcarb           ! Tradable CO2 emission permit price
        ptax(r)$(sum(s,vfm(r,"btax",s))) ! Business taxes

$consumers:
        rh(r,h)                         ! Representative households
        govt(r,pub)                     ! Government (different levels)
        taxrev(r)                       ! Tax revenue agent

$prod:y(r,s)$(vdmi(r,s)+sum(trd,vxm(r,s,trd))) s:0 t:eta  va:1
        o:p(r,s)        q:vdmi(r,s)
        o:pfx           q:vxm(r,s,"ftrd")
        o:pn(s)         q:vxm(r,s,"dtrd")
        i:pa(r,g)       q:vdifm(r,g,s)
        i:pf(r,fa)      q:vfm(r,fa,s)      va:
        i:pcarb         q:emit(r,s)
        i:ptax(r)       q:vfm(r,"btax",s)

$prod:a(r,s)$va(r,s)  s:es_a  m:es_t
        o:pa(r,s)       q:va(r,s)
        i:p(r,s)        q:vdmi(r,s)
        i:pfx           q:vim(r,s,"ftrd")   m:
        i:pn(s)         q:vim(r,s,"dtrd")   m:

$prod:inv(r)
        o:pinv(r)       q:vinv(r)
        i:pa(r,s)       q:vinvd(r,s)

$prod:gov(r,pub)
        o:pgov(r,pub)   q:vgm(r,pub)
        i:pa(r,s)       q:(vdgm(r,s,pub)+sum(trd,vigm(r,s,trd,pub)))

$prod:c(r,h) s:1
        o:pc(r,h)       q:vpm(r,h)
        i:pa(r,s)       q:(vdpm(r,s,h)+sum(trd,vipm(r,s,trd,h)))

$demand:rh(r,h)
        d:pc(r,h)       q:vpm(r,h)
        e:pf(r,fa)      q:evo(r,h,fa)
        e:pfx           q:incadj(r,h)
        e:pinv(r)       q:(-vinvh(r,h))

$demand:govt(r,pub)
        d:pgov(r,pub)   q:vgm(r,pub)
        e:pfx           q:vgm(r,pub)
        e:pcarb         q:(carbontarget(r)$(ord(pub) eq 1))

$demand:taxrev(r)
        d:pfx
        e:ptax(r)       q:(sum(s,vfm(r,"btax",s)))

$report:
	v:yd(r,s)	o:p(r,s)        prod:y(r,s)
	v:yftrd(r,s)	o:pfx	        prod:y(r,s)
	v:ydtrd(r,s)	o:pn(s)         prod:y(r,s)
       
$offtext
$sysinclude mpsgeset soe

*       Choose a numeraire:

PFX.fx = 1;

soe.workspace = 40;
soe.iterlim = 1;
$include soe.gen
solve soe using mcp;
abort$(abs(soe.objval) gt 1e-8) "***Model does not calibrate***";

$exit
*-----------------------------------------------------------------------------------------
*       Run a series of counterfactuals which reduce the amount of emission permits
*	in the economony:

*	Define report parameters:

PARAMETER	rcarbt    Percentage reduction of base year emission (permits)
		rpcarb	  Price of carbon
		cons	  Welfare change by household tpye and region
		no_b	  Benchmark value of national output
	        ro_b     Benchmark value of regional output
		nationaloutput Change in national output (in%)
		regionaloutput Change in regional output (in%);

no_b = sum((r,s),yd.l(r,s)*p.l(r,s) + yftrd.l(r,s)*pfx.l+ydtrd.l(r,s)*pn.l(s));
ro_b(r) = sum(s,yd.l(r,s)*p.l(r,s) + yftrd.l(r,s)*pfx.l+ydtrd.l(r,s)*pn.l(s));

*	Define an iteration index:

SET z /1*4/;

*	Solve a series of models (in the benchmark the price for carbon is zero, ie the cap is not binding):

LOOP(z,

*	Reduce emission permits:

carbontarget(r) = (1-0.02*ord(z))*sum(s,emit(r,s));

soe.iterlim = 10000;
$include soe.gen
solve soe using mcp;

rcarbt(z) = 100*ord(z)*0.02;
cons("CA",h,z) = 100*(c.l("CA",h)-1);
nationaloutput(z) = 100*(sum((r,s),yd.l(r,s)*p.l(r,s) + yftrd.l(r,s)*pfx.l+ydtrd.l(r,s)*pn.l(s))/no_b-1);
regionaloutput(r,z) = 100*(sum(s,yd.l(r,s)*p.l(r,s) + yftrd.l(r,s)*pfx.l+ydtrd.l(r,s)*pn.l(s))/ro_b(r)-1);
rpcarb(z) = pcarb.l;

);

DISPLAY rcarbt,rpcarb,cons,nationaloutput,regionaloutput;





