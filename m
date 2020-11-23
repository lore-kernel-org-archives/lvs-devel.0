From: "wanghai (M)" <wanghai38@huawei.com>
Subject: Re: [PATCH net v2] ipvs: fix possible memory leak in
 ip_vs_control_net_init
Date: Mon, 23 Nov 2020 22:49:10 +0800
Message-ID: <66825441-bb06-3d18-0424-df355d596c5f@huawei.com>
References: <20201120082610.60917-1-wanghai38@huawei.com>
 <21af4c92-8ca6-cce9-64bc-c4e88b6d1e8a@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <21af4c92-8ca6-cce9-64bc-c4e88b6d1e8a@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, pablo@netfilter.org, christian@brauner.io, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org


=D4=DA 2020/11/22 19:20, Julian Anastasov =D0=B4=B5=C0:
> 	Hello,
>
> On Fri, 20 Nov 2020, Wang Hai wrote:
>
>> kmemleak report a memory leak as follows:
>>
>> BUG: memory leak
>> unreferenced object 0xffff8880759ea000 (size 256):
>> comm "syz-executor.3", pid 6484, jiffies 4297476946 (age 48.546s)
[...]
>>
>> Fixes: b17fc9963f83 ("IPVS: netns, ip_vs_stats and its procfs")
>> Fixes: 61b1ab4583e2 ("IPVS: netns, add basic init per netns.")
>> Reported-by: Hulk Robot <hulkci@huawei.com>
>> Signed-off-by: Wang Hai <wanghai38@huawei.com>
>> ---
[...]
>>  =20
>> -	proc_create_net("ip_vs", 0, ipvs->net->proc_net, &ip_vs_info_seq_ops,
>> -			sizeof(struct ip_vs_iter));
>> -	proc_create_net_single("ip_vs_stats", 0, ipvs->net->proc_net,
>> -			ip_vs_stats_show, NULL);
>> -	proc_create_net_single("ip_vs_stats_percpu", 0, ipvs->net->proc_net,
>> -			ip_vs_stats_percpu_show, NULL);
>> +#ifdef CONFIG_PROC_FS
>> +	if (!proc_create_net("ip_vs", 0, ipvs->net->proc_net, &ip_vs_info_seq_=
ops,
>> +			sizeof(struct ip_vs_iter)))
>> +		goto err_vs;
>> +	if (!proc_create_net_single("ip_vs_stats", 0, ipvs->net->proc_net,
>> +			ip_vs_stats_show, NULL))
>> +		goto err_stats;
>> +	if (!proc_create_net_single("ip_vs_stats_percpu", 0, ipvs->net->proc_n=
et,
>> +			ip_vs_stats_percpu_show, NULL))
>> +		goto err_percpu;
> 	Make sure the parameters are properly aligned to function open
> parenthesis without exceeding 80 columns:
>
> linux# scripts/checkpatch.pl --strict /tmp/file.patch
Thanks, I'll perfect it.
> 	It was true only for first call due to some
> renames for the others two in commit 3617d9496cd9 :(
It does indeed rename in commit 3617d9496cd9.
But I don't understand what's wrong with my patch here.
>> +#endif
>>  =20
>>   	if (ip_vs_control_net_init_sysctl(ipvs))
>>   		goto err;
>> @@ -4180,6 +4185,14 @@ int __net_init ip_vs_control_net_init(struct netn=
s_ipvs *ipvs)
>>   	return 0;
>>  =20
>>   err:
>> +#ifdef CONFIG_PROC_FS
>> +	remove_proc_entry("ip_vs_stats_percpu", ipvs->net->proc_net);
> 	It should look better with an empty line before
> the 3 new labels.
Thanks, I'll perfect it.
>> +err_percpu:
[...]
>>   	remove_proc_entry("ip_vs_stats", ipvs->net->proc_net);
>>   	remove_proc_entry("ip_vs", ipvs->net->proc_net);
>> +#endif
>>   	free_percpu(ipvs->tot_stats.cpustats);
>>   }
>>  =20
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>
> .
>
