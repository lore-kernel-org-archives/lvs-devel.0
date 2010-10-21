From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 00/12] ipvs: changes for local server and local client
Date: Thu, 21 Oct 2010 23:20:02 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010212304240.2196@ja.ssi.bg>
References: <alpine.LFD.2.00.1010171607550.20665@ja.ssi.bg> <alpine.LFD.2.00.1010182259500.1763@ja.ssi.bg> <20101021092114.GA11154@verge.net.au> <201010211509.42629.hans.schillstrom@ericsson.com> <20101021143652.GB21739@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021143652.GB21739@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>


 	Hello,

On Thu, 21 Oct 2010, Simon Horman wrote:

>>>>> I can help you with some IPv6 testing this week.
>>>>
>>>> 	Thanks in advance
>>>>
>>>>> I would be nice to change the IPv6 address print format from %pI6 to %pI6c to get a more compact debug output.
>>>>
>>>> 	Yes, may be in following cleanup patches because the
>>>> IPVS debugging needs improvement.
>>>
>>> Hi,
>>>
>>> I am happy with this series.
>>> Do either of you have any objections in me sending
>>> it to Patrick for merging. The merge window is now open,
>>> but hopefully we can still get this into 2.6.37-rc1 if we move quickly.
>>>
>> Hi,
>> I'm also happy with it, a basic sanity check for IPv6 performed
>
> Thanks, I have sent a pull request to Patrick which includes these changes.

 	Thanks to Hans for testing the IPv6 part and to you
for sending all 12+1 patches! I'm too slow today :)

Regards

--
Julian Anastasov <ja@ssi.bg>
