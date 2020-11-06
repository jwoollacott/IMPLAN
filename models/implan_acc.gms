$title  Simple Static State-Level Model

$if not set ds $set ds ak

$batinclude models\statedata
*$batinclude statedata

$ontext
$model:soe

$sectors:
        y(s)$vom(s)             ! Sectoral production
        m(g,trd)$vim(g,trd)     ! Commodity imports
        cd(h)$vpm(h)            ! Household demand
        gd(pub)$vgm(pub)        ! Government demand
        id                      ! Investment demand

$commodities:
        py(g)$vom(g)            ! Domestic output
        pm(g,trd)$vim(g,trd)    ! Import price

        pc(h)$vpm(h)            ! Household demand
        pi                      ! Investment
        pg(pub)        	       ! Public demand
        pr(f)                   ! Factor supplies
        prf                     ! Corporate profits
        pfx                     ! Foreign exchange

$consumers:
        rh(h)                   ! Representative households
        rg(pub)        	       ! Representative public institutions
        firms                   ! Representative firms

$auxiliary:
        x(s)$vx(s)              ! Sectoral exports
        fx                      ! Foreign exchange earnings

$prod:y(s)$vom(s)  s:0 t:1  va:1 g.tl:4
        o:py(s)        	q:vom(s)
        i:py(g)        	q:vdfm(g,s)     g.tl:
        i:pm(g,trd)      q:vifm(g,trd,s) g.tl:
        i:pr(f)        	q:vfm(f,s)      va:

$prod:m(g,trd)$vim(g,trd)
        o:pm(g,trd)      q:vim(g,trd)
        i:pfx            q:vim(g,trd)

$prod:cd(h)$vpm(h)  s:1  g.tl:4
        o:pc(h)        	q:vpm(h)
        i:py(g)        	q:vdpm(g,h) g.tl:
        i:pm(g,trd)      q:vipm(g,trd,h) g.tl:

$prod:id
        o:pi             q:vinv
        i:py(g)          q:vdim(g)
        i:pm(g,trd)      q:viim(g,trd)

$prod:gd(pub)$vgm(pub)
        o:pg(pub)        q:vgm(pub)
        i:py(g)          q:vdgm(g,pub)
        i:pm(g,trd)      q:vigm(g,trd,pub)

$demand:rh(h)$vpm(h)
        d:pc(h)          q:vpm(h)
        e:prf            q:vprf(h)
        e:pr(f)          q:(sum(t,evom(f,h,t)))
        e:py(g)        	q:evpm(g,h)
        e:pfx            q:(sum(t,vtrn(h,t)))

$demand:rg(pub)$vgm(pub)
        d:pg(pub)        q:vgm(pub)
        e:prf            q:vprf(pub)
        e:pr(f)          q:(sum(t,evom(f,pub,t)))
        e:py(g)        	q:evpm(g,pub)
        e:pfx            q:(sum(t,vtrn(pub,t)))

$demand:firms
        d:prf            q:(sum(i,vprf(i)))
        e:pi             q:(-vinv)
        e:pr(f)        	q:(sum((corp,t),evom(f,corp,t)))
        e:py(g)        	q:(sum(corp,evpm(g,corp)))
        e:pfx            q:(sum((corp,t),vtrn(corp,t)))
        e:py(s)$vx(s)    q:(-1)  r:x(s)
        e:pfx            q:1     r:fx

$constraint:x(s)$vx(s)
        x(s) =e= sum(trd, vxm(s,trd) * (pfx/py(s))**5);

$constraint:fx
        fx * pfx =e= sum(s$vx(s), py(s)*x(s));

$offtext
$sysinclude mpsgeset soe

x.l(s) = vx(s);
fx.l = sum(s, vx(s));

soe.workspace = 1000;
soe.iterlim = 0;
$include soe.gen
solve soe using mcp;

