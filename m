From: "dust.li" <dust.li@linux.alibaba.com>
Subject: Re: Long delay on estimation_timer causes packet latency
Date: Thu, 3 Dec 2020 14:42:24 +0800
Message-ID: <d89672f8-a028-8690-0e6a-517631134ef6@linux.alibaba.com>
References: <D25792C1-1B89-45DE-9F10-EC350DC04ADC@gmail.com>
 <alpine.LFD.2.21.2004171029240.3962@ja.home.ssi.bg>
 <F48099A3-ECB3-46AF-8330-B829ED2ADA3F@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <F48099A3-ECB3-46AF-8330-B829ED2ADA3F@gmail.com>
Content-Language: en-US
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"; format="flowed"
To: yunhong-cgl jiang <xintian1976@gmail.com>, Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Yunhong Jiang <yunhjiang@ebay.com>

Hi Yunhong & Julian, any updates ?


We've encountered the same problem. With lots of ipvs

services plus many CPUs, it's easy to reproduce this issue.

I have a simple script to reproduce:

First add many ipvs services:

for((i=0;i<50000;i++)); do
         ipvsadm -A -t 10.10.10.10:$((2000+$i))
done


Then, check the latency of estimation_timer() using bpftrace:

#!/usr/bin/bpftrace

kprobe:estimation_timer {
         @enter = nsecs;
}

kretprobe:estimation_timer {
         $exit = nsecs;
         printf("latency: %ld us\n", (nsecs - @enter)/1000);
}

I observed about 268ms delay on my 104 CPUs test server.

Attaching 2 probes...
latency: 268807 us
latency: 268519 us
latency: 269263 us


And I tried moving estimation_timer() into a delayed

workqueue, this do make things better. But since the

estimation won't give up CPU, it can run for pretty

long without scheduling on a server which don't have

preempt enabled, so tasks on that CPU can't get executed

during that period.


Since the estimation repeated every 2s, we can't call

cond_resched() to give up CPU in the middle of iterating the

est_list, or the estimation will be quite inaccurate.

Besides the est_list needs to be protected.


I haven't found any ideal solution yet, currently, we just

moved the estimation into kworker and add sysctl to allow

us to disable the estimation, since we don't need the

estimation anyway.


Our patches is pretty simple now, if you think it's useful,

I can paste them


Do you guys have any suggestions or solutions ?


Thanks a lot !

Dust



On 4/18/20 12:56 AM, yunhong-cgl jiang wrote:
> Thanks for reply.
>
> Yes, our patch changes the est_list to a RCU list. Will do more testing and send out the patch.
>
> Thanks
> —Yunhong
>
>
>> On Apr 17, 2020, at 12:47 AM, Julian Anastasov <ja@ssi.bg> wrote:
>>
>>
>> 	Hello,
>>
>> On Thu, 16 Apr 2020, yunhong-cgl jiang wrote:
>>
>>> Hi, Simon & Julian,
>>> 	We noticed that on our kubernetes node utilizing IPVS, the estimation_timer() takes very long (>200sm as shown below). Such long delay on timer softirq causes long packet latency.
>>>
>>>           <idle>-0     [007] dNH. 25652945.670814: softirq_raise: vec=1 [action=TIMER]
>>> .....
>>>           <idle>-0     [007] .Ns. 25652945.992273: softirq_exit: vec=1 [action=TIMER]
>>>
>>> 	The long latency is caused by the big service number (>50k) and large CPU number (>80 CPUs),
>>>
>>> 	We tried to move the timer function into a kernel thread so that it will not block the system and seems solves our problem. Is this the right direction? If yes, we will do more testing and send out the RFC patch. If not, can you give us some suggestion?
>> 	Using kernel thread is a good idea. For this to work, we can
>> also remove the est_lock and to use RCU for est_list.
>> The writers ip_vs_start_estimator() and ip_vs_stop_estimator() already
>> run under common mutex __ip_vs_mutex, so they not need any
>> synchronization. We need _bh lock usage in estimation_timer().
>> Let me know if you need any help with the patch.
>>
>> Regards
>>
>> --
>> Julian Anastasov <ja@ssi.bg>
