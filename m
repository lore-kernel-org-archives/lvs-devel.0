From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] GSO: Questions for IPVS and GSO for IPv6
Date: Tue, 29 Jul 2014 15:43:08 -0700 (PDT)
Message-ID: <20140729.154308.1799295794320740648.davem@davemloft.net>
References: <alpine.LFD.2.11.1407270957400.2036@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1407270957400.2036@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: netdev@vger.kernel.org, agartrell@fb.com, lvs-devel@vger.kernel.org, Kernel-team@fb.com, edumazet@google.com

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 27 Jul 2014 10:21:17 +0300 (EEST)

> 	Questions not related to IPVS:
> 
> - I guess ipv6_gro_receive() does not support GRO for
> IPPROTO_IPV6 in IPPROTO_IPV6 because IPPROTO_IPV6 is not
> registered in inet6_offloads list?

Correct.  SIT works because we register an "ipv4" offload for protocol
ipv6.

You'll need to add an inet6 offload, but I am not sure whether you can
just reuse the SIT skb gso flag, you might need to add a new onw.

Eric would know better, he added the SIT code, CC:'d
