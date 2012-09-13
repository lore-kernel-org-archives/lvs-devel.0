From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [PATCH V3 0/8] ipvs: IPv6 fragment handling for 
	IPVS
Date: Thu, 13 Sep 2012 08:55:08 +0200 (CEST)
Message-ID: <ee5vnhe.0891bc4ff9e38f64c4c5c0da6c50af1c@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Hans Schillstrom <hans.schillstrom@ericsson.com>, netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, Thomas Graf <tgraf@suug.ch>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>

Hello
>
>Hello,
>
>On Tue, 11 Sep 2012, Jesper Dangaard Brouer wrote:
>
>> The following patchset implement IPv6 fragment handling for IPVS.
>> 
[snip]

>
>	I also see that we should not send ICMP
>errors (FRAG NEEDED/TOO BIG) in response to large
>ICMP error packets but it is not related to your changes,
>it needs separate change to all transmitters.

Just a curious question, have you seen such big ICMP packets in real life ?
(if you have normal MTU:s) 
 
Regards 
Hans

