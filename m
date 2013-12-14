From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: avoid oops in nf_ct_seqadj_set when called from
 ip_vs_ftp helper
Date: Sun, 15 Dec 2013 00:25:45 +0200 (EET)
Message-ID: <alpine.LFD.2.10.1312142351130.1963@ja.home.ssi.bg>
References: <20131213214023.14478.74738.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20131213214023.14478.74738.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>


	Hello,

On Fri, 13 Dec 2013, Jesper Dangaard Brouer wrote:

> The IPVS FTP helper ip_vs_ftp can trigger an OOPS in nf_ct_seqadj_set,
> after commit 41d73ec053d2 (netfilter: nf_conntrack: make sequence
> number adjustments usuable without NAT).
> 
> We can avoid the oops in nf_ct_seqadj_set() by in ip_vs_ftp_out()
> instead of calling nf_nat_mangle_tcp_packet() we simply call
> __nf_nat_mangle_tcp_packet() with a "false" last parameter, which
> indicate not invoking the seqadj code.
> 
> After this fix, I've tested that FTP over IPVS, with module ip_vs_ftp
> loaded, works for both passive and active FTP.

	There is still a problem when RIP and VIP differ in
text length because now ack_seq sent to RIP is not
adjusted after receiving the the 227 Entering Passive Mode
reply. I tried also to set *diff, ack_seq was corrected
but the result was bad checksum.

> Fixes: 41d73ec053d2 (netfilter: nf_conntrack: make sequence number adjustments usuable without NAT)
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ---
> I'm uncertain if this is the correct fix.  Perhaps the ip_vs_ftp
> helper need to allocate/init the seqadj extension instead?

	Agreed, lets try nfct_seqadj_ext_add() + nf_ct_seqadj_init()
if nfct_seqadj(ct) is NULL.

Regards

--
Julian Anastasov <ja@ssi.bg>
