From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next,v4 01/14] ipvs: replace ip_vs_fill_ip4hdr with
 ip_vs_fill_iph_skb_off
Date: Wed, 26 Aug 2015 20:37:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1508262034120.22375@ja.home.ssi.bg>
References: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1440607241-355987-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, alexgartrell@gmail.com, kernel-team@fb.com


	Hello,

On Wed, 26 Aug 2015, Alex Gartrell wrote:

> This removes some duplicated code and makes the ICMPv6 path look more like
> the ICMP path.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

	All patches 1-14 look ok to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Not sure why 00/14 is missing, it is useful.

Regards

--
Julian Anastasov <ja@ssi.bg>
