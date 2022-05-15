From: Menglong Dong <menglong8.dong@gmail.com>
Subject: Re: [PATCH net-next v2] net: ipvs: randomize starting destination of
 RR/WRR scheduler
Date: Sun, 15 May 2022 21:47:19 +0800
Message-ID: <CADxym3YVOKH4zhwchwYB9_gvpjmu1SnNYvrXCNhpHNv3zCO-aA@mail.gmail.com>
References: <20220510074301.480941-1-imagedong@tencent.com>
 <8983fedf-5095-59a4-b4b3-83f1864be055@ssi.bg> <CADxym3aREm=ZPucm=C6ZRnPbQJMvCxkcnKge2EAcy-Rs0CTtfg@mail.gmail.com>
 <bb1d68e0-de27-985f-19b-208fb546a0b1@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1+Fy9hqr0kRsZUGm3c2sW0uPgcK/zLLVX8crSmNBvLA=;
        b=NSXiVbCoEuViKntMJPVbDFsTBn8mhesbr5gxiAgVw2sWuZyeaxhitNtJEkmru1BBbR
         0hNot1HiIbCffSWB+F00EhkslcGFOsJcvR5AqQGYOj/nQsakGYBx4f1bDx8Ou67/BaFg
         +FZX2Kx/M6eOisLVbImgThzbjeV84KmjH/lnA+trRH+LUkXPPFqBi5UNq0ss/0oH+KlF
         4UCyUrFjqE3u0yB0cGq6g80BMkO67hbx4jwofMJFHCWiLq+qtLva1hNahAcEhAIWAfqv
         mSwf03wcqfRVZK534MHgQDOiJCBge9jn1oau4vua77eG3epMLcb3uGM13PpjruIRGF2D
         iS+g==
In-Reply-To: <bb1d68e0-de27-985f-19b-208fb546a0b1@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Menglong Dong <imagedong@tencent.com>

On Thu, May 12, 2022 at 6:33 PM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Thu, 12 May 2022, Menglong Dong wrote:
>
> > Yeah, WLC and MH are excellent schedulers. As for SH, my
> > fellows' feedback says that it doesn't work well. In fact, it's their
> > fault, they just forget to enable port hash and just use the
> > default ip hash. With my direction, this case is solved by sh.
> >
> > Now, I'm not sure if this feature is necessary. Maybe someone
> > needs it? Such as someone, who need RR/WRR and a random
> > start......
>
>         If there is some more clever way to add randomness.
> The problem is that random start should be applied after
> initial configuration only. But there is no clear point between
> where configuration is completed and when service starts.
> This is not bad for RR but is bad for WRR.
>

Yes, we need a more nice way to do this work. It's easy for RR,
but a little complex for WRR, after I figure out how WRR works.

>         One way would be the user tool to add dests in random
> order. IIRC, this should not affect setups with backup servers
> as long as they share the same set of real servers, i.e.
> order in svc->destinations does not matter for SYNC but
> the real servers should be present in all directors.
>
>         Another option would be __ip_vs_update_dest() to
> use list_add_rcu() or list_add_tail_rcu() per dest depending
> on some switch that enables random ordering for the svc.
> But it will affect only schedulers that do not order
> later the dests. So, it should help for RR, WRR (random
> order per same weight). In this case, scheduler's code
> is not affected.
>
>         For RR, the scheduler does not use weights and
> dests are usually not updated. But for WRR the weights
> can be changed and this affects order of selection without
> changing the order in svc->destinations.
>
>         OTOH, WRR is a scheduler that can support frequent
> update of dest weights. This is not true for MH which can
> easily change only between 0 and some fixed weight without
> changing its table. As result, ip_vs_wrr_dest_changed()
> can be called frequently even after the initial configuration,
> at the same time while packets are scheduled.
>

Using a user tool to add dests in random order is an option, which
I thought about before. But it needs users to make some extra
changes.

Thanks for your explanation. The options you mentioned are mature
and significant. I'll make them together and try to find the best way,
after I dig into the ipvs code deeper.

>         When you mentioned that ip_vs_wrr_gcd_weight() is
> slow, I see that ip_vs_wrr_dest_changed() can be improved
> to reduce the time while holding the lock. May be
> in separate patch we can call ip_vs_wrr_gcd_weight() and
> ip_vs_wrr_max_weight() before the spin_lock_bh() by using
> two new tmp vars.
>

Yeah, it seems that the range of the lock can be reduced. I
think I'm able to handle it.



> > Anyway, I have made a V3 according to your advice. I can
> > send it with any positive reply :/
>
>         You can use [RFC tag] for this, so that we can
> at least review it and further decide what can be done.
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
