From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: avoid lookup for fwmark 0
Date: Sun, 6 Mar 2011 07:19:01 +0900
Message-ID: <20110305221901.GM615@verge.net.au>
References: <6pi9527.faa88a21c91dd91114c03a4bcb764c6e@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6pi9527.faa88a21c91dd91114c03a4bcb764c6e@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Fri, Mar 04, 2011 at 11:48:18AM +0100, Hans Schillstrom wrote:
> 
> >---- Original Message ----
> >From: Julian Anastasov <ja@ssi.bg>
> >To: "Simon Horman" <horms@verge.net.au>
> >Cc: lvs-devel@vger.kernel.org
> >Sent: Fri, Mar 4, 2011, 11:22 AM
> >Subject: [PATCH] ipvs: avoid lookup for fwmark 0
> >
> >Restore the previous behaviour to lookup for fwmark
> >service only when fwmark is non-null. This saves only CPU.
> 
> Good point.
> >
> >Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Hans Schillstrom <hans@schillstrom.com>

Thanks, applied.
