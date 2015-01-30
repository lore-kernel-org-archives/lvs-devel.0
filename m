From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: rerouting to local clients is not needed
 anymore
Date: Fri, 30 Jan 2015 10:22:57 +0900
Message-ID: <20150130012257.GF11897@verge.net.au>
References: <1418935283-5315-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418935283-5315-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>

On Thu, Dec 18, 2014 at 10:41:23PM +0200, Julian Anastasov wrote:
> commit f5a41847acc5 ("ipvs: move ip_route_me_harder for ICMP")
> from 2.6.37 introduced ip_route_me_harder() call for responses to
> local clients, so that we can provide valid rt_src after SNAT.
> It was used by TCP to provide valid daddr for ip_send_reply().
> After commit 0a5ebb8000c5 ("ipv4: Pass explicit daddr arg to
> ip_send_reply()." from 3.0 this rerouting is not needed anymore
> and should be avoided, especially in LOCAL_IN.
> 
> Fixes 3.12.33 crash in xfrm reported by Florian Wiessner:
> "3.12.33 - BUG xfrm_selector_match+0x25/0x2f6"
> 
> Reported-by: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
> Tested-by: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Patch tested on net tree (Dec 7), 3.14.25, 3.12.33, 3.10.61.
> 3.4.104 needs a modified fix that resolves rejects, it applies
> with little fuzz on 3.2.64. Let me know if I should post
> separately 3.2 and 3.4 patches.

Sorry for missing this. I have queued it up and
sent a pull-request to Pablo.
