From: Andrew Kim <kim.andrewsy@gmail.com>
Subject: Re: [PATCH] netfilter/ipvs: queue delayed work to expire no
 destination connections if expire_nodest_conn=1
Date: Mon, 8 Jun 2020 13:29:00 -0400
Message-ID: <CABc050EAYrj+ymDbSc0CfSCkmpcZRM2O_RumUhOYxpzWDYD7XA@mail.gmail.com>
References: <alpine.LFD.2.22.394.2005281954380.4045@ja.home.ssi.bg> <20200608172204.19825-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:cc;
        bh=Mlp4HqUELPH6tw+uXAq0JHWV4MU63AE1pRSBNQXqBfo=;
        b=Ytz87AfN24xF6BUmUXHB35tA01CsFSSMdB2YEqEte9ftp+rQRh4m59px0RrzmO69ho
         GkCkflVchgclb1KknN4iK81ZPi4ZP1gHZ6q3dshzoRqdTnG8hpdMZCIbPJfc5IN7i07I
         SqohqY8NiL0XuyGh2ZsImIU8oJqpcjtE1ToNFB1Ykx7gbKdbIw0yXAaoUaS+qXb8Yvkb
         CfsOTVkuicmjDevd9p6nNdrl1MYGBPLdmWW0XVQd0hKcv2c3p9Vf2Lr+48/0/Spc5s82
         czWv73FudIWcWvJdFNJMKSzfpCr3Av7Mu8ueB+LLsiFpT1WuW/mnBOeE+4PXouxR+tSx
         53DA==
In-Reply-To: <20200608172204.19825-1-kim.andrewsy@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>

Missed a few changes in the patch I just sent, will send an updated one shortly.


On Mon, Jun 8, 2020 at 1:22 PM Andrew Sy Kim <kim.andrewsy@gmail.com> wrote:
>
> When expire_nodest_conn=1 and a destination is deleted, IPVS does not
> expire the existing connections until the next matching incoming packet.
> If there are many connection entries from a single client to a single
> destination, many packets may get dropped before all the connections are
> expired (more likely with lots of UDP traffic). An optimization can be
> made where upon deletion of a destination, IPVS queues up delayed work
> to immediately expire any connections with a deleted destination. This
> ensures any reused source ports from a client (within the IPVS timeouts)
> are scheduled to new real servers instead of silently dropped.
>
> Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
> ---
>  include/net/ip_vs.h             | 28 ++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_conn.c | 44 ++++++++++++++++++++++++++++++++
>  net/netfilter/ipvs/ip_vs_core.c | 45 +++++++++++++--------------------
>  net/netfilter/ipvs/ip_vs_ctl.c  | 22 ++++++++++++++++
>  4 files changed, 112 insertions(+), 27 deletions(-)
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 83be2d93b407..3eb03d9440ce 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -885,6 +885,8 @@ struct netns_ipvs {
>         atomic_t                conn_out_counter;
>
>  #ifdef CONFIG_SYSCTL
> +       /* delayed work for expiring no dest connections */
> +       struct delayed_work     expire_nodest_conn_work;
>         /* 1/rate drop and drop-entry variables */
>         struct delayed_work     defense_work;   /* Work handler */
>         int                     drop_rate;
> @@ -1049,6 +1051,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
>         return ipvs->sysctl_conn_reuse_mode;
>  }
>
> +static inline int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
> +{
> +       return ipvs->sysctl_expire_nodest_conn;
> +}
> +
>  static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
>  {
>         return ipvs->sysctl_schedule_icmp;
> @@ -1136,6 +1143,11 @@ static inline int sysctl_conn_reuse_mode(struct netns_ipvs *ipvs)
>         return 1;
>  }
>
> +static inline int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
> +{
> +       return 0;
> +}
> +
>  static inline int sysctl_schedule_icmp(struct netns_ipvs *ipvs)
>  {
>         return 0;
> @@ -1505,6 +1517,22 @@ static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
>  static inline int ip_vs_todrop(struct netns_ipvs *ipvs) { return 0; }
>  #endif
>
> +#ifdef CONFIG_SYSCTL
> +/* Enqueue delayed work for expiring no dest connections
> + * Only run when sysctl_expire_nodest=1
> + */
> +static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs *ipvs)
> +{
> +       if (sysctl_expire_nodest_conn(ipvs))
> +               queue_delayed_work(system_long_wq,
> +                                  &ipvs->expire_nodest_conn_work, 1);
> +}
> +
> +void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs);
> +#else
> +static inline void ip_vs_enqueue_expire_nodest_conns(struct netns_ipvs) {}
> +#endif
> +
>  #define IP_VS_DFWD_METHOD(dest) (atomic_read(&(dest)->conn_flags) & \
>                                  IP_VS_CONN_F_FWD_MASK)
>
> diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> index 02f2f636798d..88eb7c2433aa 100644
> --- a/net/netfilter/ipvs/ip_vs_conn.c
> +++ b/net/netfilter/ipvs/ip_vs_conn.c
> @@ -28,6 +28,7 @@
>  #include <linux/module.h>
>  #include <linux/vmalloc.h>
>  #include <linux/proc_fs.h>             /* for proc_net_* */
> +#include <linux/workqueue.h>
>  #include <linux/slab.h>
>  #include <linux/seq_file.h>
>  #include <linux/jhash.h>
> @@ -1366,6 +1367,49 @@ static void ip_vs_conn_flush(struct netns_ipvs *ipvs)
>                 goto flush_again;
>         }
>  }
> +
> +#ifdef CONFIG_SYSCTL
> +void ip_vs_expire_nodest_conn_flush(struct netns_ipvs *ipvs)
> +{
> +       int idx;
> +       struct ip_vs_conn *cp, *cp_c;
> +       struct ip_vs_dest *dest;
> +
> +       rcu_read_lock();
> +       for (idx = 0; idx < ip_vs_conn_tab_size; idx++) {
> +               hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[idx], c_list) {
> +                       if (cp->ipvs != ipvs)
> +                               continue;
> +
> +                       dest = cp->dest;
> +                       if (!dest || (dest->flags & IP_VS_DEST_F_AVAILABLE))
> +                               continue;
> +
> +                       /* As timers are expired in LIFO order, restart
> +                        * the timer of controlling connection first, so
> +                        * that it is expired after us.
> +                        */
> +                       cp_c = cp->control;
> +                       /* cp->control is valid only with reference to cp */
> +                       if (cp_c && __ip_vs_conn_get(cp)) {
> +                               IP_VS_DBG(4, "del controlling connection\n");
> +                               ip_vs_conn_expire_now(cp_c);
> +                               __ip_vs_conn_put(cp);
> +                       }
> +
> +                       IP_VS_DBG(4, "del connection\n");
> +                       ip_vs_conn_expire_now(cp);
> +               }
> +               cond_resched_rcu();
> +
> +               /* netns clean up started, aborted delayed work */
> +               if (!ipvs->enable)
> +                       return;
> +       }
> +       rcu_read_unlock();
> +}
> +#endif
> +
>  /*
>   * per netns init and exit
>   */
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> index aa6a603a2425..2508a9caeae8 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -694,16 +694,10 @@ static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs)
>         return ipvs->sysctl_nat_icmp_send;
>  }
>
> -static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs)
> -{
> -       return ipvs->sysctl_expire_nodest_conn;
> -}
> -
>  #else
>
>  static int sysctl_snat_reroute(struct netns_ipvs *ipvs) { return 0; }
>  static int sysctl_nat_icmp_send(struct netns_ipvs *ipvs) { return 0; }
> -static int sysctl_expire_nodest_conn(struct netns_ipvs *ipvs) { return 0; }
>
>  #endif
>
> @@ -2095,36 +2089,33 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
>                 }
>         }
>
> -       if (unlikely(!cp)) {
> -               int v;
> -
> -               if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
> -                       return v;
> -       }
> -
> -       IP_VS_DBG_PKT(11, af, pp, skb, iph.off, "Incoming packet");
> -
>         /* Check the server status */
> -       if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
> +       if (cp && cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
>                 /* the destination server is not available */
>
> -               __u32 flags = cp->flags;
> -
> -               /* when timer already started, silently drop the packet.*/
> -               if (timer_pending(&cp->timer))
> -                       __ip_vs_conn_put(cp);
> -               else
> -                       ip_vs_conn_put(cp);
> +               if (sysctl_expire_nodest_conn(ipvs)) {
> +                       bool uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
>
> -               if (sysctl_expire_nodest_conn(ipvs) &&
> -                   !(flags & IP_VS_CONN_F_ONE_PACKET)) {
> -                       /* try to expire the connection immediately */
>                         ip_vs_conn_expire_now(cp);
> +                       __ip_vs_conn_put(cp);
> +                       if (uses_ct)
> +                               return NF_DROP;
> +                       cp = NULL;
> +               } else {
> +                       __ip_vs_conn_put(cp);
> +                       return NF_DROP;
>                 }
> +       }
>
> -               return NF_DROP;
> +       if (unlikely(!cp)) {
> +               int v;
> +
> +               if (!ip_vs_try_to_schedule(ipvs, af, skb, pd, &v, &cp, &iph))
> +                       return v;
>         }
>
> +       IP_VS_DBG_PKT(11, af, pp, skb, iph.off, "Incoming packet");
> +
>         ip_vs_in_stats(cp, skb);
>         ip_vs_set_state(cp, IP_VS_DIR_INPUT, skb, pd);
>         if (cp->packet_xmit)
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 8d14a1acbc37..24736efac85c 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -210,6 +210,17 @@ static void update_defense_level(struct netns_ipvs *ipvs)
>         local_bh_enable();
>  }
>
> +/*     Handler for delayed work for expiring no
> + *     destination connections
> + */
> +static void expire_nodest_conn_handler(struct work_struct *work)
> +{
> +       struct netns_ipvs *ipvs;
> +
> +       ipvs = container_of(work, struct netns_ipvs,
> +                           expire_nodest_conn_work.work);
> +       ip_vs_expire_nodest_conn_flush(ipvs);
> +}
>
>  /*
>   *     Timer for checking the defense
> @@ -1163,6 +1174,12 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
>         list_add(&dest->t_list, &ipvs->dest_trash);
>         dest->idle_start = 0;
>         spin_unlock_bh(&ipvs->dest_trash_lock);
> +
> +       /*      Queue up delayed work to expire all no estination connections.
> +        *      No-op when CONFIG_SYSCTL is disabled.
> +        */
> +       if (!cleanup)
> +               ip_vs_enqueue_expire_nodest_conns(ipvs);
>  }
>
>
> @@ -4065,6 +4082,10 @@ static int __net_init ip_vs_control_net_init_sysctl(struct netns_ipvs *ipvs)
>         INIT_DELAYED_WORK(&ipvs->defense_work, defense_work_handler);
>         schedule_delayed_work(&ipvs->defense_work, DEFENSE_TIMER_PERIOD);
>
> +       /* Init delayed work for expiring no dest conn */
> +       INIT_DELAYED_WORK(&ipvs->expire_nodest_conn_work,
> +                         expire_nodest_conn_handler);
> +
>         return 0;
>  }
>
> @@ -4072,6 +4093,7 @@ static void __net_exit ip_vs_control_net_cleanup_sysctl(struct netns_ipvs *ipvs)
>  {
>         struct net *net = ipvs->net;
>
> +       cancel_delayed_work_sync(&ipvs->expire_nodest_conn_work);
>         cancel_delayed_work_sync(&ipvs->defense_work);
>         cancel_work_sync(&ipvs->defense_work.work);
>         unregister_net_sysctl_table(ipvs->sysctl_hdr);
> --
> 2.20.1
>
