$title  Simple Static Small Open Economy Model with Intra-national Trade

$if not set target $set target gtap

*       Read the dataset using the utility program:

$batinclude models\regionaldata

*       Define set for primary factor of production and taxes:

SET  fa(f) /empl,prop,othp/
     ft(f) /btax/;

ALIAS (fa,ffa);

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
vn(g) = sum(r, vxm(r,g,"dtrd"))+eps;

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

*       Define value share parameters to simplify algebra:

PARAMETER
        thetai(r,s)     Value share of intermediate input
        thetaf(r,s)     Value added share of sectoral output
        thetae(r,s)     Value share of emmissions
        thetat(r,s)     Value share of business taxes;

thetai(r,s)$vdmi(r,s) = sum(g,vdifm(r,g,s))/(vdmi(r,s)+sum(trd,vxm(r,s,trd)));
thetaf(r,s)$vdmi(r,s) = sum(fa,vfm(r,fa,s)/(vdmi(r,s)+sum(trd,vxm(r,s,trd))));
thetae(r,s)$vdmi(r,s) = emit(r,s)/(vdmi(r,s)+sum(trd,vxm(r,s,trd)));
thetat(r,s)$vdmi(r,s) = vfm(r,"btax",s)/(vdmi(r,s)+sum(trd,vxm(r,s,trd)));

*--------------------------------------------------------------------------
*       Formulate a stylized SOE US regional model in GAMS/MCP based on
*       hese statistics and verify that the resulting data represents
*       an equilibrium:

POSITIVE VARIABLES
        y(r,s)          Sectoral production
        a(r,s)          Armington aggregation
        c(r,h)          Consumption by household
        gov(r,pub)      Public output
        inv(r)          Investment

        p(r,s)          Sectoral output prices
        pa(r,s)         Armington aggregate prices
        pc(r,h)         Consumption by household
        pn(s)           Intra-national trade price
        pinv(r)         New investment
        pgov(r,pub)     Public output
        pf(r,fa)        Factor prices
        pfx             Foreign exchange
        pcarb           Tradable CO2 emission permit price
        ptax(r)         Business taxes

        rh(r,h)         Representative households
        govt(r,pub)     Government (different levels)
        taxrev          Tax revenue agent

        target          Rationing variable for emission permits

        cf(r,s)         User cost index for primary factors
        ca(r,s)         User cost index for Armington inputs
        cfn(r,g)        User cost index for domestic and imported inputs
        dfm(fa,r,s)     Sectoral demand for primary factors
        dfx(r,g)        Armington demand for foreign exchange
        dfn(r,g)        Armington demand for domestic trade
        da(r,s,g)       Sectoral demand for Armington good
        dad(r,g)        Armington demand for domestic output
        py(r,s)         Price for sectoral output;

EQUATIONS
        prf_y(r,s)      Sectoral production
        prf_a(r,s)      Armington aggregation
        prf_c(r,h)      Consumption by household
        prf_gov(r,pub)  Public output
        prf_inv(r)      Investment

        mkt_p(r,s)      Sectoral output prices
        mkt_pa(r,s)     Armington aggregate prices
        mkt_pc(r,h)     Consumption by household
        mkt_pn(s)       Intra-national trade price
        mkt_pinv(r)     New investment
        mkt_pgov(r,pub) Public output
        mkt_pf(r,fa)    Factor prices
        mkt_pfx         Foreign exchange
        mkt_pcarb       Tradable CO2 emission permit price
        mkt_ptax(r)     Business taxes

        inc_rh(r,h)     Representative households
        inc_govt(r,pub) Government (different levels)
        inc_taxrev(r)   Tax revenue agent

        eq_cf(r,s)
        eq_ca(r,s)      User cost index for Armington inputs
        eq_cfn(r,g)     User cost index for domestic and imported inputs
        eq_dfm(fa,r,s)  Sectoral demand for primary factors
        eq_dfx(r,g)     Armington demand for foreign exchange
        eq_dfn(r,g)     Armington demand for domestic trade
        eq_da(r,s,g)    Sectoral demand for Armington good
        eq_dad(r,g)     Armington demand for domestic output
        eq_py(r,s)      Price for sectoral output;


*       Equation definitions to simplify algebra:

eq_cf(r,s)$(sum(fa,vfm(r,fa,s))).. cf(r,s) =e= prod(fa, pf(r,fa)**(vfm(r,fa,s)
                                 /sum(ffa,vfm(r,ffa,s))));

eq_ca(r,s)$(sum(g, vdifm(r,g,s))).. ca(r,s) =e= 
				sum(g, vdifm(r,g,s)/sum(gg,vdifm(r,gg,s)) * PA(r,g));

eq_cfn(r,g)$(sum(trd,vim(r,g,trd))).. cfn(r,g) =e= 
			(vim(r,g,"ftrd")/sum(trd,vim(r,g,trd))*PFX**(1-es_t)
                                + vim(r,g,"dtrd")/sum(trd,vim(r,g,trd))
                                 *PN(g)**(1-es_t))**(1/(1-es_t));

eq_dfm(fa,r,s).. dfm(fa,r,s) =e= vfm(r,fa,s)*Y(r,s)*cf(r,s)/pf(r,fa);

eq_dfx(r,g).. dfx(r,g) =e= A(r,g) * vim(r,g,"ftrd")
                           *(PA(r,g)/cfn(r,g))**es_a * (cfn(r,g)/PFX)**es_t;

eq_dfn(r,g).. dfn(r,g) =e= A(r,g) * vim(r,g,"dtrd")
                          *(cfn(r,g)/PA(r,g))**(-es_a) * (cfn(r,g)/PN(g))**es_t;

eq_da(r,s,g).. da(r,s,g) =e= vdifm(r,g,s)*Y(r,s);

eq_dad(r,g).. dad(r,g) =e= vdmi(r,g)*A(r,g)*(PA(r,g)/P(r,g))**es_a;

eq_py(r,s)$(vdmi(r,s)+sum(trd,vxm(r,s,trd))).. py(r,s) =e=
            (vdmi(r,s)/(vdmi(r,s)+sum(trd,vxm(r,s,trd)))*P(r,s)**(1+eta)
           + vxm(r,s,"ftrd")/(vdmi(r,s)+sum(trd,vxm(r,s,trd)))*PFX**(1+eta)
           + vxm(r,s,"dtrd")/(vdmi(r,s)+sum(trd,vxm(r,s,trd)))*PN(s)**(1+eta)
           )**(1/(1+eta));

*       Zero profit conditions:

prf_y(r,s)$((vdmi(r,s)+sum(trd,vxm(r,s,trd))))
        .. thetai(r,s)*ca(r,s) + thetaf(r,s)*cf(r,s) + thetae(r,s)*PCARB
             + thetat(r,s)*PTAX(r) =e= py(r,s);

prf_a(r,s)$va(r,s).. (vdmi(r,s)/va(r,s)*(P(r,s)**(1-es_a)) + sum(trd,vim(r,s,trd))
                /va(r,s)*cfn(r,s)**(1-es_a))**(1/(1-es_a)) =e= PA(r,s);

prf_inv(r).. sum(g, PA(r,g) * vinvd(r,g)) =e= PINV(r) * vinv(r);

prf_gov(r,pub).. sum(g, PA(r,g) * (vdgm(r,g,pub)+sum(trd,vigm(r,g,trd,pub))))
                        =e= PGOV(r,pub) * vgm(r,pub);

prf_c(r,h).. pc(r,h) =e= prod(s, pa(r,s)**((vdpm(r,s,h)
                         + sum(trd,vipm(r,s,trd,h)))
                        /sum(ss,(vdpm(r,ss,h) + sum(trd,vipm(r,ss,trd,h))))));

*       Market clearing conditions:

mkt_p(r,s)$(vdmi(r,s)+sum(trd,vxm(r,s,trd))).. vdmi(r,s)*Y(r,s)*(P(r,s)/PY(r,s))**eta 
						=e= dad(r,s);

mkt_pa(r,s)$va(r,s).. va(r,s)*A(r,s) =e= sum(g, da(r,g,s))
       + sum(h, (vdpm(r,s,h)+sum(trd,vipm(r,s,trd,h)))*PC(r,h)/PA(r,s)*C(r,h))
       + vinvd(r,s)*INV(r)
       + sum(pub, (vdgm(r,s,pub)+sum(trd,vigm(r,s,trd,pub)))*GOV(r,pub));

mkt_pn(s).. sum(r, vxm(r,s,"dtrd")*Y(r,s)*(PN(s)/PY(r,s))**eta)
                          =e= sum(r, dfn(r,s));

mkt_pinv(r)..   vinv(r) * INV(r) =e= sum(h, vinvh(r,h));

mkt_pgov(r,pub).. vgm(r,pub) * GOV(r,pub) * PGOV(r,pub) =e= GOVT(r,pub);

mkt_pf(r,fa).. sum(h,evo(r,h,fa)) =e= sum(s, dfm(fa,r,s));

mkt_pfx..  sum((r,h), incadj(r,h)) + sum((r,pub), vgm(r,pub))
           + sum((r,s), vxm(r,s,"ftrd")*Y(r,s)*(PFX/PY(r,s))**eta)
           =e= sum((r,s), dfx(r,s)) + sum(r, taxrev(r)/PFX);

mkt_pc(r,h).. vpm(r,h) * C(r,h) * PC(r,h) =e= RH(r,h);

mkt_pcarb.. sum((r,pub),carbontarget(r)$(ord(pub) eq 1)) =e= sum((r,s), emit(r,s) * Y(r,s));

mkt_ptax(r)..   sum(s,vfm(r,"btax",s)) =e= sum(s, vfm(r,"btax",s) * Y(r,s));

*       Income definitions:

inc_rh(r,h).. RH(r,h) =e= sum(fa, pf(r,fa)*evo(r,h,fa))
                          + pfx*incadj(r,h) + pinv(r)*(-vinvh(r,h));

inc_govt(r,pub).. GOVT(r,pub) =e= pfx*vgm(r,pub) + pcarb*carbontarget(r)$(ord(pub) eq 1);

inc_taxrev(r).. TAXREV(r) =e= ptax(r) * sum(s, vfm(r,"btax",s));

*       Define model and match equations and variables:

model soe_mcp /prf_y.y,prf_a.a,prf_c.c,prf_gov.gov,prf_inv.inv,mkt_p.p,
               mkt_pa.pa,mkt_pc.pc,mkt_pn.pn,mkt_pinv.pinv,mkt_pgov.pgov,
               mkt_pf.pf,mkt_pfx.pfx,mkt_pcarb.pcarb,mkt_ptax.ptax,inc_rh.rh,
               inc_govt.govt,inc_taxrev.taxrev,eq_cf.cf,
               eq_ca.ca,eq_cfn.cfn,eq_dfm.dfm,eq_dfx.dfx,eq_dfn.dfn,eq_da.da,
               eq_dad.dad,eq_py.py/;

*       Assign default values:

y.l(r,s)=1;a.l(r,s)=1;c.l(r,h)=1;gov.l(r,pub)=1;inv.l(r)=1;p.l(r,s)=1;
pa.l(r,s)=1;pc.l(r,h)=1;pn.l(s)=1;pinv.l(r)=1;pgov.l(r,pub)=1;pf.l(r,fa)=1;
pfx.l=1;pcarb.l=0;ptax.l(r)=1;rh.l(r,h)=vpm(r,h);govt.l(r,pub)=vgm(r,pub);
cf.l(r,s)=1;ca.l(r,s)=1;cfn.l(r,g)=1;dfm.l(fa,r,s)=vfm(r,fa,s);
dfx.l(r,g)=vim(r,g,"ftrd");dfn.l(r,g)=vim(r,g,"dtrd");da.l(r,s,g)=vdifm(r,g,s);
dad.l(r,g)=vdmi(r,g);py.l(r,s)=1;taxrev.l(r)=sum(s, vfm(r,"btax",s));

*       Fix variables which should not be in the model:

PN.fx(s)$(vn(s)=0) =1;

*       Choose a numeraire:

PFX.fx =1;

*       Verify benchmark consistency:

soe_mcp.iterlim = 0;
solve soe_mcp using mcp;


