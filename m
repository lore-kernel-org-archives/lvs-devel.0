From: Simon Horman <horms@verge.net.au>
Subject: Re: [v3 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 16 Nov 2010 06:58:57 +0900
Message-ID: <20101115215857.GB10582@verge.net.au>
References: <201011121342.41418.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1011130123360.2125@ja.ssi.bg>
 <201011151931.17120.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201011151931.17120.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, Daniel Lezcano <daniel.lezcano@free.fr>

On Mon, Nov 15, 2010 at 07:31:14PM +0100, Hans Schillstrom wrote:
> On Saturday 13 November 2010 00:31:21 you wrote:
> > 
> >  	Hello,
> > 
> > On Fri, 12 Nov 2010, Hans Schillstrom wrote:
> > 
> > > This patch series adds/(updates) the following functionality
> > > in the synchronization between master and backup daemons.
> > >
> > > - IPv6
> > > - Persistence Engine
> > > - Firewall marks transferred
> > > - Time-outs transferred.
> > > - Flag field increased to 32 bits.
> > >
> > > Note:
> > > This patches depends on Patch 1-9 in staging branch:
> > > "IPVS: Backup, Prepare for transferring firewall marks (fwmark) to the backup daemon."
> > > to ...
> > > "IPVS: skb defrag in L7 helpers"
> > >
> > > A new message format is also introduced, not understood by old backup daemons.
> > > For compatibility reasons receiving the old version (version 0) is still possible.
> > > Old (version 0) backups will just drop new (Version 1) messages.
> > > It's also possible to send sync msg in version 0 format, by sysctl
> > > #sysclt -w net.ipv4.vs.sync_version=0
> > 
> > v3 PATCH 1/3
> >  	- ntoh_seq can use directly get_unaligned_be32, it is BE to CPU,
> >  		no need for ntohl
> 
> Tanks,
> 
> > 
> >  	- In ip_vs_conn_fill_param_sync:
> > 
> >  		- should we ignore the conn entry when pe_name_len
> >  		is 0 and pe_data_len != 0 (return 1)? May be such checks:
> > 
> >  		/* Handle pe data */
> >  		if ((pe_data_len != 0) != (pe_name_len != 0)) {
> >  			IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
> >  			return 1;
> >  		}
> >  		if (!pe_name_len)
> >  			return 0;
> >  		...
> 
> It's OK, for me, what do you think Simon ?
> Lets do it this way,
> 	if (pe_data_len) {
> 		if (pe_name_len) {
> 			...
> 		} else {
> 			IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
> 			return 1;
> 		}
> 		...
> > 
> >  		- make sure p->pe is _put when p->pe_data
> >  			allocation fails (-ENOMEM)
> > 
> 		if (!p->pe_data) {
> 			if (p->pe->module)
> 				module_put(p->pe->module);
> 			return -ENOMEM;
> 		}

I think that looks reasonable
