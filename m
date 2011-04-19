From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH][ldirectord] fix a bug that IPv6 does not work fine.
Date: Tue, 19 Apr 2011 09:11:11 +0900
Message-ID: <20110419001111.GG12611@verge.net.au>
References: <20110418.193014.310077122.sohgo@sohgo.dyndns.org>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110418.193014.310077122.sohgo@sohgo.dyndns.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Cc: lvs-devel@vger.kernel.org

On Mon, Apr 18, 2011 at 07:30:14PM +0900, Sohgo Takeuchi wrote:
> 
> 
> Hi,
> 
> I found that the latest ldirectord did not work fine when using IPv6.
> This issue was enbuged in following commits,
> 	commit f9c76a0f1d6e7c86ac741ed534c6661e22556fc2
> 	commit f85bdc302541aab3e32994b0d672e60a338a17c8
> i.e. when added fixes to allow IPv4 and IPv6 services with same fwmark.
> The fixes made same fwmark work good, but broke a behavior of IPv6
> services. When I made the fix, my testing was not enough.
> 
> Attached patch fixes this problem.
> This patch can also be found at https://github.com/sohgo/resource-agents/tree/bugfix-fwmk1

Thanks, applied to
git://github.com/horms/resource-agents.git
and pull request sent.

BTW, I pulled
https://github.com/sohgo/resource-agents.git heads/bugfix-fwmk1
in order to get the change.
