From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 0/2] Changes for PMTU Discovery
Date: Mon, 23 Jul 2012 16:59:49 +0900
Message-ID: <20120723075949.GB9371@verge.net.au>
References: <1342774793-29234-1-git-send-email-ja@ssi.bg>
 <20120723064609.GJ6603@verge.net.au>
 <alpine.LFD.2.00.1207231029160.1626@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1207231029160.1626@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

On Mon, Jul 23, 2012 at 10:33:24AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 23 Jul 2012, Simon Horman wrote:
> 
> > On Fri, Jul 20, 2012 at 11:59:51AM +0300, Julian Anastasov wrote:
> > > 	This patchset implements PMTU Discovery for TUN
> > > packets and option to disable it.
> > > 
> > > Julian Anastasov (2):
> > >   ipvs: implement passive PMTUD for IPIP packets
> > >   ipvs: add pmtu_disc option to disable IP DF for TUN packets
> > > 
> > >  include/net/ip_vs.h             |   11 +++++
> > >  net/netfilter/ipvs/ip_vs_core.c |   76 ++++++++++++++++++++++++++++++++++-
> > >  net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++
> > >  net/netfilter/ipvs/ip_vs_xmit.c |   83 ++++++++++++++++++++++++++------------
> > >  4 files changed, 149 insertions(+), 29 deletions(-)
> > 
> > Thanks, I have applied these to ipvs-next.
> > 
> > There were some offsets when applying the patches
> > and a conflict in the last hunk of ip_vs_xmit.c (in the first patch).
> > Could you check to make sure everything went in ok?
> 
> 	I created it for net-next on the same day because
> I saw this problem. Both patches apply even on net-next from
> today. May be ipvs-next is outdated, net-next changes rapidly
> last days. If you want to push these patches in this merge
> window you have to update ipvs-next. If it is not possible
> I'll resend after 2 weeks.

ipvs-next is based on Pablo's nf-next tree.
So the timing of updating is up to him.
