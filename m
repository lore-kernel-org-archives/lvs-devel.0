From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 1/6] ipvs: properly dereference dest_dst in
 ip_vs_forget_dev
Date: Fri, 19 Apr 2013 08:54:09 +0900
Message-ID: <20130418235409.GC9717@verge.net.au>
References: <1366231850-22188-1-git-send-email-ja@ssi.bg>
 <1366231850-22188-2-git-send-email-ja@ssi.bg>
 <20130418114532.GB11486@verge.net.au>
 <alpine.LFD.2.00.1304182225120.1842@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1304182225120.1842@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Thu, Apr 18, 2013 at 10:30:53PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 18 Apr 2013, Simon Horman wrote:
> 
> > On Wed, Apr 17, 2013 at 11:50:45PM +0300, Julian Anastasov wrote:
> > > 	Use rcu_dereference_protected to resolve
> > > sparse warning, found by kbuild test robot:
> > > 
> > > net/netfilter/ipvs/ip_vs_ctl.c:1464:35: warning: dereference of
> > > noderef expression
> > > 
> > > 	Problem from commit 026ace060dfe29
> > > ("ipvs: optimize dst usage for real server")
> > 
> > Thanks, this looks reasonable to me.
> > I have queued it up in ipvs-next.
> > 
> > BTW, Pablo asked previously for patches not to have
> > leading spaces at the beginning of paragraph's in the changelog.
> > I can will fix this, but it would be helpful to me if you
> > could update your chagelog style.
> 
> 	I was not aware, no problem to follow the new style :)

Thanks.
