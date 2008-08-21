From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Thu, 21 Aug 2008 11:17:17 +1000
Message-ID: <20080821011715.GG19235@verge.net.au>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Aug 20, 2008 at 06:15:07PM +0200, Julius Volz wrote:
> Hi,
> 
> Ok, it might be the time to post these experimental IPv6 patches for IPVS
> again to get some comments and help. Since the last time, I've worked on
> reducing a lot of unnecessary code duplication, but some is still there
> where it was harder to get rid of. Also, we've implemented a genetlink
> interface (the first two patches in this series are exactly the v4
> version of that) and updated ipvsadm to work with it, so we do not have
> to break the existing sockopt userspace interface. Of course, there are
> also many other small fixes and changes since the last version.
> 
> - Full kernel patch in one file against davem's net-2.6:
> http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6.patch
> 
> While not all IPv6 features are working or tested, existing IPv4 features
> should still work as before. However, to use any of the new features, you
> will need a new ipvsadm with support for genetlink and IPv6:
> 
> http://sixpak.org/vince/google/ipvsadm/
> (by Vince Busam)
> 
> To enable IPv6 support in IPVS, set CONFIG_IP_VS_IPV6=y.
> 
> Short overview:
> 
> What works with IPv6:
> - forwarding mechanisms: NAT, DR, maybe Tunnel (not fully tested yet)
> - protocols: TCP, UDP, ESP, AH (last two not tested)
> - manipulation and inspection of both IPv4 and IPv6 entries with ipvsadm
> - 6 out of 10 schedulers
> 
> What is not supported with IPv6:
> - handling fragmentation or other extension headers
> - FTP application helper (can be loaded, but only operates on v4)
> - sync daemon (can be started, but only operates on v4)

Other than the packet format of the sync deamon, are there any
fundamental restrictions here? If we extended the sync daemon,
could it work? If so, perhaps we could rev the sync deamon protocol
and fix a few other kinks, like the handling of timeouts and the
general lack of extendability, at the same time.

> - probably some incorrect handling of ICMPv6 or other corner cases
> 
> Since fragmentation and extension headers should not occur very often,
> things should "mostly" work. I tested HTTP and DNS over NAT and DR
> with various supported schedulers without encountering any problems.
> But we didn't test any exotic situations. Also, there are some TODOs
> in the code for things that haven't been tested or implemented yet.
> 
> Thanks for any comments!

Unfortunately (or fortunately depending on how you look at it),
I'm going to be away skiing for the next couple of days. Apologies
for the slow responses that will lead to.

