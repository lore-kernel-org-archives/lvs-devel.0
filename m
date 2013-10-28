From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 ipvs-next] net: ipvs: sctp: do not recalc sctp csum
 when ports didn't change
Date: Mon, 28 Oct 2013 11:44:51 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1310281136300.1490@ssi.bg>
References: <1382951695-7759-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1382951695-7759-1-git-send-email-dborkman@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org


	Hello,

On Mon, 28 Oct 2013, Daniel Borkmann wrote:

>  		/* Call application helper if needed */
> -		if (!ip_vs_app_pkt_out(cp, skb))
> +		if (!(ret = ip_vs_app_pkt_out(cp, skb)))
>  			return 0;

> -		if (!ip_vs_app_pkt_in(cp, skb))
> +		if (!(ret = ip_vs_app_pkt_in(cp, skb)))
>  			return 0;

	Sorry, just now noticed the errors from
scripts/checkpatch.pl:

ERROR: do not use assignment in if condition
#78: FILE: net/netfilter/ipvs/ip_vs_proto_sctp.c:103:
+               if (!(ret = ip_vs_app_pkt_out(cp, skb)))

ERROR: do not use assignment in if condition
#120: FILE: net/netfilter/ipvs/ip_vs_proto_sctp.c:149:
+               if (!(ret = ip_vs_app_pkt_in(cp, skb)))

total: 2 errors, 0 warnings, 81 lines checked

	I know that you copied the TCP logic that was
added by me but now we should split the complex conditions
at both places:

	ret = ...
	if (!ret)
		return 0;

	Otherwise patch looks good and I'll ack v3 with
the above changes.

Regards

--
Julian Anastasov <ja@ssi.bg>
