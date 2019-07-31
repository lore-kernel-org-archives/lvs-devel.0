From: hujunwei <hujunwei4@huawei.com>
Subject: Re: [PATCH net v2] ipvs: Improve robustness to the ipvs sysctl
Date: Wed, 31 Jul 2019 23:58:49 +0800
Message-ID: <484fef63-710a-701e-3151-eefaf3b9b1ca@huawei.com>
References: <1997375e-815d-137f-20c9-0829a8587ee9@huawei.com>
 <4a0476d3-57a4-50e0-cae8-9dffc4f4d556@huawei.com>
 <alpine.LFD.2.21.1907302226340.4897@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.21.1907302226340.4897@ja.home.ssi.bg>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@blackhole.kfki.hu, Florian Westphal <fw@strlen.de>, davem@davemloft.net, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Mingfangsen <mingfangsen@huawei.com>, wangxiaogang3@huawei.com, xuhanbing@huawei.com

Hello, Julian

On 2019/7/31 3:29, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 30 Jul 2019, hujunwei wrote:
> 
>> From: Junwei Hu <hujunwei4@huawei.com>
>>
>> The ipvs module parse the user buffer and save it to sysctl,
>> then check if the value is valid. invalid value occurs
>> over a period of time.
>> Here, I add a variable, struct ctl_table tmp, used to read
>> the value from the user buffer, and save only when it is valid.
>> I delete proc_do_sync_mode and use extra1/2 in table for the
>> proc_dointvec_minmax call.
>>
>> Fixes: f73181c8288f ("ipvs: add support for sync threads")
>> Signed-off-by: Junwei Hu <hujunwei4@huawei.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	BTW, why ip_vs_zero_all everywhere? Due to old git version?
> 

I will update the git version and send the patch v3.

Regards,
Junwei

