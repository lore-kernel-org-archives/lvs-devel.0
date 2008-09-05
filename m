From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv3 00/24] Add first IPv6 support to IPVS
Date: Fri, 5 Sep 2008 11:25:55 +1000
Message-ID: <20080905012554.GC14128@verge.net.au>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Tue, Sep 02, 2008 at 03:55:31PM +0200, Julius Volz wrote:
> Hi Horms,
> 
> Here comes the whole batch again! I've fixed almost all style issues
> reported by checkpatch.pl, except for some little things which look like
> they could stay like they are for now (down to 3 warnings and 2 errors).
> I also integrated your other comments and removed the patch that
> adds the changelog information (not needed anymore, according to
> Stephen).
> 
> These patches are based on lvs-2.6:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git
> 
> - Full kernel patch in one file:
>   http://www-user.tu-chemnitz.de/~volz/ipvs_ipv6/ipvs_ipv6_v3.patch
> 
> While not all IPv6 features are working or tested, existing IPv4 features
> should still work as before. However, to use any of the new features, you
> will need a new ipvsadm with support for genetlink and IPv6:
> 
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

Hi Julius, Hi Vince,

I have applied all of these patches to the lvs-next-2.6 branch
of the lvs-2.6 tree and I will ask Dave to pull these into
net-next-2.6 shortly.

git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-2.6.git

