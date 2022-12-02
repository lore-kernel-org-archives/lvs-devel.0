From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] ipvs: initialize 'ret' variable in do_ip_vs_set_ctl()
Date: Fri, 2 Dec 2022 13:07:02 +0300
Message-ID: <Y4nORiViTw0XlU2a@kadam>
References: <20221202032511.1435-1-liqiong@nfschina.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=lAa3hJppo/WCjU0fQNZHE/GMES32D4NEtcCS38fhV6k=;
        b=M8AhBwVKSD2KcvVRm4IPXCoeG36NL36s7PzGMw96pQhs2Dsz4R4OuRRymRuNv9mzvp
         KKAUal+dFEej+AQhzflGTMmXHhfp1acwf+6ljGPEkyIop81lycMM/hn8PEkKpUkBVr3u
         ZfWXtdXfe+DjFY1h5J7V9FX48K7ruRpPqnSijNoXNStM/QTbk63WlbmxgcQa3BqMVN1x
         q9aLDz2Cecdwb6C8IPEdwcf+xd4BHQgQOfdiol4Ji4SDrAa5nP+DAO3XNWxosU15LPVq
         gZRC2CCVg9p2icsaJT6cbqwPJDM+Gsy244qsmWN0f7l48cEQjG+ItkHB0Ga02Wu/ix/k
         KQRg==
Content-Disposition: inline
In-Reply-To: <20221202032511.1435-1-liqiong@nfschina.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li Qiong <liqiong@nfschina.com>, Peilin Ye <yepeilin.cs@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>

On Fri, Dec 02, 2022 at 11:25:11AM +0800, Li Qiong wrote:
> The 'ret' should need to be initialized to 0, in case
> return a uninitialized value because no default process
> for "switch (cmd)".
> 
> Signed-off-by: Li Qiong <liqiong@nfschina.com>

If this is a real bug, then it needs a fixes tag.  The fixes tag helps
us know whether to back port or not and it also helps in reviewing the
patch.  Also get_maintainer.pl will CC the person who introduced the
bug so they can review it.  They are normally the best person to review
their own code.

Here it would be:
Fixes: c5a8a8498eed ("ipvs: Fix uninit-value in do_ip_vs_set_ctl()")

Which is strange...  Also it suggest that the correct value is -EINVAL
and not 0.

The thing about uninitialized variable bugs is that Smatch and Clang
both warn about them so they tend to get reported pretty quick.
Apparently neither Nathan nor I sent forwarded this static checker
warning.  :/

regards,
dan carpenter
