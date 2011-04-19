From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: Re: [PATCH][ldirectord] fix a bug that IPv6 does not work fine.
Date: Tue, 19 Apr 2011 12:29:44 +0900 (JST)
Message-ID: <20110419.122944.424258809.sohgo@sohgo.dyndns.org>
References: <20110418.193014.310077122.sohgo@sohgo.dyndns.org>
	<20110419001111.GG12611@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20110419001111.GG12611@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: lvs-devel@vger.kernel.org


From: Simon Horman <horms@verge.net.au>
|
> On Mon, Apr 18, 2011 at 07:30:14PM +0900, Sohgo Takeuchi wrote:
>
>> I found that the latest ldirectord did not work fine when using IPv6.
>> This issue was enbuged in following commits,
>> 	commit f9c76a0f1d6e7c86ac741ed534c6661e22556fc2
>> 	commit f85bdc302541aab3e32994b0d672e60a338a17c8
>> i.e. when added fixes to allow IPv4 and IPv6 services with same fwmark.
>> The fixes made same fwmark work good, but broke a behavior of IPv6
>> services. When I made the fix, my testing was not enough.
>> 
>> Attached patch fixes this problem.
>> This patch can also be found at https://github.com/sohgo/resource-agents/tree/bugfix-fwmk1
> 
> Thanks, applied to
> git://github.com/horms/resource-agents.git
> and pull request sent.
> 
> BTW, I pulled
> https://github.com/sohgo/resource-agents.git heads/bugfix-fwmk1
> in order to get the change.

Hi, Simon

Thanks for accepting my patch and sending a pull request.

-- sohgo
