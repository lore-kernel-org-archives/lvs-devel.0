From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Wed, 02 Sep 2009 19:51:42 +0200
Message-ID: <4A9EB0AE.4080904@trash.net>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>  <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>  <4A9E8711.1070807@trash.net> <b5ddba180909020833w1739bd54t11fded8150007abc@mail.gmail.com> <4A9E90E4.9080805@trash.net> <alpine.LSU.2.00.0909021748310.25091@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0909021748310.25091@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Hannes Eder <heder@google.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?ISO-8859-15?Q?Fabien_Duch=EAne?= <mad_fab@skynet.be>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>

Jan Engelhardt wrote:
> On Wednesday 2009-09-02 17:36, Patrick McHardy wrote:
>>> Nice, I'll use par->family.
>>>
>>> So in theory I do not even need a check like the following in the beginning?
>>>
>>> 	if (family != NFPROTO_IPV4
>>> #ifdef CONFIG_IP_VS_IPV6
>>> 	    && family != NFPROTO_IPV6
>>> #endif
>>> 		) {
>>> 		match = false;
>>> 		goto out;
>>> 	}
>> With the AF_UNSPEC registration of your match, it might be used
> 
> par->family always contains the NFPROTO of the invoking implementation,
> which can never be UNSPEC (except, in future, xtables2 ;-)

I didn't say it will be UNSPEC, I said it might be something
different than IPV4/IPV6 unless that is checked *somewhere*.
