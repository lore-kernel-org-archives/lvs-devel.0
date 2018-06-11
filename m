From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: allow PMTU exceptions to local routes
Date: Mon, 11 Jun 2018 07:55:07 -0600
Message-ID: <685977d8-0cce-8085-e8e4-4fd8e051c4d6@gmail.com>
References: <20180610230254.6347-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=SLxQtLSrL9RdyFitxWm589c3sOsIgbdj+ZHr20H/rjA=;
        b=tCiy/T5XmRgb6RWyIQBIUQiGd/2ekjTQbHoKxGoze13p7PkeyRW/e7zZ7K4GkRLzHy
         77B1vqfYu3/yRvmZZsZ1crnYeJmbxcXleZx/0jaQrg9ZLH/tu8q3B3E4pns0y0ZhSq9e
         1Qo38tHOcTqjCo34GD17Vvho7zMi/d3e6mGehuti9tDht7DqVA/onG29xb/O2g0yobVc
         64d6mxfzcROGPejzIw0dAJgBf0E/4MOK7yYbnmLiKF0bgCGcEhrHUDB0u+8qh1po/t1P
         od1HxCFnJSFs3JAnpPyZ1z/E7HoUMie2EQaF/d3S7ApXSRzKb886FGAae/zbtfKmWU3S
         J6DQ==
In-Reply-To: <20180610230254.6347-1-ja@ssi.bg>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>, kernel-team@fb.com, lvs-devel@vger.kernel.org

On 6/10/18 5:02 PM, Julian Anastasov wrote:
> IPVS setups with local client and remote tunnel server need
> to create exception for the local virtual IP. What we do is to
> change PMTU from 64KB (on "lo") to 1460 in the common case.
> 
> Suggested-by: Martin KaFai Lau <kafai@fb.com>
> Fixes: 45e4fd26683c ("ipv6: Only create RTF_CACHE routes after encountering pmtu exception")
> Fixes: 7343ff31ebf0 ("ipv6: Don't create clones of host routes.")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  net/ipv6/route.c | 3 ---
>  1 file changed, 3 deletions(-)
> 

Acked-by: David Ahern <dsahern@gmail.com>
