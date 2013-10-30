From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v3 ipvs-next] net: ipvs: sctp: do not recalc sctp csum
 when ports didn't change
Date: Wed, 30 Oct 2013 09:48:46 +0900
Message-ID: <20131030004846.GN21262@verge.net.au>
References: <1382954180-8264-1-git-send-email-dborkman@redhat.com>
 <alpine.LFD.2.03.1310281242130.2984@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310281242130.2984@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Daniel Borkmann <dborkman@redhat.com>, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org

On Mon, Oct 28, 2013 at 12:43:26PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 28 Oct 2013, Daniel Borkmann wrote:
> 
> > Unlike UDP or TCP, we do not take the pseudo-header into
> > account in SCTP checksums. So in case port mapping is the
> > very same, we do not need to recalculate the whole SCTP
> > checksum in software, which is very expensive.
> > 
> > Also, similarly as in TCP, take into account when a private
> > helper mangled the packet. In that case, we also need to
> > recalculate the checksum even if ports might be same.
> > 
> > Thanks for feedback regarding skb->ip_summed checks from
> > Julian Anastasov; here's a discussion on these checks for
> > snat and dnat:
> > 
> > * For snat_handler(), we can see CHECKSUM_PARTIAL from
> >   virtual devices, and from LOCAL_OUT, otherwise it
> >   should be CHECKSUM_UNNECESSARY. In general, in snat it
> >   is more complex. skb contains the original route and
> >   ip_vs_route_me_harder() can change the route after
> >   snat_handler. So, for locally generated replies from
> >   local server we can not preserve the CHECKSUM_PARTIAL
> >   mode. It is an chicken or egg dilemma: snat_handler
> >   needs the device after rerouting (to check for
> >   NETIF_F_SCTP_CSUM), while ip_route_me_harder() wants
> >   the snat_handler() to put the new saddr for proper
> >   rerouting.
> > 
> > * For dnat_handler(), we should not see CHECKSUM_COMPLETE
> >   for SCTP, in fact the small set of drivers that support
> >   SCTP offloading return CHECKSUM_UNNECESSARY on correctly
> >   received SCTP csum. We can see CHECKSUM_PARTIAL from
> >   local stack or received from virtual drivers. The idea is
> >   that SCTP decides to avoid csum calculation if hardware
> >   supports offloading. IPVS can change the device after
> >   rerouting to real server but we can preserve the
> >   CHECKSUM_PARTIAL mode if the new device supports
> >   offloading too. This works because skb dst is changed
> >   before dnat_handler and we see the new device. So, checks
> >   in the 'if' part will decide whether it is ok to keep
> >   CHECKSUM_PARTIAL for the output. If the packet was with
> >   CHECKSUM_NONE, hence we deal with unknown checksum. As we
> >   recalculate the sum for IP header in all cases, it should
> >   be safe to use CHECKSUM_UNNECESSARY. We can forward wrong
> >   checksum in this case (without cp->app). In case of
> >   CHECKSUM_UNNECESSARY, the csum was valid on receive.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> 
> 	Looks good, thanks!
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, I have queued this up.
