From: "Julius Volz" <julius.volz@gmail.com>
Subject: Re: [PATCH] IPVS: Add IPv6 support to LBLC/LBLCR schedulers
Date: Tue, 4 Nov 2008 01:59:04 +0100
Message-ID: <43ca39800811031659g4f74e1beh321463953a86f19b@mail.gmail.com>
References: <20081103231712.GA7807@cydonia.lan>
	 <20081104001451.GA18842@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:message-id:date:from:to
         :subject:cc:in-reply-to:mime-version:content-type
         :content-transfer-encoding:content-disposition:references;
        bh=Pa0mZA0CIQU7MLw72mtaZI+osSHxI/iLn6GHY2BalOM=;
        b=ArGYeYJBhxkbiBE2iRdPxjurrfeOHjPFiRMGoQHs9qbxneK0vRSxPZMlwAKvkdAe5D
         tGdfTFNkaqD6UBrxZcpRbWyC7RN3BucFcNZHHiwk64ZiQ2vZ8sH1JOe10t/ZV6GIghFi
         +KY4qamEAYO+zz6HZ0nc2ibgsAGjrpLnhhPW8=
In-Reply-To: <20081104001451.GA18842@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, David Miller <davem@davemloft.net>

On Tue, Nov 4, 2008 at 1:14 AM, Simon Horman <horms@verge.net.au> wrote:
> On Tue, Nov 04, 2008 at 12:17:12AM +0100, Julius Volz wrote:
>> Add IPv6 support to LBLC and LBLCR schedulers. These were the last
>> schedulers without IPv6 support, but we might want to keep the
>> supports_ipv6 flag in the case of future schedulers without IPv6
>> support.
>
> Hi Julius,
>
> this patch looks fine to me.
>
> Acked-by: Simon Horman <horms@verge.net.au>

Thanks!

> With regards to supports_ipv6, I think that it would be better
> to remove it, now that it is unused, and add it (or something similar)
> back if needed as I'm not entirely sure it will ever be needed again.

Agreed and patch sent!

Julius
