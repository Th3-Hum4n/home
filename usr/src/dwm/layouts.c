/* function declarations */
static void tile(Monitor *);
static void monocle(Monitor *m);
static void bstack(Monitor *m);
static void centeredmaster(Monitor *m);
static void deck(Monitor *m);
static void fibonacci(Monitor *mon, int s);
static void dwindle(Monitor *mon);
static void spiral(Monitor *mon);

void
tile(Monitor *m)
{
	unsigned int i, n, h, mw, my, ty, ns;
	float mfacts = 0, sfacts = 0;
	Client *c;

	for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++) {
        if (n < m->nmaster)
			mfacts += c->cfact;
		else
			sfacts += c->cfact;
	}
	if (n == 0)
		return;

    if (n > m->nmaster) {
		mw = m->nmaster ? m->ww * m->mfact : 0;
        ns = m->nmaster > 0 ? 2 : 1;
    } else  {
		mw = m->ww;
        ns = 1;
    }

	for (i = 0, my = ty = gappx, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
		if (i < m->nmaster) {
			h = (m->wh - my) * (c->cfact / mfacts) - gappx;
			resize(c, m->wx + gappx, m->wy + my, mw - (2*c->bw) - gappx*(5-ns)/2, h - (2*c->bw));
			my += HEIGHT(c) + gappx;
			mfacts -= c->cfact;
		} else {
			h = (m->wh - ty) * (c->cfact / sfacts) - gappx;
			resize(c, m->wx + mw + gappx/ns, m->wy + ty, m->ww - mw - (2*c->bw) - gappx*(5-ns)/2, h - (2*c->bw));
			ty += HEIGHT(c) + gappx;
			sfacts -= c->cfact;
		}
}

void
monocle(Monitor *m)
{
	unsigned int n = 0;
	Client *c;

	for (c = m->clients; c; c = c->next)
		if (ISVISIBLE(c))
			n++;

	if (n > 0) /* override layout symbol */
		snprintf(m->ltsymbol, sizeof m->ltsymbol, "[%d]", n);
    else /* need this for the fifo. */
        snprintf(m->ltsymbol, sizeof m->ltsymbol, "[M]");
    for (c = nexttiled(m->clients); c; c = nexttiled(c->next)) {
        resize(c, m->wx + gappx, m->wy + gappx, m->ww - 2 * c->bw - 2 * gappx, m->wh -2 * c->bw - 2 * gappx);
    }
}

void
deck(Monitor *m)
{
	int dn;
	unsigned int i, n, h, mw, my, ns;
	Client *c;

	for(n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++);
	if(n == 0)
		return;

	dn = n - m->nmaster;
	if(dn > 0) /* override layout symbol */
		snprintf(m->ltsymbol, sizeof m->ltsymbol, "[] %d", dn);

    if(n > m->nmaster) {
		mw = m->nmaster ? m->ww * m->mfact : 0;
        ns = m->nmaster > 0 ? 2 : 1;
    }
    else {
		mw = m->ww;
        ns = 1;
    }

	for(i = 0, my = gappx, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
		if(i < m->nmaster) {
			h = (m->wh - my) / (MIN(n, m->nmaster) - i) - gappx;
			resize(c, m->wx + gappx, m->wy + my, mw - (2*c->bw) - gappx*(5-ns)/2, h - (2*c->bw));
			my += HEIGHT(c) + gappx;
		}
		else
			resize(c, m->wx + mw + gappx/ns, m->wy + gappx, m->ww - mw - (2*c->bw) - gappx*(5-ns)/2, m->wh - (2*c->bw) - gappx*2);
}

void
fibonacci(Monitor *mon, int s)
{
	unsigned int i, n, nx, ny, nw, nh;
	Client *c;

	for(n = 0, c = nexttiled(mon->clients); c; c = nexttiled(c->next), n++);
	if(n == 0)
		return;

	nx = mon->wx;
	ny = 0;
	nw = mon->ww;
	nh = mon->wh;

	for(i = 0, c = nexttiled(mon->clients); c; c = nexttiled(c->next)) {
		if((i % 2 && nh / 2 > 2 * c->bw)
		   || (!(i % 2) && nw / 2 > 2 * c->bw)) {
			if(i < n - 1) {
				if(i % 2)
					nh /= 2;
				else
					nw /= 2;
				if((i % 4) == 2 && !s)
					nx += nw;
				else if((i % 4) == 3 && !s)
					ny += nh;
			}
			if((i % 4) == 0) {
				if(s)
					ny += nh;
				else
					ny -= nh;
			}
			else if((i % 4) == 1)
				nx += nw;
			else if((i % 4) == 2)
				ny += nh;
			else if((i % 4) == 3) {
				if(s)
					nx += nw;
				else
					nx -= nw;
			}
			if(i == 0)
			{
				if(n != 1)
					nw = mon->ww * mon->mfact;
				ny = mon->wy;
			}
			else if(i == 1)
				nw = mon->ww - nw;
			i++;
		}
		resize(c, nx + gappx, ny + gappx, nw - 2 * c->bw - gappx*2, nh - 2 * c->bw - gappx*2);
	}
}

void
dwindle(Monitor *mon) {
	fibonacci(mon, 1);
}

void
spiral(Monitor *mon) {
	fibonacci(mon, 0);
}

void
bstack(Monitor *m) {
	int w, h, mh, mx, tx, ty, tw;
	unsigned int i, n;
	Client *c;

	for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++);
	if (n == 0)
		return;
	if (n > m->nmaster) { /* there are clients in the stack */
		mh = m->nmaster ? m->mfact * m->wh : gappx;
		tw = (m->ww - (n - m->nmaster + 1) * gappx) / (n - m->nmaster);
		ty = m->wy + mh + gappx;
	} else {
		mh = m->wh;
		tw = m->ww;
		ty = m->wy;
	}
	for (i = 0, mx = tx = gappx, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++) {
		if (i < m->nmaster) { // Modifies master windows
			w = (m->ww - mx) / (MIN(n, m->nmaster) - i) - gappx;
			resize(c, m->wx + mx, m->wy + gappx, w - (2 * c->bw), mh - 2 * (c->bw + gappx));
			mx += WIDTH(c) + gappx;
		} else { // Modifies stack windows
			h = m->wh - mh - gappx;
            if (barpos == 2) tx = m->wx + gappx;
			resize(c, tx, ty - gappx, tw - (2 * c->bw), h - (2 * c->bw));
			if (tw != m->ww) // if there's more than one client in the stack!
				tx += WIDTH(c) + gappx;
		}
	}
}


void
centeredmaster(Monitor *m)
{
	unsigned int i, n, h, mw, mx, my, oty, ety, tw;
	Client *c;

	/* count number of clients in the selected monitor */
	for (n = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), n++);
	if (n == 0)
		return;

	/* initialize areas */
	mw = m->ww;
	mx = 0;
	my = 0;
	tw = mw;

	if (n > m->nmaster) {
		/* go mfact box in the center if more than nmaster clients */
		mw = m->nmaster ? m->ww * m->mfact : 0;
		tw = m->ww - mw;

		if (n - m->nmaster > 1) {
			/* only one client */
			mx = (m->ww - mw) / 2;
			tw = (m->ww - mw) / 2;
		}
	}

	oty = 0;
	ety = 0;
	for (i = 0, c = nexttiled(m->clients); c; c = nexttiled(c->next), i++)
	if (i < m->nmaster) {
		/* nmaster clients are stacked vertically, in the center
		 * of the screen
         */
		h = (m->wh - my) / (MIN(n, m->nmaster) - i) - gappx*2;
		resize(c, m->wx + mx + gappx, m->wy + my + gappx, mw - (2*c->bw) - gappx, h - (2*c->bw));
		my += HEIGHT(c) + gappx;
	} else {
		/* stack clients are stacked vertically */
		if ((i - m->nmaster) % 2) {
			h = (m->wh - ety) / ( (1 + n - i) / 2) - gappx*2;
			resize(c, m->wx + gappx, m->wy + ety + gappx, tw - (2*c->bw) - gappx, h - (2*c->bw));
			ety += HEIGHT(c) + gappx;
		} else {
			h = (m->wh - oty) / ((1 + n - i) / 2) - gappx*2;
			resize(c, m->wx + mx + mw + gappx, m->wy + oty + gappx, tw - (2*c->bw) - gappx, h - (2*c->bw));
			oty += HEIGHT(c) + gappx;
		}
	}
}
