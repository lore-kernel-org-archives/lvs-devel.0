From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH v2] ipvs: drop first packet to dead server
Date: Fri, 9 Oct 2015 18:17:34 +0200
Message-ID: <20151009161734.GA5034@midget.suse.cz>
References: <20150925093737.GA5047@midget.suse.cz>
 <20150925094820.GB5047@midget.suse.cz>
 <alpine.LFD.2.11.1509272004230.1618@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1509272004230.1618@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hi,

On Sun, Sep 27, 2015 at 08:25:18PM +0300, Julian Anastasov wrote:
> On Fri, 25 Sep 2015, Jiri Bohac wrote:
> 
> >  		if (!atomic_read(&cp->n_control))
> >  			ip_vs_conn_expire_now(cp);
> >  		__ip_vs_conn_put(cp);
> > -		cp = NULL;
> > +		return NF_DROP;
> 
> 	So, at this point we do not know whether we have
> one or many real servers, with same or different forwarding
> method. For example, if we know that old real server is DR
> and the new real server is again DR we can reuse the conntrack.
> 
> 	Without such info we have to drop the connection
> _only_ when conntrack is used.

right, good point!

> +static inline bool ip_vs_conn_uses_conntrack(struct ip_vs_conn *cp,
> +					struct sk_buff *skb)
> +{
> +#ifdef CONFIG_IP_VS_NFCT
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct;
> +
> +	if (!(cp->flags & IP_VS_CONN_F_NFCT))
> +		return false;
> +	ct = nf_ct_get(skb, &ctinfo);
> +	if (ct && !nf_ct_is_untracked(ct))
> +		return true;
> +#endif
> +	return false;
> +}
> +

I tested this part; we found the problem on an old (3.12) kernel,
we're missing the parts dealing with rescheduling on port reuse -
only dealing with the "weight == 0" case.

> +	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
> +		bool uses_ct = false, resched = false;
> +
> +		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> +		    unlikely(!atomic_read(&cp->dest->weight))) {
> +			resched = true;
> +			uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
> +		} else if (is_new_conn_expected(cp, conn_reuse_mode)) {
> +			uses_ct = ip_vs_conn_uses_conntrack(cp, skb);
> +			if (!atomic_read(&cp->n_control)) {
> +				resched = true;
> +			} else {
> +				/* Do not reschedule controlling connection
> +				 * that uses conntrack while it is still
> +				 * referenced by controlled connection(s).
> +				 */
> +				resched = !uses_ct;
> +			}
> +		}
> +
> +		if (resched) {
> +			if (!atomic_read(&cp->n_control))
> +				ip_vs_conn_expire_now(cp);
> +			__ip_vs_conn_put(cp);
> +			if (uses_ct)
> +				return NF_DROP;
> +			cp = NULL;
> +		}

Looks good, but I can't easily test this.

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
