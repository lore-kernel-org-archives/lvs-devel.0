From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3.2.66] ipvs: rerouting to local clients is not needed
 anymore
Date: Mon, 9 Feb 2015 12:30:27 +0100
Message-ID: <20150209113027.GA3854@salvia>
References: <1423212925-24810-1-git-send-email-ja@ssi.bg>
 <20150209002310.GA12850@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150209002310.GA12850@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Mon, Feb 09, 2015 at 09:23:10AM +0900, Simon Horman wrote:
> On Fri, Feb 06, 2015 at 10:55:25AM +0200, Julian Anastasov wrote:
> > commit f5a41847acc5 ("ipvs: move ip_route_me_harder for ICMP")
> > from 2.6.37 introduced ip_route_me_harder() call for responses to
> > local clients, so that we can provide valid rt_src after SNAT.
> > It was used by TCP to provide valid daddr for ip_send_reply().
> > After commit 0a5ebb8000c5 ("ipv4: Pass explicit daddr arg to
> > ip_send_reply()." from 3.0 this rerouting is not needed anymore
> > and should be avoided, especially in LOCAL_IN.
> > 
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, could you guide this into stable 3.2 ?

Done, thanks.
