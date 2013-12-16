From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH] ipvs: avoid oops in nf_ct_seqadj_set when called from
 ip_vs_ftp helper
Date: Mon, 16 Dec 2013 15:57:24 +0100
Message-ID: <20131216155724.2a174830@redhat.com>
References: <20131213214023.14478.74738.stgit@dragon>
	<alpine.LFD.2.11.1312151709260.6463@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1312151709260.6463@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>

On Sun, 15 Dec 2013 18:10:42 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> On Fri, 13 Dec 2013, Jesper Dangaard Brouer wrote:
> 
> > The IPVS FTP helper ip_vs_ftp can trigger an OOPS in nf_ct_seqadj_set,
> > after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
> > number adjustments usuable without NAT).
> > 
> > We can avoid the oops in nf_ct_seqadj_set() by in ip_vs_ftp_out()
> > instead of calling nf_nat_mangle_tcp_packet() we simply call
> > __nf_nat_mangle_tcp_packet() with a "false" last parameter, which
> > indicate not invoking the seqadj code.
> > 
> > After this fix, I've tested that FTP over IPVS, with module ip_vs_ftp
> > loaded, works for both passive and active FTP.
> > 
> > Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > 
> > ---
> > I'm uncertain if this is the correct fix.  Perhaps the ip_vs_ftp
> > helper need to allocate/init the seqadj extension instead?
> 
> 	I hope I'll save you some time... What do you
> think about such change:

Thanks a lot!


> [PATCH net] ipvs: use the new seqadj interface from ip_vs_ftp
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index 77c1732..9c2074d 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -34,6 +34,7 @@
>  #include <linux/netfilter.h>
>  #include <net/netfilter/nf_conntrack.h>
>  #include <net/netfilter/nf_conntrack_expect.h>
> +#include <net/netfilter/nf_conntrack_seqadj.h>
>  #include <net/netfilter/nf_nat.h>
>  #include <net/netfilter/nf_nat_helper.h>
>  #include <linux/gfp.h>
> @@ -260,7 +261,8 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
>  		buf_len = strlen(buf);
>  
>  		ct = nf_ct_get(skb, &ctinfo);
> -		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct)) {
> +		if (ct && !nf_ct_is_untracked(ct) && nfct_nat(ct) &&
> +		    nfct_seqadj(ct)) {

If we add the other section, then this check should not be necessary.


>  			/* If mangling fails this function will return 0
>  			 * which will cause the packet to be dropped.
>  			 * Mangling can only fail under memory pressure,
> diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
> index c8beafd..5a355a4 100644
> --- a/net/netfilter/ipvs/ip_vs_nfct.c
> +++ b/net/netfilter/ipvs/ip_vs_nfct.c
> @@ -63,6 +63,7 @@
>  #include <net/ip_vs.h>
>  #include <net/netfilter/nf_conntrack_core.h>
>  #include <net/netfilter/nf_conntrack_expect.h>
> +#include <net/netfilter/nf_conntrack_seqadj.h>
>  #include <net/netfilter/nf_conntrack_helper.h>
>  #include <net/netfilter/nf_conntrack_zones.h>
>  
> @@ -97,6 +98,11 @@ ip_vs_update_conntrack(struct sk_buff *skb, struct ip_vs_conn *cp, int outin)
>  	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
>  		return;
>  
> +	/* Applications may adjust TCP seqs */
> +	if (cp->app && nf_ct_protonum(ct) == IPPROTO_TCP &&
> +	    !nfct_seqadj(ct) && !nfct_seqadj_ext_add(ct))
> +		return;
> +

It will work.

I'm just thinking if we will allocate a seqadj ext, in too many
situations, were its not really needed... double checking, I see that
"cp->app" will limit us a lot, as it seems that FTP is the only one
using register_ip_vs_app(),

And above this, we do check:
	if (IP_VS_FWD_METHOD(cp) != IP_VS_CONN_F_MASQ)
		return;
So, we only do this for IPVS masq case, good.
I think we are good.

Now, I'm just wondering if SIP will work... (but I don't have a lab to
test this).

I'll submit a new patch/fix soon.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
