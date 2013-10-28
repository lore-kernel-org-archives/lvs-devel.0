From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH ipvs 2/2] net: ipvs: sctp: do not recalc sctp checksum
 when not needed
Date: Mon, 28 Oct 2013 18:38:21 +0900
Message-ID: <20131028093821.GA11662@verge.net.au>
References: <1af1d5e1aae9df91683625f0cb120b329e8d2f10.1382689350.git.dborkman@redhat.com>
 <8390127344501c35ed3c23f3690b8a671d353870.1382689350.git.dborkman@redhat.com>
 <alpine.LFD.2.03.1310252306230.1600@ssi.bg>
 <526C102C.9040306@redhat.com>
 <20131028013920.GO849@verge.net.au>
 <526E1C3D.1080800@redhat.com>
 <20131028085024.GA26154@verge.net.au>
 <alpine.LFD.2.03.1310281058410.1490@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.03.1310281058410.1490@ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Daniel Borkmann <dborkman@redhat.com>, lvs-devel@vger.kernel.org, linux-sctp@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>

[ Cc: Pablo ]

On Mon, Oct 28, 2013 at 11:00:37AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 28 Oct 2013, Simon Horman wrote:
> 
> > Thanks, I have pushed it to ipvs-next.
> > 
> > I will hold off on sending a pull-request to Pablo until you send
> > the 2nd patch.
> 
> 	First patch is a bugfix, it should go to stable
> kernels. The second patch looks like an optimization.

Good point.

Pablo, what is the best way to handle this?
Should I send the fix as a pull-request for nf or nf-next?
