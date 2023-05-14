From: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Subject: Re: [PATCH] ipvs: change ip_vs_conn_tab_bits range to [8,31]
Date: Sun, 14 May 2023 13:40:05 -0700
Message-ID: <CACXxYfxfkuo_EOa3TgBC7+iBXFckV3_csvUvLMN3VdfYPCkFQg@mail.gmail.com>
References: <20230412-increase_ipvs_conn_tab_bits-v1-1-60a4f9f4c8f2@gmail.com>
 <d2519ce3-e49b-a544-b79d-42905f4a2a9a@ssi.bg> <CACXxYfxLU0jWmq0W7YxX=44XFCGvgMX2HwTFUUHCUMjO28g5BA@mail.gmail.com>
 <2bc64d6d-6aa7-1477-0cd-8a41e68fcc5@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1684096843; x=1686688843;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=jTLrV1t79VLaE1SDZkVCg5CZRdC8GYzApnYPaUee360=;
        b=VeKFNu0SlE8bemNa4W77yFCM58pPpmOyusQXhEtzIrdPMZaaNekjj3ImZnBcpBRfh+
         D+Vl4urEyIHG7LNrtKn2fSu5HlQrPw+Avxh+f8aK2rI5WnBn+3RF0wOR/DAgntTAJjnd
         /2GfKh+7823LrzeFvh0AyDlcSngzHjYyOkCUSMrC9XVtcnjuLPJLimPrkDmS1nnRMTJL
         6V8eGMDH0gkAYxhMSkA/bMODoxeRqgypT3anK9SvaLdJyf0R4fzMJXe0zBMF3r3o+WsL
         bc8qPx4zXERl93imXnMSTlJTiEorxgocgY1rjcPyoUizkojFojwh57dUzjxUSL0m1Rc5
         zA0Q==
In-Reply-To: <2bc64d6d-6aa7-1477-0cd-8a41e68fcc5@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

>         One way to solve the problem is to use in Kconfig:
>
> range 8 20 if !64BIT
> range 8 27 if 64BIT

Thanks @Julian Anastasov. I appreciate the detailed response around
why these limits exist. Personally, I won't be able to own the task of
making these checks more intelligent, but for now, I wonder if it
would be okay to accept the range increase to 27.

I am sending a v2 patch to set a higher limit to 27.

Thanks,
Abhijeet
