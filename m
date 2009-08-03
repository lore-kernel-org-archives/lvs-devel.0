From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] IPVS: use pr_err and friends instead of
 IP_VS_ERR and friends
Date: Sun, 02 Aug 2009 18:29:56 -0700 (PDT)
Message-ID: <20090802.182956.263159793.davem@davemloft.net>
References: <20090802210530.14843.62378.stgit@jazzy.zrh.corp.google.com>
	<20090803003658.GQ6177@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090803003658.GQ6177@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: heder@google.com, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, joe@perches.com, jengelh@medozas.de

From: Simon Horman <horms@verge.net.au>
Date: Mon, 3 Aug 2009 10:36:59 +1000

> On Sun, Aug 02, 2009 at 11:05:41PM +0200, Hannes Eder wrote:
>> Since pr_err and friends are used instead of printk there is no point
>> in keeping IP_VS_ERR and friends.  Furthermore make use of '__func__'
>> instead of hard coded function names.
>> 
>> Signed-off-by: Hannes Eder <heder@google.com>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.

