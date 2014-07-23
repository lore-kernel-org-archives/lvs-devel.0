From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs 1/2] ipvs: Do tcp/udp checksumming prior to tunnel
 xmit
Date: Wed, 23 Jul 2014 11:25:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407231054180.5114@ja.home.ssi.bg>
References: <1406097465-8180-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1406097465-8180-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Tue, 22 Jul 2014, Alex Gartrell wrote:

> The combination of NF_INET_LOCAL_OUT and hardware checksum offload results
> in picking the packet out of the send path before it gets proper checksums.
> Our NICs (most NICs?) cannot do the checksumming in ipip packets, so these
> faulty tcp/udp headers arrive at their destination and are discarded.
> 
> Instead, checksum the tcp/udp packets in the tunnel transmit path.  Right
> now we do this for all packets, but a subsequent patch will limit this to
> the NF_INET_LOCAL_OUT hook.

	After the support for hardware-offloaded encapsulation
went in we may lack some support, like playing with skb->encapsulation, 
etc. I'm not sure calculating the checksums in all
cases (ip_summed) is the right thing to do.

	For DR and TUN we tried to avoid checking and
calculating checksum because we do not mangle the payload.
But CHECKSUM_PARTIAL in ip_summed is a special case.
We call skb_forward_csum() from ip_vs_tunnel_xmit_prepare
but may be it is not enough. Such interesting case is
local TCP client (CHECKSUM_PARTIAL) forwarded via TUN.

	ipip.c and ip_tunnel_core.c are good source of
information. I think, we can check what is needed
to complete the partial checksum while adding IPIP header.
For example, calling skb_checksum_help() may be
enough for the CHECKSUM_PARTIAL case. See
iptunnel_handle_offloads() for reference.

	Can you give more information, eg. what
value you see in ip_summed, leading to these problems?
And whether packet to IPVS comes from local stack or
from remote client. Is TCP/UDP checksum offload running?

Regards

--
Julian Anastasov <ja@ssi.bg>
