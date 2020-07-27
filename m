From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH 12/26] netfilter: switch nf_setsockopt to sockptr_t
Date: Mon, 27 Jul 2020 18:16:32 +0200
Message-ID: <CAHmME9ric=chLJayn7Erve7WBa+qCKn-+Gjri=zqydoY6623aA@mail.gmail.com>
References: <20200723060908.50081-1-hch@lst.de> <20200723060908.50081-13-hch@lst.de>
 <20200727150310.GA1632472@zx2c4.com> <20200727150601.GA3447@lst.de>
Mime-Version: 1.0
Return-path: <linux-hams-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed; d=zx2c4.com; h=mime-version
        :references:in-reply-to:from:date:message-id:subject:to:cc
        :content-type; s=mail; bh=yZ9s7iESSXllw2jFppVGJgSQSDc=; b=T8Sn3a
        8QgZwT7OBLiEk39YllHL8AHxegeWoSsgukQldc9TiwR4eHH+81jI/awj0HrXtBrg
        Y5UPc9Cc5BZJ8GrAprgs5NcK5vubz31d4jsM4x0gMeFEgDrVjUrRX41udJBHMNld
        d/Bx9892A78N/q/07Gl0nQui+mlF/IAoZIyvrYwHlA6vlD8ytQ/RkS4Lp/JjiVOo
        r0KIpueIg+d9HaYHBQI6Nj9saKViVpoxMt0rA2Xtk8fEZ2Ajc735rEzlQ3Gn8yTu
        4eFoXmxypskbeYUzua5Dmfrj+eDOvtFDSR0ScqE+ZC5nUsdiFsBW9DfS1UvXfi+f
        sWCgYlvemIgM0Wvg==
In-Reply-To: <20200727150601.GA3447@lst.de>
Sender: linux-hams-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Netdev <netdev@vger.kernel.org>, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org

On Mon, Jul 27, 2020 at 5:06 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Jul 27, 2020 at 05:03:10PM +0200, Jason A. Donenfeld wrote:
> > Hi Christoph,
> >
> > On Thu, Jul 23, 2020 at 08:08:54AM +0200, Christoph Hellwig wrote:
> > > diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> > > index da933f99b5d517..42befbf12846c0 100644
> > > --- a/net/ipv4/ip_sockglue.c
> > > +++ b/net/ipv4/ip_sockglue.c
> > > @@ -1422,7 +1422,8 @@ int ip_setsockopt(struct sock *sk, int level,
> > >                     optname != IP_IPSEC_POLICY &&
> > >                     optname != IP_XFRM_POLICY &&
> > >                     !ip_mroute_opt(optname))
> > > -           err = nf_setsockopt(sk, PF_INET, optname, optval, optlen);
> > > +           err = nf_setsockopt(sk, PF_INET, optname, USER_SOCKPTR(optval),
> > > +                               optlen);
> > >  #endif
> > >     return err;
> > >  }
> > > diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
> > > index 4697d09c98dc3e..f2a9680303d8c0 100644
> > > --- a/net/ipv4/netfilter/ip_tables.c
> > > +++ b/net/ipv4/netfilter/ip_tables.c
> > > @@ -1102,7 +1102,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
> > >  }
> > >
> > >  static int
> > > -do_replace(struct net *net, const void __user *user, unsigned int len)
> > > +do_replace(struct net *net, sockptr_t arg, unsigned int len)
> > >  {
> > >     int ret;
> > >     struct ipt_replace tmp;
> > > @@ -1110,7 +1110,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
> > >     void *loc_cpu_entry;
> > >     struct ipt_entry *iter;
> > >
> > > -   if (copy_from_user(&tmp, user, sizeof(tmp)) != 0)
> > > +   if (copy_from_sockptr(&tmp, arg, sizeof(tmp)) != 0)
> > >             return -EFAULT;
> > >
> > >     /* overflow check */
> > > @@ -1126,8 +1126,8 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
> > >             return -ENOMEM;
> > >
> > >     loc_cpu_entry = newinfo->entries;
> > > -   if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
> > > -                      tmp.size) != 0) {
> > > +   sockptr_advance(arg, sizeof(tmp));
> > > +   if (copy_from_sockptr(loc_cpu_entry, arg, tmp.size) != 0) {
> > >             ret = -EFAULT;
> > >             goto free_newinfo;
> > >     }
> >
> > Something along this path seems to have broken with this patch. An
> > invocation of `iptables -A INPUT -m length --length 1360 -j DROP` now
> > fails, with
> >
> > nf_setsockopt->do_replace->translate_table->check_entry_size_and_hooks:
> >   (unsigned char *)e + e->next_offset > limit  ==>  TRUE
> >
> > resulting in the whole call chain returning -EINVAL. It bisects back to
> > this commit. This is on net-next.
>
> This is another use o sockptr_advance that Ido already found a problem
> in.  I'm looking into this at the moment..

I haven't seen Ido's patch, but it seems clear the issue is that you
want to call `sockptr_advance(&arg, sizeof(tmp))`, and adjust
sockptr_advance to take a pointer.

Slight concern about the whole concept:

Things are defined as

typedef union {
        void            *kernel;
        void __user     *user;
} sockptr_t;
static inline bool sockptr_is_kernel(sockptr_t sockptr)
{
        return (unsigned long)sockptr.kernel >= TASK_SIZE;
}

So what happens if we have some code like:

sockptr_t sp;
init_user_sockptr(&sp, user_controlled_struct.extra_user_ptr);
sockptr_advance(&sp, user_controlled_struct.some_big_offset);
copy_to_sockptr(&sp, user_controlled_struct.a_few_bytes,
sizeof(user_controlled_struct.a_few_bytes));

With the user controlling some_big_offset, he can convert the user
sockptr into a kernel sockptr, causing the subsequent copy_to_sockptr
to be a vanilla memcpy, after which a security disaster ensues.

Maybe sockptr_advance should have some safety checks and sometimes
return -EFAULT? Or you should always use the implementation where
being a kernel address is an explicit bit of sockptr_t, rather than
being implicit?
