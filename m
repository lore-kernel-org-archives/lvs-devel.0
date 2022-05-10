From: Menglong Dong <menglong8.dong@gmail.com>
Subject: Re: [PATCH net-next] net: ipvs: random start for RR scheduler
Date: Tue, 10 May 2022 11:21:17 +0800
Message-ID: <CADxym3bgR9xfHgoAwWeEQvLUnwrUxee3gK4SkRqcS+TmmfWUGw@mail.gmail.com>
References: <20220509122213.19508-1-imagedong@tencent.com> <cb8eaad0-83c5-a150-d830-e078682ba18b@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W6hg8xZDlvVbV0yxBFJp6M3i2By/uzGhIKuyQsM88v4=;
        b=P+wESGRbK7UrpgEo0WHOiYGsdzWzZ8+u3MZXUDBD4YdLv0BOKi/E+XbjkFcw6DoRaN
         LenQnO42u8tz5dMfezSlUYh7mWdgCucKAr1fPOYcuPBvBQp4xQiCsNPZyCL+LxgPhrrf
         veBicKCnUjsb4wSJjmvW+1gbMijZcgobY0wy5gqSBHsLiZJi6QFk1owyvBeCAcSL1S36
         TVJ3B318oVs8ampqE+l+C6rWHg8nWxfmg8BhUGb6gqo2W498Bo+vfxGsE9pOMhyvAc8X
         MwQJyuatuyH/Pe7rZDYhDlFYKFbSvx3LU4SUdCXn4Q7gK0ZFCplpHbfthTj3SECxSJFR
         snqg==
In-Reply-To: <cb8eaad0-83c5-a150-d830-e078682ba18b@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, Menglong Dong <imagedong@tencent.com>

On Tue, May 10, 2022 at 2:17 AM Julian Anastasov <ja@ssi.bg> wrote:
>
>
>         Hello,
>
> On Mon, 9 May 2022, menglong8.dong@gmail.com wrote:
>
> > From: Menglong Dong <imagedong@tencent.com>
> >
> > For now, the start of the RR scheduler is in the order of dest
> > service added, it will result in imbalance if the load balance
>
>         ...order of added destinations,...
>
> > is done in client side and long connect is used.
>
>         ..."long connections are used". Is this a case where
> small number of connections are used? And the two connections
> relatively overload the real servers?
>
> > For example, we have client1, client2, ..., client5 and real service
> > service1, service2, service3. All clients have the same ipvs config,
> > and each of them will create 2 long TCP connect to the virtual
> > service. Therefore, all the clients will connect to service1 and
> > service2, leaving service3 free.
>
>         You mean, there are many IPVS directors with same
> config and each director gets 2 connections? Third connection
> will get real server #3, right ? Also, are the clients local
> to the director?
>

Sorry to have missed your message here. Yeah, this is what I mean.
And in my case, the directors are local the to client, and each client
only have 2 connections. If the 3th connection happens, it will get #3
real server. And all directors connected to #1 and #2 real servers,
resulting in overload.

> > Fix this by randomize the start of dest service to RR scheduler when
>
>         ..."randomizing the starting destination when"
>
> > IP_VS_SVC_F_SCHED_RR_RANDOM is set.
> >
> > Signed-off-by: Menglong Dong <imagedong@tencent.com>
> > ---
> >  include/uapi/linux/ip_vs.h    |  2 ++
> >  net/netfilter/ipvs/ip_vs_rr.c | 25 ++++++++++++++++++++++++-
> >  2 files changed, 26 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> > index 4102ddcb4e14..7f74bafd3211 100644
> > --- a/include/uapi/linux/ip_vs.h
> > +++ b/include/uapi/linux/ip_vs.h
> > @@ -28,6 +28,8 @@
> >  #define IP_VS_SVC_F_SCHED_SH_FALLBACK        IP_VS_SVC_F_SCHED1 /* SH fallback */
> >  #define IP_VS_SVC_F_SCHED_SH_PORT    IP_VS_SVC_F_SCHED2 /* SH use port */
> >
> > +#define IP_VS_SVC_F_SCHED_RR_RANDOM  IP_VS_SVC_F_SCHED1 /* random start */
> > +
> >  /*
> >   *      Destination Server Flags
> >   */
> > diff --git a/net/netfilter/ipvs/ip_vs_rr.c b/net/netfilter/ipvs/ip_vs_rr.c
> > index 38495c6f6c7c..e309d97bdd08 100644
> > --- a/net/netfilter/ipvs/ip_vs_rr.c
> > +++ b/net/netfilter/ipvs/ip_vs_rr.c
> > @@ -22,13 +22,36 @@
> >
> >  #include <net/ip_vs.h>
> >
> > +static void ip_vs_rr_random_start(struct ip_vs_service *svc)
> > +{
> > +     struct list_head *cur;
> > +     u32 start;
> > +
> > +     if (!(svc->flags | IP_VS_SVC_F_SCHED_RR_RANDOM) ||
>
>         | -> &
>
> > +         svc->num_dests <= 1)
> > +             return;
> > +
> > +     spin_lock_bh(&svc->sched_lock);
> > +     start = get_random_u32() % svc->num_dests;
>
>         May be prandom is more appropriate for non-crypto purposes.
> Also, not sure if it is a good idea to limit the number of steps,
> eg. to 128...
>
>         start = prandom_u32_max(min(svc->num_dests, 128U));
>
>         or just use
>
>         start = prandom_u32_max(svc->num_dests);
>
>         Also, this line can be before the spin_lock_bh.
>
> > +     cur = &svc->destinations;
>
>         cur = svc->sched_data;
>
>         ... and to start from current svc->sched_data because
> we are called for every added dest. Better to jump 0..127 steps
> ahead, to avoid delay with long lists?
>
> > +     while (start--)
> > +             cur = cur->next;
> > +     svc->sched_data = cur;
> > +     spin_unlock_bh(&svc->sched_lock);
> > +}
> >
> >  static int ip_vs_rr_init_svc(struct ip_vs_service *svc)
> >  {
> >       svc->sched_data = &svc->destinations;
> > +     ip_vs_rr_random_start(svc);
> >       return 0;
> >  }
> >
> > +static int ip_vs_rr_add_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
> > +{
> > +     ip_vs_rr_random_start(svc);
> > +     return 0;
> > +}
> >
> >  static int ip_vs_rr_del_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest)
> >  {
> > @@ -104,7 +127,7 @@ static struct ip_vs_scheduler ip_vs_rr_scheduler = {
> >       .module =               THIS_MODULE,
> >       .n_list =               LIST_HEAD_INIT(ip_vs_rr_scheduler.n_list),
> >       .init_service =         ip_vs_rr_init_svc,
> > -     .add_dest =             NULL,
> > +     .add_dest =             ip_vs_rr_add_dest,
> >       .del_dest =             ip_vs_rr_del_dest,
> >       .schedule =             ip_vs_rr_schedule,
> >  };
> > --
> > 2.36.0
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
