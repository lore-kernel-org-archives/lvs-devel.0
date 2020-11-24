From: "wanghai (M)" <wanghai38@huawei.com>
Subject: Re: [PATCH net v2] ipvs: fix possible memory leak in
 ip_vs_control_net_init
Date: Tue, 24 Nov 2020 16:07:00 +0800
Message-ID: <506b722c-e049-eab1-3f19-f30473467fff@huawei.com>
References: <20201120082610.60917-1-wanghai38@huawei.com>
 <21af4c92-8ca6-cce9-64bc-c4e88b6d1e8a@ssi.bg>
 <66825441-bb06-3d18-0424-df355d596c5f@huawei.com>
 <9c409f4a-42df-1dd8-e69a-d5d3bab8d0c0@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <9c409f4a-42df-1dd8-e69a-d5d3bab8d0c0@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, pablo@netfilter.org, christian@brauner.io, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


在 2020/11/24 3:04, Julian Anastasov 写道:
> 	Hello,
>
> On Mon, 23 Nov 2020, wanghai (M) wrote:
>
>> 在 2020/11/22 19:20, Julian Anastasov 写道:
>>>   Hello,
>>>
>>> On Fri, 20 Nov 2020, Wang Hai wrote:
>>>
>>>> +	if (!proc_create_net_single("ip_vs_stats_percpu", 0,
>>>> ipvs->net->proc_net,
>>>> +			ip_vs_stats_percpu_show, NULL))
>>>> +		goto err_percpu;
>>> 	Make sure the parameters are properly aligned to function open
>>> parenthesis without exceeding 80 columns:
>>>
>>> linux# scripts/checkpatch.pl --strict /tmp/file.patch
>> Thanks, I'll perfect it.
>>> 	It was true only for first call due to some
>>> renames for the others two in commit 3617d9496cd9 :(
>> It does indeed rename in commit 3617d9496cd9.
>> But I don't understand what's wrong with my patch here.
> 	Visually, they should look like this:
>
>          if (!proc_create_net("ip_vs", 0, ipvs->net->proc_net,
>                               &ip_vs_info_seq_ops, sizeof(struct ip_vs_iter)))
>                  goto err_vs;
>          if (!proc_create_net_single("ip_vs_stats", 0, ipvs->net->proc_net,
>                                      ip_vs_stats_show, NULL))
>                  goto err_stats;
>          if (!proc_create_net_single("ip_vs_stats_percpu", 0,
>                                      ipvs->net->proc_net,
>                                      ip_vs_stats_percpu_show, NULL))
>                  goto err_percpu;

Thank you for your patient explanation, I got it.

I just sent v3

"[PATCH net v3] ipvs: fix possible memory leak in ip_vs_control_net_init"

> 	The first one explained:
>
> <1  TAB>if (!proc_create_net("ip_vs", 0, ipvs->net->proc_net,
> <  open parenthesis is here  ^ and all next lines align to first parameter>
> <1  TAB><1  TAB><1 TAB><5 SP>&ip_vs_info_seq_ops, sizeof(struct ip_vs_iter)))
> <1  TAB><1  TAB>goto err_vs;
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
