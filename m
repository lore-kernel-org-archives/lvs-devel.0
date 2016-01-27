From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] netfilter: ipvs/SIP: handle ip_vs_fill_iph_skb_off
 failure
Date: Wed, 27 Jan 2016 22:56:08 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1601272241530.2353@ja.home.ssi.bg>
References: <1453902749-3422685-1-git-send-email-arnd@arndb.de>
 <1453902749-3422685-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1453902749-3422685-2-git-send-email-arnd@arndb.de>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>, 
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>, 
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Wensong Zhang <wensong@linux-vs.org>, coreteam@netfilter.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>


	Hello,

On Wed, 27 Jan 2016, Arnd Bergmann wrote:

> ip_vs_fill_iph_skb_off() may not find an IP header, and gcc has
> determined that ip_vs_sip_fill_param() then incorrectly accesses
> the protocol fields:
> 
> net/netfilter/ipvs/ip_vs_pe_sip.c: In function 'ip_vs_sip_fill_param':
> net/netfilter/ipvs/ip_vs_pe_sip.c:76:5: error: 'iph.protocol' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>   if (iph.protocol != IPPROTO_UDP)
>      ^
> net/netfilter/ipvs/ip_vs_pe_sip.c:81:10: error: 'iph.len' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>   dataoff = iph.len + sizeof(struct udphdr);
>           ^
> 
> This adds a check for the ip_vs_fill_iph_skb_off() return code
> before looking at the ip header data returned from it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: b0e010c527de ("ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off")

	Looks ok to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

	but see below...

> ---
>  net/netfilter/ipvs/ip_vs_pe_sip.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
> index 1b8d594e493a..c4e9ca016a88 100644
> --- a/net/netfilter/ipvs/ip_vs_pe_sip.c
> +++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
> @@ -70,10 +70,10 @@ ip_vs_sip_fill_param(struct ip_vs_conn_param *p, struct sk_buff *skb)
>  	const char *dptr;
>  	int retc;
>  
> -	ip_vs_fill_iph_skb(p->af, skb, false, &iph);
> +	retc = ip_vs_fill_iph_skb(p->af, skb, false, &iph);
>  
>  	/* Only useful with UDP */
> -	if (iph.protocol != IPPROTO_UDP)
> +	if (!retc || iph.protocol != IPPROTO_UDP)
>  		return -EINVAL;
>  	/* todo: IPv6 fragments:
>  	 *       I think this only should be done for the first fragment. /HS

	There are other places like this where result is not
checked because there is always a guarding skb_header_pointer
check, i.e. ip_vs_fill_iph_skb* should not fail at such point.

	Let us know you want to extend this patch with other such
calls (including ip_vs_fill_iph_skb_icmp)? May be they will
need return NF_ACCEPT. I guess, all such changes should be
for the ipvs-next/net-next tree when it opens.

Regards

--
Julian Anastasov <ja@ssi.bg>
