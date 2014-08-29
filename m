From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH ipvs,v3 00/20] Support v6 real servers in v4 pools and
 vice versa
Date: Fri, 29 Aug 2014 10:36:46 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408291027230.1520@ja.home.ssi.bg>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408281759150.1956@ja.home.ssi.bg> <540026C2.9050209@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <540026C2.9050209@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com


	Hello,

On Fri, 29 Aug 2014, Alex Gartrell wrote:

> > Patch 7:
> >  - I guess addr_type var should be in the
> >  'if (skb_af == AF_INET6) {' block. So, do not
> >  forget to compile next time with CONFIG_IP_VS_IPV6=n
> 
> I'll make sure I compile each patch with this option.

	One final compile will be enough to detect
a problem :)

> > 	After checking the cp->daddr usage I prepared
> > a patch that we should insert somewhere before the last one.
> > Attached.
> 
> I'm just going to make one small change: dbuf isn't declared without
> CONFIG_IP_VS_IPV6.

	Yes, that is what I thought this morning, the
same mistake :)

Regards

--
Julian Anastasov <ja@ssi.bg>
