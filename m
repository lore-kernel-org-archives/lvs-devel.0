From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCHv2 net-next] ipvs: queue delayed work to expire no
 destination connections if expire_nodest_conn=1
Date: Wed, 8 Jul 2020 18:12:45 +0200
Message-ID: <20200708161245.GB14873@salvia>
References: <alpine.LFD.2.23.451.2007081847310.3373@ja.home.ssi.bg>
 <20200708160618.13013-1-kim.andrewsy@gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200708160618.13013-1-kim.andrewsy@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Sy Kim <kim.andrewsy@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Wed, Jul 08, 2020 at 12:06:18PM -0400, Andrew Sy Kim wrote:
> When expire_nodest_conn=1 and a destination is deleted, IPVS does not
> expire the existing connections until the next matching incoming packet.
> If there are many connection entries from a single client to a single
> destination, many packets may get dropped before all the connections are
> expired (more likely with lots of UDP traffic). An optimization can be
> made where upon deletion of a destination, IPVS queues up delayed work
> to immediately expire any connections with a deleted destination. This
> ensures any reused source ports from a client (within the IPVS timeouts)
> are scheduled to new real servers instead of silently dropped.

Is this the same patch ?

https://patchwork.ozlabs.org/project/netfilter-devel/patch/20200708135854.28944-1-kim.andrewsy@gmail.com/

Julian has "Signed-off-by:" previous patch and this v2 does not say
what has been updated.

Thanks.
