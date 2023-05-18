From: Simon Horman <horms@kernel.org>
Subject: Re: [PATCH v3] ipvs: increase ip_vs_conn_tab_bits range for 64BIT
Date: Thu, 18 May 2023 20:52:12 +0200
Message-ID: <ZGZz3BcmSXm2KXLw@kernel.org>
References: <20230412-increase_ipvs_conn_tab_bits-v3-1-c813278f2d24@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1684435938;
        bh=ChP7EBU3iErxQg5xg1/sPCMbmF5dwTkOP9EktOEEk9Q=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=VG48LIRP1kSQNTCB/WIxiyyXO6IeBEzYwskdHaF1sK1rBSovOhEhucxMSkGHxHxTo
         eF7qNsnBl9auArI0zg8VrPZ2EMgV9cLDTmMumZ3MqOx+sUX6em0YChg4xrd9Hdlr51
         9lq3ajA9cCdQkFLQFpu3C2QiTg0OvPe+GOPiotdIuQ7pHlD5tzdY3mWUe97IFn6+a+
         ++fXuVC85DNEVb83mZojkg8wtpdqbssZDc9Dw/v157J2CvdbIPYCy5p1aklsNOMR1b
         q1irjFkAKfeB8oNETCpW+GG86CUzoithx/d2S9C/viCPUoF6KGu/+9N9yIok2vnMz/
         EIJe4Z2hn9q6A==
Content-Disposition: inline
In-Reply-To: <20230412-increase_ipvs_conn_tab_bits-v3-1-c813278f2d24@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Abhijeet Rastogi <abhijeet.1989@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Tue, May 16, 2023 at 08:08:49PM -0700, Abhijeet Rastogi wrote:
> Current range [8, 20] is set purely due to historical reasons
> because at the time, ~1M (2^20) was considered sufficient.
> With this change, 27 is the upper limit for 64-bit, 20 otherwise.
> 
> Previous change regarding this limit is here.
> 
> Link: https://lore.kernel.org/all/86eabeb9dd62aebf1e2533926fdd13fed48bab1f.1631289960.git.aclaudi@redhat.com/T/#u
> 
> Signed-off-by: Abhijeet Rastogi <abhijeet.1989@gmail.com>

Acked-by: Simon Horman <horms@kernel.org>


