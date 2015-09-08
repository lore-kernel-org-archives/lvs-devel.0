From: Simon Horman <horms@verge.net.au>
Subject: Re: [ipvs-next:master 14/14] include/net/ip_vs.h:1080:2: warning:
 'ipvs' may be used uninitialized in this function
Date: Tue, 8 Sep 2015 09:14:36 +0900
Message-ID: <20150908001436.GB5401@verge.net.au>
References: <201509011028.xcctBo3Y%fengguang.wu@intel.com>
 <20150907061920.GA15897@verge.net.au>
 <alpine.LFD.2.11.1509071112210.1539@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1509071112210.1539@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: kbuild test robot <fengguang.wu@intel.com>, Alex Gartrell <agartrell@fb.com>, kbuild-all@01.org, lvs-devel@vger.kernel.org

On Mon, Sep 07, 2015 at 11:21:19AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 7 Sep 2015, Simon Horman wrote:
> 
> > [CC Julian, lvs-dev]
> > 
> > Hi Alex, Hi All,
> > 
> > On Tue, Sep 01, 2015 at 10:03:31AM +0800, kbuild test robot wrote:
> > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> > > head:   5e26b1b3abce05c177feb589260031519a1bc7b1
> > > commit: 5e26b1b3abce05c177feb589260031519a1bc7b1 [14/14] ipvs: support scheduling inverse and icmp SCTP packets
> > > config: x86_64-randconfig-x001-201535 (attached as .config)
> > > reproduce:
> > >   git checkout 5e26b1b3abce05c177feb589260031519a1bc7b1
> > >   # save the attached .config to linux build tree
> > >   make ARCH=x86_64 
> > > 
> > > Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> > > http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> > > 
> > > All warnings (new ones prefixed by >>):
> > > 
> > >    In file included from net/netfilter/ipvs/ip_vs_proto_sctp.c:9:0:
> > >    net/netfilter/ipvs/ip_vs_proto_sctp.c: In function 'sctp_conn_schedule':
> > > >> include/net/ip_vs.h:1080:2: warning: 'ipvs' may be used uninitialized in this function [-Wmaybe-uninitialized]
> > >      return ipvs->sysctl_sloppy_sctp;
> > >      ^
> > >    net/netfilter/ipvs/ip_vs_proto_sctp.c:18:21: note: 'ipvs' was declared here
> > >      struct netns_ipvs *ipvs;
> > 
> > I wonder if squashing the following into the commit noted above is
> > a good way to resolve this problem.
> > 
> > It looks to me that 'ipvs' may indeed be initialised.
> > But that may be resolved by simply initialising it before rather
> > than after the call to sctp_conn_schedule() in question.
> 
> 	My compiler is silent about this problem :(
> It needs to be fixed...
> 
> > My main concern is that rcu_read_lock() may also need to move.
> 
> 	Not needed.

Thanks for confirming that.

I have squashed my change into Alex's patch and pushed the result.
For reference it is as follows:

From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH] ipvs: support scheduling inverse and icmp SCTP packets

In the event of an icmp packet, take only the ports instead of trying to
grab the full header.

In the event of an inverse packet, use the source address and port.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
[horms: initialise 'ipvs' before it is used]
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_sctp.c | 46 +++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 21 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index cd2984f3dad7..e000e6e76d71 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -13,37 +13,41 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 		   int *verdict, struct ip_vs_conn **cpp,
 		   struct ip_vs_iphdr *iph)
 {
-	struct net *net;
+	struct net *net = skb_net(skb);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service *svc;
-	struct netns_ipvs *ipvs;
 	sctp_chunkhdr_t _schunkh, *sch;
 	sctp_sctphdr_t *sh, _sctph;
-
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
-	}
-
-	sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
-	if (sh == NULL) {
-		*verdict = NF_DROP;
-		return 0;
+	__be16 _ports[2], *ports = NULL;
+
+	if (likely(!ip_vs_iph_icmp(iph))) {
+		sh = skb_header_pointer(skb, iph->len, sizeof(_sctph), &_sctph);
+		if (sh) {
+			sch = skb_header_pointer(
+				skb, iph->len + sizeof(sctp_sctphdr_t),
+				sizeof(_schunkh), &_schunkh);
+			if (sch && (sch->type == SCTP_CID_INIT ||
+				    sysctl_sloppy_sctp(ipvs)))
+				ports = &sh->source;
+		}
+	} else {
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	sch = skb_header_pointer(skb, iph->len + sizeof(sctp_sctphdr_t),
-				 sizeof(_schunkh), &_schunkh);
-	if (sch == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
 
-	net = skb_net(skb);
-	ipvs = net_ipvs(net);
 	rcu_read_lock();
-	if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
-	    (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				      &iph->daddr, sh->dest))) {
+	if (likely(!ip_vs_iph_inverse(iph)))
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+	if (svc) {
 		int ignored;
 
 		if (ip_vs_todrop(ipvs)) {
-- 
2.1.4

