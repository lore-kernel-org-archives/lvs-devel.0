From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch v5 00/12] IPVS: SIP Persistence Engine
Date: Mon, 04 Oct 2010 20:47:56 +0200
Message-ID: <4CAA215C.8040605@trash.net>
References: <20101004134624.963907470@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101004134624.963907470@akiko.akashicho.tokyo.vergenet.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

Am 04.10.2010 15:46, schrieb Simon Horman:
> CODE AVAILABILITY
> 
> The kernel patches (12) are available in git as the pe-5 branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git

Pulled, thanks Simon. I get a warning in ip_vs_pe_sip.c however,
please send a fix for this on top.

net/netfilter/ipvs/ip_vs_pe_sip.c:11: warning: 'ip_vs_dbg_callid'
defined but not used

Thanks!
