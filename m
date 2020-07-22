From: Matthieu Baerts <matthieu.baerts@tessares.net>
Subject: Re: [MPTCP] [PATCH 24/24] net: pass a sockptr_t into ->setsockopt
Date: Wed, 22 Jul 2020 10:26:42 +0200
Message-ID: <b3665200-2476-9d35-8dea-d5da141c6b70@tessares.net>
References: <20200720124737.118617-1-hch@lst.de>
 <20200720124737.118617-25-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tessares-net.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ijnpSqTzlWs7OuuIHaz94zTqsgZ4TkbrlxGL7rF8SvM=;
        b=xFRbFe5eYCppxJ62qFkLFv33fQa9ER4RHEl34g5WwIC4xdcR+4tivo7mnn1S+rNlbS
         cMN8QwQ1eW0avv9rFxBRIQMUktSGW06zNgKrNWQvq5F25hq8QLzdYCQ1hmqL4iSIvq09
         Szc8YdqC97qHUqKRHbhQr8/oguhWktZDZtVMGTavTEfzVAENBpjq7LQbsQSFC/Qb56AS
         G/7MNxNktsXQmENPoH9ousqNoZVBW0eyiSYtxkhGP/mapdbBWtSCpZCTmHbB+1rtyqO0
         wY2Oxf7ffMMplrOPj5lpx8Ya/rpegVFUOFLBmwqnjZVN6pLS4eW+iRKkCxAtMw4/FDqK
         d09g==
In-Reply-To: <20200720124737.118617-25-hch@lst.de>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.o

Hi Christoph,

On 20/07/2020 14:47, Christoph Hellwig wrote:
> Rework the remaining setsockopt code to pass a sockptr_t instead of a
> plain user pointer.  This removes the last remaining set_fs(KERNEL_DS)
> outside of architecture specific code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

...
> diff --git a/net/mptcp/protocol.c b/net/mptcp/protocol.c
> index 27b6f250b87dfd..30a8e697b9db9c 100644
> --- a/net/mptcp/protocol.c
> +++ b/net/mptcp/protocol.c
> @@ -1627,7 +1627,7 @@ static void mptcp_destroy(struct sock *sk)
>   }
>   
>   static int mptcp_setsockopt_sol_socket(struct mptcp_sock *msk, int optname,
> -				       char __user *optval, unsigned int optlen)
> +				       sockptr_t optval, unsigned int optlen)
>   {
>   	struct sock *sk = (struct sock *)msk;
>   	struct socket *ssock;
> @@ -1643,8 +1643,8 @@ static int mptcp_setsockopt_sol_socket(struct mptcp_sock *msk, int optname,
>   			return -EINVAL;
>   		}
>   
> -		ret = sock_setsockopt(ssock, SOL_SOCKET, optname,
> -				      USER_SOCKPTR(optval), optlen);
> +		ret = sock_setsockopt(ssock, SOL_SOCKET, optname, optval,
> +				      optlen);

A very small detail related to the modifications in MPTCP code, only if 
you have to send a v2 and if you don't mind: may you move "optlen" to 
the previous line like it was before your patch 7/24. Same below at the 
end of the function.

That would reduce the global diff in MPTCP files to function signatures 
only.

Cheers,
Matt
-- 
Tessares | Belgium | Hybrid Access Solutions
www.tessares.net
