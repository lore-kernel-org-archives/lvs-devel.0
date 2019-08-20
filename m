From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: change type of delta and previous_delta in
 ip_vs_seq.
Date: Tue, 20 Aug 2019 13:00:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1908201250440.3332@ja.home.ssi.bg>
References: <20190820003718.GA16620@toolchain>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20190820003718.GA16620@toolchain>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: zhang kai <zhangkaiheb@126.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org


	Hello,

	Cc list trimmed...

On Tue, 20 Aug 2019, zhang kai wrote:

> In NAT forwarding mode, Applications may decrease the size of packets,
> and TCP sequences will get smaller, so both of variables will be negetive
> values in this case.

	As long as nobody cares about their sign, the type should not
matter. You can not solve all signed/unsigned mismatches with such
small patch. Or you are seeing some problem, may be in debug?

> 
> Signed-off-by: zhang kai <zhangkaiheb@126.com>
> ---
>  include/net/ip_vs.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 3759167f91f5..de7e75063c7c 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -346,8 +346,8 @@ enum ip_vs_sctp_states {
>   */
>  struct ip_vs_seq {
>  	__u32			init_seq;	/* Add delta from this seq */
> -	__u32			delta;		/* Delta in sequence numbers */
> -	__u32			previous_delta;	/* Delta in sequence numbers
> +	__s32			delta;		/* Delta in sequence numbers */
> +	__s32			previous_delta;	/* Delta in sequence numbers
>  						 * before last resized pkt */
>  };
>  
> -- 
> 2.17.1

Regards
