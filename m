From: Simon Horman <horms@kernel.org>
Subject: Re: [PATCH] ipvs: change ip_vs_conn_tab_bits range to [8,31]
Date: Thu, 13 Apr 2023 10:09:56 +0200
Message-ID: <ZDe41Nc8BjkXVcrf@kernel.org>
References: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681373403;
        bh=lMClDkMrgqgkJYaMUUXc7/mL4pKlD3f/q5HMOfhzsoY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=NrVGILoJGNuSkcJ8ebmZ3OaXsNtuRgD3ADdYmEXq1EBGMsJ8MgbgrrQT+xre30wWb
         sLxhmaVhLtSwCK34+4lPwOqkS+Q24SHaab5F75XpgDWl+B59vSlwa10JebA+mY3Znm
         61p+mQ0wc9P+xmyBuJKVqPbWOJxxRNHL2mJ3avIG5TQApSy7ldImysGlgb7BJNgApn
         Czikowyvobhpnxr0ep/w8fyH8Mvyg7d6uN51pTRchBawYK/slaTNkAzgYC62bS8vX2
         aG4s6z1K+YkNrZdtVay8HqRzIps2JMGrYCzeTxICQp5KdczeOAWt2r7TdKAFN84DsC
         KoxLFMjhj9M2w==
Content-Disposition: inline
In-Reply-To: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Wed, Apr 12, 2023 at 01:49:08PM -0700, Abhijeet Rastogi via B4 Relay wrote:
> From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
> 
> Current range [8, 20] is set purely due to historical reasons
> because at the time, ~1M (2^20) was considered sufficient.
> 
> Previous change regarding this limit is here.
> 
> Link: https://lore.kernel.org/all/86eabeb9dd62aebf1e2533926fdd13fed48bab1f.1631289960.git.aclaudi@redhat.com/T/#u
> 
> Signed-off-by: Abhijeet Rastogi <abhijeet.1989@gmail.com>
> ---

Hi Abhijeet,

> The conversation for this started at: 
> 
> https://www.spinics.net/lists/netfilter/msg60995.html

  'The 20 bit (1m entries) ceiling exists since the original merge of ipvs
   in 2003, so likely this was just considered "big enough" back then.'

Yes, that matches my recollection.

There were probably also concerns about the viability of making
larger allocations at the time on the kinds of systems where
IPVS would be deployed.

On the allocation theme, I do note that 2^31 does lead to a substantial
vmalloc allocation regardless of actual usage. Probably it would be best
to move IPVS to use rhashtable(). But that is obviously a much more
invasive change.

In any case, I think this patch is an improvement on the current situation.

Acked-by: Simon Horman <horms@kernel.org>

> 
> The upper limit for algo is any bit size less than 32, so this
> change will allow us to set bit size > 20. Today, it is common to have
> RAM available to handle greater than 2^20 connections per-host.
> 
> Distros like RHEL already have higher limits set.

...
