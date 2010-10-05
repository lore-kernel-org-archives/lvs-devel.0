From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v5 00/12] IPVS: SIP Persistence Engine
Date: Tue, 5 Oct 2010 19:00:23 +0900
Message-ID: <20101005100023.GC18737@verge.net.au>
References: <20101004134624.963907470@akiko.akashicho.tokyo.vergenet.net>
 <4CAA215C.8040605@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CAA215C.8040605@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Mon, Oct 04, 2010 at 08:47:56PM +0200, Patrick McHardy wrote:
> Am 04.10.2010 15:46, schrieb Simon Horman:
> > CODE AVAILABILITY
> > 
> > The kernel patches (12) are available in git as the pe-5 branch of
> > git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git
> 
> Pulled, thanks Simon. I get a warning in ip_vs_pe_sip.c however,
> please send a fix for this on top.
> 
> net/netfilter/ipvs/ip_vs_pe_sip.c:11: warning: 'ip_vs_dbg_callid'
> defined but not used

Sorry about that, I will investigate and send a fix.
