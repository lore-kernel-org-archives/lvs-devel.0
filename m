From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next,v3 03/14] ipvs: Handle inverse and icmp headers
 in ip_vs_leave
Date: Wed, 26 Aug 2015 15:29:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1508261442060.3538@ja.home.ssi.bg>
References: <1440560969-3511889-1-git-send-email-agartrell@fb.com> <1440560969-3511889-3-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1440560969-3511889-3-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, alexgartrell@gmail.com, kernel-team@fb.com


	Hello,

On Tue, 25 Aug 2015, Alex Gartrell wrote:

> -	if ((svc->port == FTPPORT) && (pptr[1] != FTPPORT))
> +	if (svc->port == FTPPORT && dport != FTPPORT)
>  		return NF_ACCEPT;

	Not sure if we have chance for this merge window
but only small things for patches 3 and 4 need to be fixed:

Patch 1: OK
Patch 2: OK

Patch 3:
	- We need to prevent ICMP-to-ICMP in ip_vs_leave:

	if (svc->port == FTPPORT && dport != FTPPORT)
		return NF_ACCEPT;

+	if (ip_vs_iph_icmp(iph))
+		return NF_DROP;

Patch 4:
	- I now see that first IP_VS_DBG_PKT in ip_vs_try_to_schedule
needs iph->off instead of 0.

Patch 5: OK
Patch 6: OK
Patch 7: OK
Patch 8: OK
Patch 9: OK
Patch 10: OK
Patch 11: OK
Patch 12: OK
Patch 13: OK
Patch 14: OK

Regards

--
Julian Anastasov <ja@ssi.bg>
