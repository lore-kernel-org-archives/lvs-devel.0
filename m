From: liqiong <liqiong@nfschina.com>
Subject: Re: [PATCH] ipvs: initialize 'ret' variable in do_ip_vs_set_ctl()
Date: Fri, 2 Dec 2022 18:18:37 +0800
Message-ID: <9bc0af1a-3cf0-de4e-7073-0f7895b7f6eb@nfschina.com>
References: <20221202032511.1435-1-liqiong@nfschina.com>
 <Y4nORiViTw0XlU2a@kadam>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Y4nORiViTw0XlU2a@kadam>
Content-Language: en-US
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Dan Carpenter <error27@gmail.com>, Peilin Ye <yepeilin.cs@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, kernel-janitors@vger.kernel.org, coreteam@netfilter.org, Yu Zhe <yuzhe@nfschina.com>



在 2022年12月02日 18:07, Dan Carpenter 写道:
> On Fri, Dec 02, 2022 at 11:25:11AM +0800, Li Qiong wrote:
>> The 'ret' should need to be initialized to 0, in case
>> return a uninitialized value because no default process
>> for "switch (cmd)".
>>
>> Signed-off-by: Li Qiong <liqiong@nfschina.com>
> If this is a real bug, then it needs a fixes tag.  The fixes tag helps
> us know whether to back port or not and it also helps in reviewing the
> patch.  Also get_maintainer.pl will CC the person who introduced the
> bug so they can review it.  They are normally the best person to review
> their own code.
>
> Here it would be:
> Fixes: c5a8a8498eed ("ipvs: Fix uninit-value in do_ip_vs_set_ctl()")
>
> Which is strange...  Also it suggest that the correct value is -EINVAL
> and not 0.
>
> The thing about uninitialized variable bugs is that Smatch and Clang
> both warn about them so they tend to get reported pretty quick.
> Apparently neither Nathan nor I sent forwarded this static checker
> warning.  :/
>
> regards,
> dan carpenter

It is not a real bug,   I  use tool (eg: smatch, sparse) to audit the code,  got this warning and check it,
found may be a real problem.
