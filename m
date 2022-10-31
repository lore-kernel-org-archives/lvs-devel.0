From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net,v2 0/2] fix WARNING when removing file in ipvs
Date: Mon, 31 Oct 2022 17:05:02 +0200 (EET)
Message-ID: <9dfd739c-f7b-e758-9b46-f79ba9cec82@ssi.bg>
References: <20221031120705.230059-1-shaozhengchao@huawei.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20221031120705.230059-1-shaozhengchao@huawei.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zhengchao Shao <shaozhengchao@huawei.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Simon Horman <horms@verge.net.au>, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, weiyongjun1@huawei.com, yuehaibing@huawei.com


	Hello,

On Mon, 31 Oct 2022, Zhengchao Shao wrote:

> When using strace for fault injection, some warnings are trigged when
> files are removed. This is because the file fails to be created during
> the initialization, but the initialization continues normally. Therefore,
> a WARNING is reported when the file is removed during the exit.
> 
> ---
> v2: add macro isolation
> ---
> Zhengchao Shao (2):
>   ipvs: fix WARNING in __ip_vs_cleanup_batch()
>   ipvs: fix WARNING in ip_vs_app_net_cleanup()

	Both patches in v2 look good to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

>  net/netfilter/ipvs/ip_vs_app.c  | 10 ++++++++--
>  net/netfilter/ipvs/ip_vs_conn.c | 26 +++++++++++++++++++++-----
>  2 files changed, 29 insertions(+), 7 deletions(-)
> 
> -- 
> 2.17.1

Regards

--
Julian Anastasov <ja@ssi.bg>

