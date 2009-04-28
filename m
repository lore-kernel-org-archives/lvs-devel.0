From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [bug] FWMARKs and persistence in IPVS: The Use of Unions
Date: Tue, 28 Apr 2009 11:07:40 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0904281103250.27149@fbirervta.pbzchgretzou.qr>
References: <20090428081509.GA746@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090428081509.GA746@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>, lvs-devel@vger.kernel.org, =?UTF-8?Q?Fabien_Duch=C3=AAne?= <fabien.duchene@student.uclouvain.be>, Joseph Mack NA3T <jmack@wm7d.net>, Julius Volz <julius.volz@gmail.com>


On Tuesday 2009-04-28 10:15, Simon Horman wrote:
>
>It seems to me that it should be easy enough to fix by changing
>fwmark in ip_vs_sched_persist() from:
>
>union nf_inet_addr fwmark = {
>	.all = { 0, 0, 0, htonl(svc->fwmark) }
>};
>
>to:
>
>union nf_inet_addr fwmark = {
>	.all = { htonl(svc->fwmark), 0, 0, 0 }
>};
>
>Assuming that this would result in fwmark->ip being set to
>htonl(svc->fwmark), which is relevant if svc->af is AF_INET - that is,
>for IPv4.[...]
>An alternate idea would be to change the af value used for fwmarks,
>but this seems to be even less clean than the current (slightly broken)
>technique of using nf_inet_addr for IPv4 or IPv6 addresses, or fwmarks.

If you use ->all, then using NFPROTO_UNSPEC as af
seems to me like a good match.
