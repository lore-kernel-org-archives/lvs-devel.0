From: Simon Horman <horms@verge.net.au>
Subject: Re: multiple local nodes (patch)
Date: Wed, 24 Dec 2008 14:58:23 +1100
Message-ID: <20081224035821.GA31149@verge.net.au>
References: <20081208214012.GP30076@vps.drown.org> <20081224035118.GC28817@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224035118.GC28817@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Daniel Drown <dan-lvs@drown.org>
Cc: lvs-devel@vger.kernel.org

On Wed, Dec 24, 2008 at 02:51:18PM +1100, Simon Horman wrote:
> On Mon, Dec 08, 2008 at 09:40:12PM +0000, Daniel Drown wrote:
> > I have a need for multiple local nodes in LVS.  I started from the patch from
> > 2005:
> > http://archive.linuxvirtualserver.org/html/lvs-users/2005-06/msg00113.html
> > 
> > I found three problems with it:
> > 1. packet checksums were not calculated correctly
> > 2. having stats enabled would deadlock the kernel in the stats update function
> > 	(ip_vs_in_stats/ip_vs_out_stats)
> > 3. the kernel would deadlock in the packet recieve function (ip_vs_in)
> > 
> > For #1, I believe this was because the existing code assumes the TCP/UDP
> > checksums are correct (which is not true for locally generated packets with
> > hardware checksum).  I just used the same code that the tcp and udp functions
> > use.
> > 
> > For #2 and #3, the problem was that the majority of the code runs as a bottom
> > handler.  Locally generated packets are run as a normal kernel context.  If a
> > network interrupt happens while the kernel is holding a IPVS lock for sending
> > a local packet, it can schedule the bottom handler.  The bottom handler can
> > then try to acquire the same lock, and this is a deadlock.  To prevent this
> > from happening, I've disabled bottom handlers (local_bh_disable) in the local
> > packet output function I created (ip_vs_out_nobh).
> > 
> > I've tested this and it works on a RH5/CentOS5 2.6.18.92.1.17.el5 kernel:
> > http://dan.drown.org/software/ipvs-2.6.18-92.1.17.el5-multiple-local-nodes.patch
> > 
> > I've ported it to a stock 2.6.27.7 kernel, but I haven't had time to test it
> > out yet:
> > http://dan.drown.org/software/ipvs-2.6.27.7-multiple-local-nodes.patch
> > 
> > I welcome any comments or criticism on the code.
> 
> Hi Daniel,
> 
> sorry to take so long to respond, I have been meaning to do so.
> 
> Your patch seems good to me (though I am somewhat biases as I wrote
> the patch you based your patch on). Would it be possible for you to
> 
> a) update the code to either DaveM's net-next-2.6 tree on git.kernel.org,
>    or at the very least one of the 2.6.29-rc releases? In particular

     Sorry, that should be one of the 2.6.28-rc releases.

>    please note that the lvs code has moved from net/ipv4/ipvs/ to
>    net/netfilter/ipvs/ . Also, I think that you will need to rework
>    your checksum code changes a little to accomodate IPv6, which
>    has been merged into IPVS recently.
> 
> b) Provide a Signed-off-by line, an explanation of which can be found at
>    http://linux.yyz.us/patch-format.html
> 
> -- 
> Simon Horman
>   VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
>   H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en
> 

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

