From: Matteo Croce <mcroce@redhat.com>
Subject: Re: [PATCH] ipvs: don't show negative times in ip_vs_conn
Date: Mon, 30 Jul 2018 17:49:14 +0000
Message-ID: <CAGnkfhzxz715p23PH+QgK2zduhv95O85wa92ktBRtw5xy1sZ8w@mail.gmail.com>
References: <20180720151957.24791-1-mcroce@redhat.com> <ff823fec-0c37-80f9-9bcf-515357c5209a@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <ff823fec-0c37-80f9-9bcf-515357c5209a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eric.dumazet@gmail.com
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org

On Fri, Jul 20, 2018 at 4:19 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
>
> On 07/20/2018 08:19 AM, Matteo Croce wrote:
> > Since commit 500462a9de65 ("timers: Switch to a non-cascading wheel"),
> > timers duration can last even 12.5% more than the scheduled interval.
> >
> > Signed-off-by: Matteo Croce <mcroce@redhat.com>
> > ---
> >  net/netfilter/ipvs/ip_vs_conn.c | 22 ++++++++++++++--------
> >  1 file changed, 14 insertions(+), 8 deletions(-)
> >
> > diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
> > index 99e0aa350dc5..c78c48a6d53f 100644
> > --- a/net/netfilter/ipvs/ip_vs_conn.c
> > +++ b/net/netfilter/ipvs/ip_vs_conn.c
> > @@ -1066,6 +1066,12 @@ static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
> >       rcu_read_unlock();
> >  }
> >
> > +static unsigned int time_left(unsigned long time)
> > +{
> > +     return time_is_after_jiffies(time) ?
> > +             jiffies_to_msecs(time - jiffies) / 1000 : 0;
> > +}
>
>
> I would suggest adding jiffies_delta_to_msecs(), because we will need elsewhere,
> like in inet_sk_diag_fill()
>
>
> diff --git a/include/linux/jiffies.h b/include/linux/jiffies.h
> index a27cf66523279c1a5d4aaa0d0087f1e9d48d170f..fa928242567db30769839ac8738be5dc58e372ab 100644
> --- a/include/linux/jiffies.h
> +++ b/include/linux/jiffies.h
> @@ -447,6 +447,11 @@ static inline clock_t jiffies_delta_to_clock_t(long delta)
>         return jiffies_to_clock_t(max(0L, delta));
>  }
>
> +static inline unsigned int jiffies_delta_to_msecs(long delta)
> +{
> +       return jiffies_to_msecs(max(0L, delta));
> +}
> +
>  extern unsigned long clock_t_to_jiffies(unsigned long x);
>  extern u64 jiffies_64_to_clock_t(u64 x);
>  extern u64 nsec_to_clock_t(u64 x);
>

Hi Eric,
What about a function which returns directly the delta from a
timestamp, and 0 if elapsed?
So we can rely on time_is_after_jiffies() for overflows, it should be
less error prone.

static unsigned int jiffies_delta_to_msecs(unsigned long time)
{
     return time_is_after_jiffies(time) ?
             jiffies_to_msecs(time - jiffies) / 1000 : 0;
}


