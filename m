From: "Julius Volz" <juliusv@google.com>
Subject: Re: Should we move IPVS out of net/ipv4 now?
Date: Mon, 22 Sep 2008 11:16:10 +0200
Message-ID: <f4845fc0809220216p543af0fcu9ee486feba287c12@mail.gmail.com>
References: <20080918235220.GD13536@verge.net.au>
	 <20080918.170030.32445027.davem@davemloft.net>
	 <f4845fc0809190247l631c2a56se956f46078b41ef3@mail.gmail.com>
	 <20080919.124553.193698159.davem@davemloft.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1222074973; bh=QjeyDcaE9Wgx3XLrDNuj3v5hwj4=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References:X-GMailtapped-By; b=LTjyzYnzDiTw7Ni
	ogjAJnowHa8goRG6n0HHShstEEU5PNhN5hgsrKb8lOSDsDAAf2bvTkR6UkbY8atYhgB
	Hndw==
In-Reply-To: <20080919.124553.193698159.davem@davemloft.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: David Miller <davem@davemloft.net>
Cc: horms@verge.net.au, csnook@redhat.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Fri, Sep 19, 2008 at 9:45 PM, David Miller <davem@davemloft.net> wrote:
> From: "Julius Volz" <juliusv@google.com>
> Date: Fri, 19 Sep 2008 11:47:13 +0200
>
>> The build with ARCH=um seems to have a problem with the
>> architecture-specific headers:
>>
>> net/core/skb_dma_map.c: In function 'skb_dma_map':
>> net/core/skb_dma_map.c:20: error: implicit declaration of function
>> 'dma_mapping_error'
>>
>> The bad commit that introduces the skb_dma_map.c file (and this error)
>> is a40c24a1336. Previous versions build fine.
>
> I'll commit the following to net-next-2.6, let me know if it doesn't
> take care of the problem:
>
> net: Fix build with ARCH=um
>
> If UM is going to claim that it supports DMA by setting
> HAS_DMA, it should provide a dma_mapping_error() implementation.
>
> Based upon a report by Julius Volz.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/asm-um/dma-mapping.h |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/include/asm-um/dma-mapping.h b/include/asm-um/dma-mapping.h
> index f0ee4fb..90fc708 100644
> --- a/include/asm-um/dma-mapping.h
> +++ b/include/asm-um/dma-mapping.h
> @@ -118,4 +118,11 @@ dma_cache_sync(struct device *dev, void *vaddr, size_t size,
>        BUG();
>  }
>
> +static inline int
> +dma_mapping_error(struct device *dev, dma_addr_t dma_handle)
> +{
> +       BUG();
> +       return 0;
> +}
> +
>  #endif
> --

Thanks, that got rid of the problem!

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
