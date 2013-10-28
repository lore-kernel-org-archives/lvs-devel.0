From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 ipvs-next] net: ipvs: sctp: do not recalc sctp csum
 when ports didn't change
Date: Mon, 28 Oct 2013 10:47:25 +0100
Message-ID: <526E32AD.8030203@redhat.com>
References: <1382951695-7759-1-git-send-email-dborkman@redhat.com> <alpine.LFD.2.03.1310281136300.1490@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.03.1310281136300.1490@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On 10/28/2013 10:44 AM, Julian Anastasov wrote:
[...]
> 	Sorry, just now noticed the errors from
> scripts/checkpatch.pl:
>
> ERROR: do not use assignment in if condition
> #78: FILE: net/netfilter/ipvs/ip_vs_proto_sctp.c:103:
> +               if (!(ret = ip_vs_app_pkt_out(cp, skb)))
>
> ERROR: do not use assignment in if condition
> #120: FILE: net/netfilter/ipvs/ip_vs_proto_sctp.c:149:
> +               if (!(ret = ip_vs_app_pkt_in(cp, skb)))
>
> total: 2 errors, 0 warnings, 81 lines checked
>
> 	I know that you copied the TCP logic that was
> added by me but now we should split the complex conditions
> at both places:
>
> 	ret = ...
> 	if (!ret)
> 		return 0;
>
> 	Otherwise patch looks good and I'll ack v3 with
> the above changes.

Ok, sure, I'll update with the cosmetic change.
