From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 0/5] IPVS changes
Date: Mon, 18 Mar 2013 22:04:05 +0900
Message-ID: <20130318130405.GA7337@verge.net.au>
References: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1362864308-8259-1-git-send-email-ja@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Sat, Mar 09, 2013 at 11:25:03PM +0200, Julian Anastasov wrote:
> 	This patchset adds new backup_only flag and fixes
> some warnings found by sparse. I hope the SCTP part is
> correct. In fact I see other problems with the SCTP state
> machine that need to be resolved.
> 
> 	The patchset does not overlap with the other
> patchset for IPVS optimizations, so can be applied
> independently.

Thanks, applied.
