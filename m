From: hujunwei <hujunwei4@huawei.com>
Subject: Re: Subject: [PATCH netfilter] ipvs: Fix crash when ipv6 route
 unreach
Date: Tue, 7 May 2019 23:41:14 +0800
Message-ID: <b761ba94-c902-1797-0465-edafe72dc1d3@huawei.com>
References: <f40bae44-a4b1-868c-3572-3e89c4cadb6a@huawei.com>
 <alpine.LFD.2.21.1905071009060.3512@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.21.1905071009060.3512@ja.home.ssi.bg>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: wensong@linux-vs.org, horms@verge.net.au, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, mingfangsen@huawei.com, wangxiaogang3@huawei.com, zhangwenhao8@huawei.com



On 2019/5/7 15:45, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 7 May 2019, hujunwei wrote:
> 
>> From: Junwei Hu <hujunwei4@huawei.com>
>>
>> When Tcp send RST packet in ipvs, crash occurs with the following
>> stack trace:
>>
>> BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
>> PID: 0 COMMAND: "swapper/2"
>> TASK: ffff9ec83889bf40  (1 of 4)  [THREAD_INFO: ffff9ec8388b0000]
>> CPU: 2  STATE: TASK_RUNNING (PANIC)
>>  [exception RIP: __ip_vs_get_out_rt_v6+1250]
>> RIP: ffffffffc0d566f2  RSP: ffff9ec83ed03c68  RFLAGS: 00010246
>> RAX: 0000000000000000  RBX: ffff9ec835e85000  RCX: 000000000005e1f9
>> RDX: 000000000005e1f8  RSI: 0000000000000200  RDI: ffff9ec83e801b00
>> RBP: ffff9ec83ed03cd8   R8: 000000000001bb40   R9: ffffffffc0d5673f
>> R10: ffff9ec83ed1bb40  R11: ffffe2d384d4fdc0  R12: ffff9ec7b7ad5900
>> R13: 0000000000000000  R14: 0000000000000007  R15: ffff9ec8353f7580
>> ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>>  [ffff9ec83ed03ce0] ip_vs_fnat_xmit_v6 at ffffffffc0d5b42c [ip_vs]
>>  [ffff9ec83ed03d70] tcp_send_rst_ipv6 at ffffffffc0d6542a [ip_vs]
>>  [ffff9ec83ed03df8] tcp_conn_expire_handler at ffffffffc0d65823 [ip_vs]
>>  [ffff9ec83ed03e20] ip_vs_conn_expire at ffffffffc0d42373 [ip_vs]
>>  [ffff9ec83ed03e70] call_timer_fn at ffffffffae0a6b58
>>  [ffff9ec83ed03ea8] run_timer_softirq at ffffffffae0a904d
>>  [ffff9ec83ed03f20] __do_softirq at ffffffffae09fa85
>>  [ffff9ec83ed03f90] call_softirq at ffffffffae739dac
>>  [ffff9ec83ed03fa8] do_softirq at ffffffffae02e62b
>>  [ffff9ec83ed03fc0] irq_exit at ffffffffae09fe25
>>  [ffff9ec83ed03fd8] smp_apic_timer_interrupt at ffffffffae73b158
>>  [ffff9ec83ed03ff0] apic_timer_interrupt at ffffffffae737872
>>
>> TCP connection timeout and send a RST packet, the skb is alloc
>> by alloc_skb, the pointer skb->dev and skb_dst(skb) is NULL,
>> however, ipv6 route unreach at that time, so go into err_unreach.
>> In err_unreach, crash occurs when skb->dev and skb_dst(skb) is NULL.
> 
> 	I guess, this is a modified IPVS module and the problem
> can not occur in mainline kernel. ip_vs_in() and ip_vs_out() already 
> have check for skb_dst(). May be you generate skb without attached
> route, so skb_dst is NULL. Also, note that decrement_ttl() has similar
> code.
> 

Hi Julian, thank you for replay.
We are developing based on IPVS module. That code seems less compatible,
i think it is meaningful to make the code robust.
All above just my advice.

Regards,
Junwei

