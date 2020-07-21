From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH 02/24] bpfilter: fix up a sparse annotation
Date: Tue, 21 Jul 2020 04:40:16 +0200
Message-ID: <20200721024016.2talwdt5hjqvirr6@ltop.local>
References: <20200720124737.118617-1-hch@lst.de>
 <20200720124737.118617-3-hch@lst.de>
Mime-Version: 1.0
Return-path: <linux-can-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=uGJfiXXxVHM7zniHW3sl0xVltZ7h7OdT0FRQ5H6GgQM=;
        b=OeoCW/0tbvMmfJG3/GXVxS0sf0NU1F3vv5ek0RwSeUB4oL3xBRF4212opG/Qca2oMt
         w/LznXXPQ/9latRxVyAN7HoUeXaNxvpuCBnCtE8R4VgfJiFrlJWGUZ3AudCWWBSFASY5
         rHitPZwk5CzwZGC9yY+cINRMFHfhNoff5Hs0bqMLp86BM3TNE6gCd0fujLU9Jp1gGqkn
         fbgcZ3ejttQ6DUlGWTOX05MbhnYkq6NEeVjuv6BJvSSMm0lLza1F8vnXHY24yVrWhuUw
         mE4fVqq6wL70udwjlBJkWv9YZBUUfIIT74p06ZRe0yu4iR7nwWtzJQYm2S7oIsa47DMh
         Anhg==
Content-Disposition: inline
In-Reply-To: <20200720124737.118617-3-hch@lst.de>
Sender: linux-can-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.o

On Mon, Jul 20, 2020 at 02:47:15PM +0200, Christoph Hellwig wrote:
> The __user doesn't make sense when casting to an integer type.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  net/bpfilter/bpfilter_kern.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bpfilter/bpfilter_kern.c b/net/bpfilter/bpfilter_kern.c
> index 977e9dad72ca4f..713b4b3d02005d 100644
> --- a/net/bpfilter/bpfilter_kern.c
> +++ b/net/bpfilter/bpfilter_kern.c
> @@ -49,7 +49,7 @@ static int __bpfilter_process_sockopt(struct sock *sk, int optname,
>  	req.is_set = is_set;
>  	req.pid = current->pid;
>  	req.cmd = optname;
> -	req.addr = (long __force __user)optval;
> +	req.addr = (__force long)optval;

For casts to integers, even '__force' is not needed (since integers
can't be dereferenced, the concept of address-space is meaningless
for them, so it's never useful to warn when it's dropped and
'__force' is thus not needed).

-- Luc
