From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/4] [patch nf-next v2] IPVS: ICMPv6 checksum
 calculation
Date: Thu, 26 Aug 2010 13:18:37 -0700 (PDT)
Message-ID: <20100826.131837.28801802.davem@davemloft.net>
References: <20100826125427.056491061@vergenet.net>
	<20100826125726.621600393@vergenet.net>
	<Pine.LNX.4.58.1008262234270.3055@u.domain.uli>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.1008262234270.3055@u.domain.uli>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, wensong@linux-vs.org, kaber@trash.net, tingsrain@gmail.com

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 26 Aug 2010 22:36:24 +0300 (EEST)

>> +	skb->csum_offset = offsetof(struct icmp6hdr, icmp6_cksum);
>>  	skb->ip_summed = CHECKSUM_UNNECESSARY;
> 
> 	Ops, this should be CHECKSUM_PARTIAL

I'll fix this up when I apply the patch.
