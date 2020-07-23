From: Matthieu Baerts <matthieu.baerts@tessares.net>
Subject: Re: [MPTCP] [PATCH 08/26] net: switch sock_set_timeout to sockptr_t
Date: Thu, 23 Jul 2020 10:39:50 +0200
Message-ID: <092368db-122f-60bc-6a32-3cd5c70727da@tessares.net>
References: <20200723060908.50081-1-hch@lst.de>
 <20200723060908.50081-9-hch@lst.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tessares-net.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=t34u4KAm1gK/f1oDA6+0ZgZ3T1IDP3Ad7b21M8jn9IE=;
        b=CNsYMCaC5YFx1sCHrUnGTyxK55+RElxWw1Y4CgVq4WviDSpLe5tvZRQNhbw/o8NHkS
         5lNPKTvPIJgzELza08HXzETuGDGqESAjMwaETk5Mmah7A76FYju7HEJcSxVz2Z68Ez32
         Fe8bkyg3EIliyQfIE0WUqAFYcrQUJWfpZsNbAdl/ll0KB40GMQt1yoxZTtepzlC4KdnZ
         GnSg5TjVpPWt7FlYOZYnnYqZEV4wmhNftYUlMk2HjS0eEZRDa0Aihb7OonspbY3XBKmu
         gfkANWXjINxT44g2wwmEPqLtqbE4VWM7CM7H0NR7+q8PAGIse1jhucMrcCJVf3oeSFy2
         TE7Q==
In-Reply-To: <20200723060908.50081-9-hch@lst.de>
Content-Language: en-GB
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com, linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, linux-x25@vger.kernel.org

Hi Christoph,

On 23/07/2020 08:08, Christoph Hellwig wrote:
> Pass a sockptr_t to prepare for set_fs-less handling of the kernel
> pointer from bpf-cgroup.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   net/mptcp/protocol.c |  6 ++++--

Thank you for looking at that!

For MPTCP-related code:

Acked-by: Matthieu Baerts <matthieu.baerts@tessares.net>

Cheers,
Matt
-- 
Tessares | Belgium | Hybrid Access Solutions
www.tessares.net
