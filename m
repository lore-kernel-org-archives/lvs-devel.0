From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: don't alter conntrack in OPS mode
Date: Fri, 15 Apr 2016 10:17:43 +1000
Message-ID: <20160415001743.GE9557@verge.net.au>
References: <5708f21f.jc8RYqMS4IkxB05t%marcoangaroni@gmail.com>
 <alpine.LFD.2.11.1604122312420.1611@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
	t=1460679464; bh=8xUP1FrubJFUXx4OJTmjdOxAo4AyzTdHnEhnGTTTYMo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=MPEtM191NGcuKIfXre7NzSnlLWSSoqhzZW9lPuY7sfMYP+4KESO0UDbsxAJAKfepM
	 01VbyUThhQOo+1Xld2kqP06yg7k6Ern27SjrIGhxa7GdUax+aEohAKAZDarSneATir
	 4RtEIrP+JiFwWtYg3csz7ejfKs4vDH1Mk7ZaJI64=
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1604122312420.1611@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Marco Angaroni <marcoangaroni@gmail.com>, lvs-devel@vger.kernel.org

On Tue, Apr 12, 2016 at 11:14:17PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sat, 9 Apr 2016, Marco Angaroni wrote:
> 
> > When using OPS mode in conjunction with SIP persistent-engine, packets
> > originating from the same ip-address/port could be balanced to different
> > real servers, and (to properly handle SIP responses) OPS connections 
> > are created in the in-out direction too, where ip_vs_update_conntrack()
> > is called to modify the reply tuple.
> > 
> > As a result, there can be collision of conntrack tuples, causing random
> > packet drops, as explained below:
> > 
> > conntrack1: orig=CIP->VIP, reply=RIP1->CIP
> > conntrack2: orig=RIP2->CIP, reply=CIP->VIP
> > 
> > Tuple CIP->VIP is both in orig of conntrack1 and reply of conntrack2.
> > The collision triggers packet drop inside nf_conntrack processing.
> > 
> > In addition, the current implementation deletes the conntrack object at
> > every expire of an OPS connection (once every forwarded packet), to have
> > it recreated from scratch at next packet traversing IPVS.
> > 
> > Since in OPS mode, by definition, we don't expect any associated 
> > response, the choices implemented in this patch are:
> > a) don't call nf_conntrack_alter_reply() for OPS connections inside
> >    ip_vs_update_conntrack().
> > b) don't delete the conntrack object at OPS connection expire.
> > 
> > The result is that created conntrack objects for each tuple CIP->VIP,
> > RIP-N->CIP, etc. are left in UNREPLIED state and not modified by IPVS
> > OPS connection management. This eliminates packet drops and leaves
> > a single conntrack object for each tuple packets are sent from.
> > 
> > Signed-off-by: Marco Angaroni <marcoangaroni@gmail.com>
> 
> 	Thanks! Looks good to me. Simon, please apply.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Thanks, applied.
