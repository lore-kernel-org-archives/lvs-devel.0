From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] ipvs: queue delayed work to expire no
 destination connections if expire_nodest_conn=1
Date: Wed, 15 Jul 2020 20:54:42 +0200
Message-ID: <20200715185442.GA19665@salvia>
References: <20200708161245.GB14873@salvia>
 <20200708161638.13584-1-kim.andrewsy@gmail.com>
 <alpine.LFD.2.23.451.2007082006311.3373@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.23.451.2007082006311.3373@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Andrew Sy Kim <kim.andrewsy@gmail.com>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Wed, Jul 08, 2020 at 08:19:55PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 8 Jul 2020, Andrew Sy Kim wrote:
> 
> > When expire_nodest_conn=1 and a destination is deleted, IPVS does not
> > expire the existing connections until the next matching incoming packet.
> > If there are many connection entries from a single client to a single
> > destination, many packets may get dropped before all the connections are
> > expired (more likely with lots of UDP traffic). An optimization can be
> > made where upon deletion of a destination, IPVS queues up delayed work
> > to immediately expire any connections with a deleted destination. This
> > ensures any reused source ports from a client (within the IPVS timeouts)
> > are scheduled to new real servers instead of silently dropped.
> > 
> > Signed-off-by: Andrew Sy Kim <kim.andrewsy@gmail.com>
> 
> 	OK, patch content is same, subject has "ipvs:" prefix,
> empty line after Signed-off-by is removed, so this patch can
> be applied without any modifications.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
