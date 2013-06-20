From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: sloppy TCP and SCTP
Date: Thu, 20 Jun 2013 22:12:32 +0900
Message-ID: <20130620131232.GB24993@verge.net.au>
References: <20130612104754.GA29327@eldamar.org.uk>
 <20130613075615.GA29773@eldamar.org.uk>
 <alpine.LFD.2.00.1306131121470.1680@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306131121470.1680@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alexander Frolkin <avf@eldamar.org.uk>, lvs-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 13, 2013 at 11:32:11AM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 13 Jun 2013, Alexander Frolkin wrote:
> 
> > This adds support for sloppy TCP and SCTP modes to IPVS.
> > 
> > When enabled (sysctls net.ipv4.vs.sloppy_tcp and
> > net.ipv4.vs.sloppy_sctp), allows IPVS to create connection state on any
> > packet, not just a TCP SYN (or SCTP INIT).
> > 
> > This allows connections to fail over from one IPVS director to another
> > mid-flight.
> > 
> > Signed-off-by: Alexander Frolkin <avf@eldamar.org.uk>
> 
> 	Thanks! Simon, please apply to ipvs-next tree!

Done :)

> Signed-off-by: Julian Anastasov <ja@ssi.bg>
