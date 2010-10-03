From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch v3 00/12] IPVS: SIP Persistence Engine
Date: Sun, 3 Oct 2010 14:07:27 +0900
Message-ID: <20101003050725.GA5817@verge.net.au>
References: <20101002023056.536217499@akiko.akashicho.tokyo.vergenet.net>
 <alpine.LFD.2.00.1010021155520.2055@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1010021155520.2055@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>

On Sat, Oct 02, 2010 at 12:00:14PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 2 Oct 2010, Simon Horman wrote:
> 
> >This patch series adds load-balancing of UDP SIP based on Call-ID to
> >IPVS as well as a frame-work for extending IPVS to handle alternate
> >persistence requirements.
> >
> >REVISIONS
> >
> >This is v3 of the patch series with addresses serveral problems
> >raised by Julian Anastasov on the lvs-devel mailing list.
> 
> 	No other obvious problems in v3 1-12. So,
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks.


> 	May be next days I'll test my changes on top of PE v3

I think that could save a bit of porting work later
and perhaps you might notice some more bugs too :-)
