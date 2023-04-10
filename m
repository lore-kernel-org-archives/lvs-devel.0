From: Simon Horman <horms@kernel.org>
Subject: Re: [PATCH nf-next 0/4] ipvs: Cleanups for v6.4
Date: Mon, 10 Apr 2023 14:20:46 +0200
Message-ID: <ZDP/Ht1Nb4iRSkI8@kernel.org>
References: <20230409-ipvs-cleanup-v1-0-98cdc242feb0@kernel.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1681129251;
        bh=qAiViZFTjwW5jvmupiD8t0d1vpgVxX0pOPthBKjeqgo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=VMZZvgq8avInlnsgTtRo5FoOCXzQeNjdBmnVsAkvyGpyfVdM0FjWOjSlIirmj8d3G
         7+9O9FA8RsQUVBxKKC5pTKOw/geUfiSa2q8bmyfGQwxA0fhmeez92HGFrq9uRLpWpv
         7Nng4sa2JJ47hxdP1xR4AU5FLZVJjOrW9foh/MOzs7zRHfMTInsCtp9lHWZmBb2TGS
         e/lA30gO3CPsELJdFX+EkuvS1SG3+woz/d4HM4pwU0tO6ez1SUEY4qt2iuWiHfqQFs
         NhYVH1gEIPtlOzFuN1HDIBiwsUQRIdWjOH3FUXOIwJE3FHLZK1vsPAPWJl0REiTPFD
         UKD9ouPACa6Qg==
Content-Disposition: inline
In-Reply-To: <20230409-ipvs-cleanup-v1-0-98cdc242feb0@kernel.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, David Ahern <dsahern@kernel.org>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Mon, Apr 10, 2023 at 11:42:34AM +0200, Simon Horman wrote:
> Hi Pablo,
> 
> this series aims to clean up IPVS in several ways without
> implementing any functional changes, aside from removing
> some debugging output.
> 
> Patch 1/4: Update width of source for ip_vs_sync_con_options
>            The operation is safe, use an annotation to describe it properly.
> 
> Patch 2/4: Consistently use array_size() in ip_vs_conn_init()
>            It seems better to use helpers consistently.
> 
> Patch 3/4: Remove {Enter,Leave}Function
>            These seem to be well past their use-by date.
> 
> Patch 4/4: Correct spelling in comments
> 	   I can't spell. But codespell helps me these days.
> 
> All changes: compile tested only!

Hi all,

Julian pointed out some minor issues which I will address in a v2.
