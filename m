From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v4 00/12] IPVS: SIP Persistence Engine
Date: Mon, 4 Oct 2010 20:30:33 +0900
Message-ID: <20101004113032.GE10694@verge.net.au>
References: <20101004090352.966809749@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101004090352.966809749@akiko.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Mon, Oct 04, 2010 at 06:03:52PM +0900, Simon Horman wrote:
> This patch series adds load-balancing of UDP SIP based on Call-ID to
> IPVS as well as a frame-work for extending IPVS to handle alternate
> persistence requirements.

[snip]

> CODE AVAILABILITY
> 
> The kernel patches (12) are available in git as the pe-3 branch of
> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git
> 
> The ipvsadm patches (2) are available in git as the pe-3 branch of
> git://github.com/horms/ipvsadm-test.git

pe-3 should read pe-4 above (x2).

> There is no change to the ipvsadm patches since the v2 series
> so I will not repost them.

