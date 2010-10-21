From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] nf_nat: restrict ICMP translation for embedded header
Date: Thu, 21 Oct 2010 13:27:04 +0200
Message-ID: <20101021112702.GC25555@verge.net.au>
References: <alpine.LFD.2.00.1010111103470.3743@ja.ssi.bg>
 <4CB606AF.4040207@trash.net>
 <4CC020C3.9090104@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CC020C3.9090104@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org

On Thu, Oct 21, 2010 at 01:15:15PM +0200, Patrick McHardy wrote:
> Am 13.10.2010 21:21, schrieb Patrick McHardy:
> > Am 11.10.2010 10:23, schrieb Julian Anastasov:
> >>
> >>     Skip ICMP translation of embedded protocol header
> >> if NAT bits are not set. Needed for IPVS to see the original
> >> embedded addresses because for IPVS traffic the IPS_SRC_NAT_BIT
> >> and IPS_DST_NAT_BIT bits are not set. It happens when IPVS performs
> >> DNAT for client packets after using nf_conntrack_alter_reply
> >> to expect replies from real server.
> >>
> >> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> >> ---
> >>
> >>     I'm not very familiar with this code, so this change
> >> must not be considered as trivial. May be there was a
> >> reason the embedded header to be translated before the NAT
> >> bits are set?
> > 
> > This seems OK to me, but I need to think about it a bit more,
> > this code is subtle.
> 
> I think this change is fine, it does not apply to the current tree
> anymore however. Could you please send me an updated version
> against the nf-next-2.6.git tree? Thanks!

I can handle this and include it in my next pull request.
