From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v2 00/12] IPVS: SIP Persistence Engine
Date: Sat, 2 Oct 2010 00:09:13 +0900
Message-ID: <20101001150912.GA30160@verge.net.au>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org
Cc: Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Patrick McHardy <kaber@trash.net>

On Fri, Oct 01, 2010 at 11:35:17PM +0900, Simon Horman wrote:
> This patch series adds load-balancing of UDP SIP based on Call-ID to
> IPVS as well as a frame-work for extending IPVS to handle alternate
> persistence requirements.

Patrick, I would like these patches considered for inclusion
in nf-next-2.6. There is some minor diffing noise between
this series and "ipvs: Keep track of backlog connections",
which I posted for inclusion in nf-next-2.6 recently. Let
me know if you want me to do something about the noise.

