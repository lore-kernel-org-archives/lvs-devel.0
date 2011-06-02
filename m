From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: restore support for iptables SNAT
Date: Thu, 2 Jun 2011 22:01:34 +0900
Message-ID: <20110602130132.GG13097@verge.net.au>
References: <1306973394-29504-1-git-send-email-horms@verge.net.au>
 <1306973394-29504-2-git-send-email-horms@verge.net.au>
 <4DE7793F.1060108@netfilter.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DE7793F.1060108@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Thu, Jun 02, 2011 at 01:51:27PM +0200, Pablo Neira Ayuso wrote:
> On 02/06/11 02:09, Simon Horman wrote:
> > From: Julian Anastasov <ja@ssi.bg>
> > 
> > 	Fix the IPVS priority in LOCAL_IN hook,
> > so that SNAT target in POSTROUTING is supported for IPVS
> > traffic as in 2.6.36 where it worked depending on
> > module load order.
> > 
> > 	Before 2.6.37 we used priority 100 in LOCAL_IN to
> > process remote requests. We used the same priority as
> > iptables SNAT and if IPVS handlers are installed before
> > SNAT handlers we supported SNAT in POSTROUTING for the IPVS
> > traffic. If SNAT is installed before IPVS, the netfilter
> > handlers are before IPVS and netfilter checks the NAT
> > table twice for the IPVS requests: once in LOCAL_IN where
> > IPS_SRC_NAT_DONE is set and second time in POSTROUTING
> > where the SNAT rules are ignored because IPS_SRC_NAT_DONE
> > was already set in LOCAL_IN.
> > 
> > 	But in 2.6.37 we changed the IPVS priority for
> > LOCAL_IN with the goal to be unique (101) forgetting the
> > fact that for IPVS traffic we should not walk both
> > LOCAL_IN and POSTROUTING nat tables.
> > 
> > 	So, change the priority for processing remote
> > IPVS requests from 101 to 99, i.e. before NAT_SRC (100)
> > because we prefer to support SNAT in POSTROUTING
> > instead of LOCAL_IN. It also moves the priority for
> > IPVS replies from 99 to 98. Use constants instead of
> > magic numbers at these places.
> 
> I have applied this to my net-next-2.6 tree. Once it hits linus tree,
> I'll pass it to -stable.
> 
> http://1984.lsi.us.es/git/?p=net-next-2.6/.git;a=shortlog;h=refs/heads/pablo/nf-next-2.6-updates

Thanks Pablo.
