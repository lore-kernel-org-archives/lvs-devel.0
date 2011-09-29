From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC] IPVS: secure_tcp does provide alternate state timeouts
Date: Thu, 29 Sep 2011 11:47:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109291119420.1696@ja.ssi.bg>
References: <1317281111-23985-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1317281111-23985-1-git-send-email-horms@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org


	Hello,

On Thu, 29 Sep 2011, Simon Horman wrote:

> * Also reword the test to make it read more easily (to me)
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> ---
> 
> Julian, I don't see that IPVS currently implements alternate
> timeouts for secure_tcp. Am I missing something?

	Yes, only states are changed. What is missing is a
libipvs support to modify per-protocol timeouts because they
are not exported to /proc anymore. As the states have name,
may be we can implement timeout to be set as follows:

	ipvsadm --set-state-timeout -p TCP SYN 10

	Using 2 timeout tables just for secure_tcp is
complicated and with the above control it is not needed.

> ---
>  Documentation/networking/ipvs-sysctl.txt |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/networking/ipvs-sysctl.txt b/Documentation/networking/ipvs-sysctl.txt
> index 1dcdd49..13610e3 100644
> --- a/Documentation/networking/ipvs-sysctl.txt
> +++ b/Documentation/networking/ipvs-sysctl.txt
> @@ -140,13 +140,11 @@ nat_icmp_send - BOOLEAN
>  secure_tcp - INTEGER
>          0  - disabled (default)
>  
> -        The secure_tcp defense is to use a more complicated state
> -        transition table and some possible short timeouts of each
> -        state. In the VS/NAT, it delays the entering the ESTABLISHED
> -        until the real server starts to send data and ACK packet
> -        (after 3-way handshake).
> +	The secure_tcp defense is to use a more complicated TCP state
> +	transition table. For VS/NAT, it also delays entering the
> +	TCP ESTABLISHED state until the three way handshake is completed.
>  
> -        The value definition is the same as that of drop_entry or
> +        The value definition is the same as that of drop_entry and
>          drop_packet.
>  
>  sync_threshold - INTEGER
> -- 
> 1.7.5.4

Regards

--
Julian Anastasov <ja@ssi.bg>
