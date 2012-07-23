From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] ipvs: ip_vs_ftp depends on nf_conntrack_ftp helper
Date: Mon, 23 Jul 2012 15:48:18 +0900
Message-ID: <20120723064818.GK6603@verge.net.au>
References: <1341966327-16606-1-git-send-email-horms@verge.net.au>
 <1341966327-16606-2-git-send-email-horms@verge.net.au>
 <20120712153937.GB18793@1984>
 <alpine.LFD.2.00.1207122238220.1831@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1207122238220.1831@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Hans Schillstrom <hans.schillstrom@ericsson.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Thu, Jul 12, 2012 at 10:43:22PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 12 Jul 2012, Pablo Neira Ayuso wrote:
> 
> > On Wed, Jul 11, 2012 at 09:25:26AM +0900, Simon Horman wrote:
> > > From: Julian Anastasov <ja@ssi.bg>
> > > 
> > > 	The FTP application indirectly depends on the
> > > nf_conntrack_ftp helper for proper NAT support. If the
> > > module is not loaded, IPVS can resize the packets for the
> > > command connection, eg. PASV response but the SEQ adjustment
> > > logic in ipv4_confirm is not called without helper.
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > ---
> > >  net/netfilter/ipvs/Kconfig | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
> > > index f987138..8b2cffd 100644
> > > --- a/net/netfilter/ipvs/Kconfig
> > > +++ b/net/netfilter/ipvs/Kconfig
> > > @@ -250,7 +250,8 @@ comment 'IPVS application helper'
> > >  
> > >  config	IP_VS_FTP
> > >    	tristate "FTP protocol helper"
> > > -        depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT
> > > +	depends on IP_VS_PROTO_TCP && NF_CONNTRACK && NF_NAT && \
> > > +		NF_CONNTRACK_FTP
> > 
> > If you require FTP NAT support, then this depends on NF_NAT_FTP
> > instead of NF_CONNTRACK_FTP.
> 
> 	No, I just checked again, it works without nf_nat_ftp,
> only nf_nat, nf_conntrack_ftp and iptable_nat are needed.
> We use packet mangling part from nf_nat (nf_nat_mangle_tcp_packet).

Is there a consensus on this?
