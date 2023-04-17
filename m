From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next v3 0/4] ipvs: Cleanups for v6.4
Date: Mon, 17 Apr 2023 19:59:35 +0300 (EEST)
Message-ID: <a873ffc-bcdf-934f-127a-80188e8b33e6@ssi.bg>
References: <20230409-ipvs-cleanup-v3-0-5149ea34b0b9@kernel.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20230409-ipvs-cleanup-v3-0-5149ea34b0b9@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@kernel.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Horatiu Vultur <horatiu.vultur@microchip.com>


	Hello,

On Mon, 17 Apr 2023, Simon Horman wrote:

> Hi Julian,
> 
> this series aims to clean up IPVS in several ways without
> implementing any functional changes, aside from removing
> some debugging output.
> 
> Patch 1/4: Update width of source for ip_vs_sync_conn_options
>            The operation is safe, use an annotation to describe it properly.
> 
> Patch 2/4: Consistently use array_size() in ip_vs_conn_init()
>            It seems better to use helpers consistently.
> 
> Patch 3/4: Remove {Enter,Leave}Function
>            These seem to be well past their use-by date.
> 
> Patch 4/4: Correct spelling in comments
> 	   I can't spell. But codespell helps me these days.
> 
> All changes: compile tested only!
> 
> ---
> Changes in v3:
> - Patch 2/4: Correct division by 1024.
>              It was applied to the wrong variable in v2.
> - Add Horatiu's Reviewed-by tag.
> 
> Changes in v2:
> - Patch 1/4: Correct spelling of 'conn' in subject.
> - Patch 2/4: Restore division by 1024. It was lost on v1.
> 
> ---
> Simon Horman (4):
>       ipvs: Update width of source for ip_vs_sync_conn_options
>       ipvs: Consistently use array_size() in ip_vs_conn_init()
>       ipvs: Remove {Enter,Leave}Function
>       ipvs: Correct spelling in comments

	The patchset looks good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

>  include/net/ip_vs.h             | 32 +++++----------------
>  net/netfilter/ipvs/ip_vs_conn.c | 12 ++++----
>  net/netfilter/ipvs/ip_vs_core.c |  8 ------
>  net/netfilter/ipvs/ip_vs_ctl.c  | 26 +----------------
>  net/netfilter/ipvs/ip_vs_sync.c |  7 +----
>  net/netfilter/ipvs/ip_vs_xmit.c | 62 ++++++-----------------------------------
>  6 files changed, 23 insertions(+), 124 deletions(-)
> 
> base-commit: 99676a5766412f3936c55b9d18565d248e5463ee

Regards
