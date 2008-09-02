From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 00/00] Add first IPv6 support to IPVS
Date: Tue, 2 Sep 2008 18:18:42 +1000
Message-ID: <20080902081841.GM13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:55:57PM +0200, Julius Volz wrote:
> I now managed to rework the IPVS IPv6 patches in a way that the kernel
> builds after each patch in the series. Sometimes, this adds some
> ugliness in the form of temporary constructs which are introduced in one
> patch and deleted in the next ones. I've also integrated other small bug
> fixes and cleanups from comments on the mailing lists.

Thanks, I appreciate that. I think that these patches are starting
to look quite nice. I've posted some coments (all relating to style I
think) to some of the patches. Nothing else has caught my eye so far.

> Note: these patches are not based on net-2.6 anymore, but on lvs-2.6:

I've verified that these patches apply against the lvs-next-2.6 branch of
of the lvs-2.6 tree. Which means they should also apply against Dave's
net-next-2.6 tree (net-next-2.6 and lvs-next-2.6 are currently converged).
Which would seem to be the most likely target for these changes at this
time.

> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git
> 
> - Full kernel patch in one file:
>   http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6_v2.patch
> 
> While not all IPv6 features are working or tested, existing IPv4 features
> should still work as before. However, to use any of the new features, you
> will need a new ipvsadm with support for genetlink and IPv6:

I'm comfortable with merging things in that state.

It seems quite reasonable to add IPv6 features in an iterative
manner so long as IPv4 keeps working.

>   http://sixpak.org/vince/google/ipvsadm/
>   (by Vince Busam)
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
> - probably some incorrect handling of ICMPv6 or other corner cases
> 
> Since fragmentation and extension headers should not occur very often,
> things should "mostly" work. I tested HTTP and DNS over NAT and DR
> with various supported schedulers without encountering any problems.
> But we didn't test any exotic situations. Also, there are some TODOs
> in the code for things that haven't been tested or implemented yet.
> 
> Thanks for any comments!
> 
> Julius
