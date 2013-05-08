From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: Fix reuse connection if real server is dead
Date: Wed, 8 May 2013 11:53:33 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305081146470.1912@ja.ssi.bg>
References: <1367963680-5213-1-git-send-email-grzegorz.lyczba@gmail.com>  <alpine.LFD.2.00.1305081012310.1912@ja.ssi.bg> <1368000475.3169.163.camel@hawk.mlab.se>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1368000475.3169.163.camel@hawk.mlab.se>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Grzegorz Lyczba <grzegorz.lyczba@gmail.com>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>


	Hello,

On Wed, 8 May 2013, Hans Schillstrom wrote:

> > > +	    unlikely(!atomic_read(&cp->dest->weight)) &&
> > 
> > 	We should add '!iph.fragoffs &&' here.
> 
> Do we really need that?
> I don't think a SYN can be fragmented.

	SYNs are usually not fragmented. But we don't have the
right to search for SYN in a packet without TCP header. It can
be data fragment that contains 1 at this bit position, when
weight=0 such packets should be forwarded as part of existing
connection.

Regards

--
Julian Anastasov <ja@ssi.bg>
