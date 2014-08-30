From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs,v4 19/20] ipvs: use the new dest addr family field
Date: Sat, 30 Aug 2014 11:35:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408301123020.1671@ja.home.ssi.bg>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com> <1409301549-5284-20-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg> <5400EE48.5060007@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <5400EE48.5060007@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Fri, 29 Aug 2014, Alex Gartrell wrote:

> I updated this patch
> 
> -#define IP_VS_ADDRSTRLEN INET_ADDRSTRLEN
> +#define IP_VS_ADDRSTRLEN (8+1)

	ok

> I'll spare the mailing list another 20 emails though.
> 
> So, if I understand correctly, we'll wait until it lands in net-next and then
> I'll submit these patches to netdev?

	Yes, we'll wait the patch but then post them again
here, so that Simon can apply them to ipvs-next. Simon
then adds netdev to CC list.

	Simon can say if he agrees to keep them somewhere 
until it is time to apply them, in case he follows our
discussion :)

> > 	For now we have to find a way to support sync
> > protocol and to update ipvsadm.
> 
> I'll mail the ipvsadm change right away.  I haven't begun to think about sync
> protocol though :)

	I'll think about sync :)

Regards

--
Julian Anastasov <ja@ssi.bg>
