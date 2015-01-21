From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: orphan skb on LOCAL_IN path
Date: Thu, 22 Jan 2015 00:43:27 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501212355350.2701@ja.home.ssi.bg>
References: <1421794516-309785-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1421794516-309785-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Tue, 20 Jan 2015, Alex Gartrell wrote:

> skb->sk can be set in the early_demux path.  This can be problematic, as it
> may be a time-wait socket, which will blow up in the ip6_output path when
> we try to pull out the non-existent pinet6 pointer (the type-punning causes
> that pointer to be garbage).
> 
> This patch orphans the skb if it's not a local socket, so we no longer have
> to worry about running into the time-wait problem from early demux.

	Good idea. But there is a case where for traffic to
local real server we return NF_ACCEPT.

	In this case we have to preserve the skb->sk. I guess
skb_orphan should be used as follows. skb->dev is NULL
for LOCAL_OUT and non-NULL for LOCAL_IN/FORWARD but
for FORWARD we do not care for skb->sk. So, we can
check just for skb->dev.

- ip_vs_send_or_cont: Handles ip_vs_null_xmit,
ip_vs_bypass_xmit*, ip_vs_dr_xmit*, ip_vs_icmp_xmit(non-NAT)

	/* Not a local client? */
	if (skb->dev)
		skb_orphan(skb);

	It should be added only before NF_HOOK.
I.e. when 'local' is true (local RIP) we should not
drop the socket.

- ip_vs_nat_send_or_cont(NAT): same but no matter the 'local' var
because we can change daddr/dport in packet and to
return NF_ACCEPT. As daddr/dport changes we have to drop
the socket. In the worst case, when RIP:RPORT
matches VIP:VPORT daddr/dport do not change but we
do not have indication, we blindly drop sk. In
such case DR method is recommended instead, it will not
drop the socket when 'local' is true.

	if (skb->dev)
		skb_orphan(skb);

- ip_vs_tunnel_xmit_prepare (TUN): before nf_reset(),
it is called for remote real server (i.e. no 'local' var there):

	if (skb->dev)
		skb_orphan(skb);

Regards

--
Julian Anastasov <ja@ssi.bg>
