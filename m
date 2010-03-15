From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/netfilter/ipvs/ip_vs_ftp.c: Remove use of NIPQUAD
Date: Mon, 15 Mar 2010 12:01:42 -0700 (PDT)
Message-ID: <20100315.120142.113006088.davem@davemloft.net>
References: <1268094699.1617.5.camel@Joe-Laptop.home>
	<4B9E5E43.9060206@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4B9E5E43.9060206@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: kaber@trash.net
Cc: joe@perches.com, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 15 Mar 2010 17:20:19 +0100

> Joe Perches wrote:
>> NIPQUAD has very few uses left.
>> 
>> Remove this use and make the code have the identical form of the only
>> other use of "%u,%u,%u,%u,%u,%u" in net/ipv4/netfilter/nf_nat_ftp.c
> 
> Are we trying to remove NIPQUAD?

Yes.

