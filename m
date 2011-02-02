From: Simon Horman <horms@verge.net.au>
Subject: Re: [GIT PULL nf-next-2.6] IPVS build fixes and clean-ups
Date: Thu, 3 Feb 2011 06:39:07 +0900
Message-ID: <20110202213907.GI2248@verge.net.au>
References: <1296519255-10602-1-git-send-email-horms@verge.net.au>
 <20110131165009.66999952.randy.dunlap@oracle.com>
 <20110201040634.GA2351@verge.net.au>
 <20110201100421.GA13325@verge.net.au>
 <4D483D6E.5070007@oracle.com>
 <4D4840BC.4050303@trash.net>
Mime-Version: 1.0
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D4840BC.4050303@trash.net>
Sender: linux-next-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Hans Schillstrom <hans@schillstrom.com>

On Tue, Feb 01, 2011 at 06:19:56PM +0100, Patrick McHardy wrote:
> Am 01.02.2011 18:05, schrieb Randy Dunlap:
> > On 02/01/11 02:04, Simon Horman wrote:
> >> On Tue, Feb 01, 2011 at 03:06:37PM +1100, Simon Horman wrote:
> >>> On Mon, Jan 31, 2011 at 04:50:09PM -0800, Randy Dunlap wrote:
> >>>> On Tue,  1 Feb 2011 11:14:11 +1100 Simon Horman wrote:
> >>>>
> >>>>> Hi,
> >>>>>
> >>>>> This short patch series addresses two linux-next build problems
> >>>>> raised by Randy Dunlap:
> >>>>>
> >>>>> * net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
> >>>>> * ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko]
> >>>>>   ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
> >>>>>
> >>>>> The remainder of the changset is cleanups that I noticed along the way.
> >>>>
> >>>> These 4 patches build successfully for me.
> >>>> However, I do see these warnings (sorry I missed them earlier):
> >>>>
> >>>> WARNING: net/netfilter/ipvs/ip_vs.o(.init.text+0x161): Section mismatch in reference from the function init_module() to the function .exit.text:ip_vs_sync_cleanup()
> >>>> WARNING: net/netfilter/ipvs/ip_vs.o(.init.text+0x161): Section mismatch in reference from the function init_module() to the function .exit.text:ip_vs_sync_cleanup()
> >>>
> >>> Thanks, I'll look into that. I will be travelling for a good portion of the
> >>> next day and a bit so I apologise in advance if that delays my next patch.
> >>
> >> Hi,
> >>
> >> I the following patch seems to be the right fix for this to me.
> >> I will send an amended pull request.
> >>
> >> IPVS: Remove ip_vs_sync_cleanup from section __exit
> >>
> >> ip_vs_sync_cleanup() may be called from ip_vs_init() on error
> >> and thus needs to be accesible from section __init
> >>
> >> Reporte-by: Randy Dunlap <randy.dunlap@oracle.com>
> >   Reported-by:
> > 
> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Thanks, since Simon is travelling, I'll apply the patches now
> with your and Hans's Acks and will push them to Dave later.

Thanks, I've finished travelling now :-)
