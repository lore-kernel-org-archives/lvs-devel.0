From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH 2/3] ipvs: Fix faulty IPv6 extension header 
	handling in IPVS
Date: Mon, 27 Aug 2012 12:55:14 +0200 (CEST)
Message-ID: <mdaatbj.ca5ac4e44d852a03ede087a5ed658cd9@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

>
>On Mon, 20 Aug 2012, Jesper Dangaard Brouer wrote:
>
>> Based on patch from: Hans Schillstrom
>>
>> IPv6 headers must be processed in order of appearance,
>> neither can it be assumed that Upper layer headers is first.
>> If anything else than L4 is the first header IPVS will throw it.
>>
>> IPVS will write SNAT & DNAT modifications at a fixed pos which
>> will corrupt the message. Proper header position must be found
>> before writing modifying packet.
>>
>> This patch contains a lot of API changes.  This is done, to avoid
>> the costly scan of finding the IPv6 headers, via ipv6_find_hdr().
>> Finding the IPv6 headers is done as early as possible, and passed
>> on as a pointer "struct ip_vs_iphdr *" to the affected functions.
>
>How about we change netfilter to set up the skb's transport header
>at an early time so we can avoid all (most of) these header scans
>in netfilter?

I think that would be great, maybe it should be global i.e. not only a netfilter issue.

