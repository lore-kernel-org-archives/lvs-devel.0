From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next v4] netfilter: ipvs: Fix reuse connection if RS
 weight is 0
Date: Sat, 30 Oct 2021 16:51:24 +0300 (EEST)
Message-ID: <3fa86627-969-cf6-9de0-25721c9f3964@ssi.bg>
References: <20211030064049.9992-1-xingwu.yang@gmail.com> <e2699ba8-e733-2c71-584a-138746511f4@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <e2699ba8-e733-2c71-584a-138746511f4@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: yangxingwu <xingwu.yang@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, pablo@netfilter.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Chuanqi Liu <legend050709@qq.com>


	Hello,

On Sat, 30 Oct 2021, Julian Anastasov wrote:

> On Sat, 30 Oct 2021, yangxingwu wrote:
> 
> > We are changing expire_nodest_conn to work even for reused connections when
> > conn_reuse_mode=0 but without affecting the controlled and persistent
> > connections during the graceful termination period while server is with
> > weight=0.
> > 
> > Fixes: d752c3645717 ("ipvs: allow rescheduling of new connections when port
> > reuse is detected")
> > Co-developed-by: Chuanqi Liu <legend050709@qq.com>
> > Signed-off-by: Chuanqi Liu <legend050709@qq.com>
> > Signed-off-by: yangxingwu <xingwu.yang@gmail.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

NACK for v4.

	May be we should not include the !cp->control changes
in this patch, it is better to reschedule as it was done
before, the new connection will get the needed real server
depending on the rules in ip_vs_check_template().

	So, please send v5 with cp->control changes removed,
updated commit message and Fixes tag without line wrap.

> 	Simon, Pablo, may be you can change Fixes tag to be
> on one line before applying.
> 
> > ---
> >  Documentation/networking/ipvs-sysctl.rst |  3 +--
> >  net/netfilter/ipvs/ip_vs_core.c          | 12 ++++--------
> >  2 files changed, 5 insertions(+), 10 deletions(-)
> > 
> > diff --git a/Documentation/networking/ipvs-sysctl.rst b/Documentation/networking/ipvs-sysctl.rst
> > index 2afccc63856e..1cfbf1add2fc 100644
> > --- a/Documentation/networking/ipvs-sysctl.rst
> > +++ b/Documentation/networking/ipvs-sysctl.rst
> > @@ -37,8 +37,7 @@ conn_reuse_mode - INTEGER
> >  
> >  	0: disable any special handling on port reuse. The new
> >  	connection will be delivered to the same real server that was
> > -	servicing the previous connection. This will effectively
> > -	disable expire_nodest_conn.
> > +	servicing the previous connection.
> >  
> >  	bit 1: enable rescheduling of new connections when it is safe.
> >  	That is, whenever expire_nodest_conn and for TCP sockets, when
> > diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
> > index 128690c512df..ce6ceb55822b 100644
> > --- a/net/netfilter/ipvs/ip_vs_core.c
> > +++ b/net/netfilter/ipvs/ip_vs_core.c
> > @@ -1100,10 +1100,6 @@ static inline bool is_new_conn(const struct sk_buff *skb,
> >  static inline bool is_new_conn_expected(const struct ip_vs_conn *cp,
> >  					int conn_reuse_mode)
> >  {
> > -	/* Controlled (FTP DATA or persistence)? */
> > -	if (cp->control)
> > -		return false;
> > -
> >  	switch (cp->protocol) {
> >  	case IPPROTO_TCP:
> >  		return (cp->state == IP_VS_TCP_S_TIME_WAIT) ||
> > @@ -1964,7 +1960,6 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >  	struct ip_vs_proto_data *pd;
> >  	struct ip_vs_conn *cp;
> >  	int ret, pkts;
> > -	int conn_reuse_mode;
> >  	struct sock *sk;
> >  
> >  	/* Already marked as IPVS request or reply? */
> > @@ -2041,15 +2036,16 @@ ip_vs_in(struct netns_ipvs *ipvs, unsigned int hooknum, struct sk_buff *skb, int
> >  	cp = INDIRECT_CALL_1(pp->conn_in_get, ip_vs_conn_in_get_proto,
> >  			     ipvs, af, skb, &iph);
> >  
> > -	conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> > -	if (conn_reuse_mode && !iph.fragoffs && is_new_conn(skb, &iph) && cp) {
> > +	if (!iph.fragoffs && is_new_conn(skb, &iph) && cp && !cp->control) {
> >  		bool old_ct = false, resched = false;
> > +		int conn_reuse_mode = sysctl_conn_reuse_mode(ipvs);
> >  
> >  		if (unlikely(sysctl_expire_nodest_conn(ipvs)) && cp->dest &&
> >  		    unlikely(!atomic_read(&cp->dest->weight))) {
> >  			resched = true;
> >  			old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
> > -		} else if (is_new_conn_expected(cp, conn_reuse_mode)) {
> > +		} else if (conn_reuse_mode &&
> > +			   is_new_conn_expected(cp, conn_reuse_mode)) {
> >  			old_ct = ip_vs_conn_uses_old_conntrack(cp, skb);
> >  			if (!atomic_read(&cp->n_control)) {
> >  				resched = true;
> > -- 
> > 2.30.2

Regards

--
Julian Anastasov <ja@ssi.bg>
