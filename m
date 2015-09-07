From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ipvs-next:master 14/14] include/net/ip_vs.h:1080:2: warning:
 'ipvs' may be used uninitialized in this function
Date: Mon, 7 Sep 2015 11:21:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509071112210.1539@ja.home.ssi.bg>
References: <201509011028.xcctBo3Y%fengguang.wu@intel.com> <20150907061920.GA15897@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20150907061920.GA15897@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: kbuild test robot <fengguang.wu@intel.com>, Alex Gartrell <agartrell@fb.com>, kbuild-all@01.org, lvs-devel@vger.kernel.org


	Hello,

On Mon, 7 Sep 2015, Simon Horman wrote:

> [CC Julian, lvs-dev]
> 
> Hi Alex, Hi All,
> 
> On Tue, Sep 01, 2015 at 10:03:31AM +0800, kbuild test robot wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> > head:   5e26b1b3abce05c177feb589260031519a1bc7b1
> > commit: 5e26b1b3abce05c177feb589260031519a1bc7b1 [14/14] ipvs: support scheduling inverse and icmp SCTP packets
> > config: x86_64-randconfig-x001-201535 (attached as .config)
> > reproduce:
> >   git checkout 5e26b1b3abce05c177feb589260031519a1bc7b1
> >   # save the attached .config to linux build tree
> >   make ARCH=x86_64 
> > 
> > Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> > http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    In file included from net/netfilter/ipvs/ip_vs_proto_sctp.c:9:0:
> >    net/netfilter/ipvs/ip_vs_proto_sctp.c: In function 'sctp_conn_schedule':
> > >> include/net/ip_vs.h:1080:2: warning: 'ipvs' may be used uninitialized in this function [-Wmaybe-uninitialized]
> >      return ipvs->sysctl_sloppy_sctp;
> >      ^
> >    net/netfilter/ipvs/ip_vs_proto_sctp.c:18:21: note: 'ipvs' was declared here
> >      struct netns_ipvs *ipvs;
> 
> I wonder if squashing the following into the commit noted above is
> a good way to resolve this problem.
> 
> It looks to me that 'ipvs' may indeed be initialised.
> But that may be resolved by simply initialising it before rather
> than after the call to sctp_conn_schedule() in question.

	My compiler is silent about this problem :(
It needs to be fixed...

> My main concern is that rcu_read_lock() may also need to move.

	Not needed.

> diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> index 2026fca7e1c3..e000e6e76d71 100644
> --- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
> +++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
> @@ -13,9 +13,9 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		   int *verdict, struct ip_vs_conn **cpp,
>  		   struct ip_vs_iphdr *iph)
>  {
> -	struct net *net;
> +	struct net *net = skb_net(skb);
> +	struct netns_ipvs *ipvs = net_ipvs(net);
>  	struct ip_vs_service *svc;
> -	struct netns_ipvs *ipvs;
>  	sctp_chunkhdr_t _schunkh, *sch;
>  	sctp_sctphdr_t *sh, _sctph;
>  	__be16 _ports[2], *ports = NULL;
> @@ -40,8 +40,6 @@ sctp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
>  		return 0;
>  	}
>  
> -	net = skb_net(skb);
> -	ipvs = net_ipvs(net);
>  	rcu_read_lock();
>  	if (likely(!ip_vs_iph_inverse(iph)))
>  		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
> 

	Such patch looks good to me.

Regards

--
Julian Anastasov <ja@ssi.bg>
