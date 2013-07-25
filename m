From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/sctp: Refactor SCTP skb checksum
 computation
Date: Wed, 24 Jul 2013 23:15:22 -0700 (PDT)
Message-ID: <20130724.231522.347956000482833125.davem@davemloft.net>
References: <1374717125-28969-1-git-send-email-joe@wand.net.nz>
	<alpine.LFD.2.00.1307250804180.1718@ja.ssi.bg>
	<20130725052437.GB25854@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130725052437.GB25854@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: horms@verge.net.au
Cc: ja@ssi.bg, joe@wand.net.nz, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, pablo@netfilter.org, jesse@nicira.com

From: Simon Horman <horms@verge.net.au>
Date: Thu, 25 Jul 2013 14:24:38 +0900

> On Thu, Jul 25, 2013 at 08:08:11AM +0300, Julian Anastasov wrote:
>> 
>> 	Hello,
>> 
>> On Thu, 25 Jul 2013, Joe Stringer wrote:
>> 
>> > This patch consolidates the SCTP checksum calculation code from various
>> > places to a single new function, sctp_compute_cksum(skb, offset).
>> > 
>> > Signed-off-by: Joe Stringer <joe@wand.net.nz>
>> > ---
>> > v2:
>> > * Use skb->data + offset for start position of checksum calculation
>> > * Fix existing bug in sctp_csum_check() where the incorrect offset was used
>> > * Remove redundant variable in sctp_nat_csum()
>> 
>> 	v2 looks good to me, thanks!
>> 
>> Reviewed-by: Julian Anastasov <ja@ssi.bg>
> 
> IPVS portion:
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Dave, could you consider taking this through net-next?

Sure.
