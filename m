From: linmiaohe <linmiaohe@huawei.com>
Subject: Re: [PATCH] ipvs:set sock send/receive buffer correctly
Date: Thu, 18 Apr 2019 10:17:32 +0800
Message-ID: <99e42cf0-bb45-cc88-a6f6-aff1098745dd@huawei.com>
References: <501e5522-1d69-7c67-a1bc-fd8502d3b5d1@huawei.com>
 <60c11e72-99eb-fcde-e130-a35ecdc1d2d1@gmail.com>
 <bbfcccf4-626b-1029-62a6-a82b79edacbb@huawei.com>
 <a8ed41f3-1576-cbf6-907a-f501b3df189e@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a8ed41f3-1576-cbf6-907a-f501b3df189e@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Eric Dumazet <eric.dumazet@gmail.com>, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org
Cc: Mingfangsen <mingfangsen@huawei.com>, liujie165@huawei.com



On 2019/4/18 10:02, Eric Dumazet wrote:
> 
> 
> On 04/17/2019 06:45 PM, linmiaohe wrote:
>>
> 
>> In fact, I just implemented this function with reference to
>> sock_setsockopt(). When val * 2 overflow, we will set the
>> buffer as SOCK_MIN_SNDBUF, just as sock_setsockopt() do.
>>
> 
> I do not think so.
> 
> Please check latest linux kernel, not some old version.
> 
> commit 4057765f2dee79cb92f9067909477303360be8d3    sock: consistent handling of extreme SO_SNDBUF/SO_RCVBUF values
> 
> .
> 

Thank you for your patience, you are right. My version is not the newest.
I will update my patch according to the newest version. Thanks again.

