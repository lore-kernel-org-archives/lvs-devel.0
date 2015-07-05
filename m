From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipvs: skb_orphan in case of forwarding
Date: Sun, 5 Jul 2015 23:58:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1507052351490.12815@ja.home.ssi.bg>
References: <1436127950-1481955-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1436127950-1481955-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, kernel-team@fb.com


	Hello,

On Sun, 5 Jul 2015, Alex Gartrell wrote:

> +	/* Remove the early_demux association unless it's bound for the
> +	 * exact same port and address on this host after translation.
> +	 */
> +	if (!local || cp->vport != cp->dport ||
> +	    !ip_vs_addr_equal(cp->af, &cp->vaddr, &cp->caddr))

	Sigh, it was my mistake, it should be
cp->daddr instead of cp->caddr. It seems, I copied it
from somewhere to give example... Sorry, can you resend
with cp->daddr as v2.

Regards

--
Julian Anastasov <ja@ssi.bg>
