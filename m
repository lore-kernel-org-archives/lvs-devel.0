From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: optimize release of connections in OPS mode
Date: Fri, 15 Apr 2016 10:16:08 +1000
Message-ID: <20160415001607.GD9557@verge.net.au>
References: <5703e74c.U5rZ4wS4UQ/GgXJn%marcoangaroni@gmail.com>
 <alpine.LFD.2.11.1604091313310.2087@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1460679368; bh=RfCYSG0w8u8ilKF0ZPAyjM7jEWCI0sOvJGZSRdYIcgY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=loofODkknwAt1JLE/9hEK4w70MnNGlmBIR5ZylO3ETJV4taqO+Pxr4aGNBo4kP3xY
	 B/pHMkX9YijJXknljkFbFWeh50jFIUk4WfXOh0f8nkLSde16unFucrgPRHiBRqtVMp
	 fspdQSwpYb+yX41NAqli99hF5PvPk/iJ3ZbZRvqY=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1604091313310.2087@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Marco Angaroni <marcoangaroni@gmail.com>, lvs-devel@vger.kernel.org

On Sat, Apr 09, 2016 at 01:16:15PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 5 Apr 2016, Marco Angaroni wrote:
> 
> > One-packet-scheduling is the most expensive mode in IPVS from
> > performance point of view: for each packet to be processed a new
> > connection data structure is created and, after packet is sent,
> > deleted by starting a new timer set to expire immediately.
> > 
> > SIP persistent-engine needs OPS mode to have Call-ID based load
> > balancing, so OPS mode performance has negative impact in SIP
> > protocol load balancing.
> > 
> > This patch aims to improve performance of OPS mode by means of the
> > following changes in the release mechanism of OPS connections:
> > a) call expire callback ip_vs_conn_expire() directly instead of
> >    starting a timer programmed to fire immediately.
> > b) avoid call_rcu() overhead inside expire callback, since OPS
> >    connection are not inserted in the hash-table and last just the
> >    time to process the packet, hence there is no concurrent access
> >    to such data structures.
> > 
> > Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> 
> 	Looks good to me. Simon, please apply.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
