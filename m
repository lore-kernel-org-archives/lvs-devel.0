From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next 0/2] ipvs: minor clean ups flagged by sparse
Date: Sat, 20 Apr 2013 12:19:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1304201218001.1593@ja.ssi.bg>
References: <1366336315-25823-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366336315-25823-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>


	Hello,

On Fri, 19 Apr 2013, Simon Horman wrote:

> Hi,
> 
> this short series cleans up two minor problems flagged by sparse,
> in both cases shadowed variables.
> 
> [PATCH 1/2] ipvs: Avoid shadowing net variable in ip_vs_leave()
> [PATCH 2/2] ipvs: Use min3() in ip_vs_dbg_callid()

	Both look good to me. In case you wait for ack,

Acked-by: Julian Anastasov <ja@ssi.bg>

