From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/3] netfilter: xt_ipvs (netfilter matcher for IPVS)
Date: Wed, 2 Sep 2009 17:49:40 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0909021748310.25091@fbirervta.pbzchgretzou.qr>
References: <20090902101417.11561.45663.stgit@jazzy.zrh.corp.google.com>  <20090902101527.11561.59498.stgit@jazzy.zrh.corp.google.com>  <4A9E8711.1070807@trash.net> <b5ddba180909020833w1739bd54t11fded8150007abc@mail.gmail.com> <4A9E90E4.9080805@trash.net>
Mime-Version: 1.0
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752721AbZIBPtl@vger.kernel.org>
In-Reply-To: <4A9E90E4.9080805@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Hannes Eder <heder@google.com>, lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, =?UTF-8?Q?Fabien_Duch=C3=AAne?= <mad_fab@skynet.be>, Jean-Luc Fortemaison <jl.fortemaison@uclouvain.be>, Julian Anastasov <ja@ssi.bg>, Julius Volz <julius.volz@gmail.com>, Laurent Grawet <laurent.grawet@uclouvain.be>, Simon Horman <horms@verge.net.au>, Wensong Zhang <wensong@linux-vs.org>


On Wednesday 2009-09-02 17:36, Patrick McHardy wrote:
>> 
>> Nice, I'll use par->family.
>> 
>> So in theory I do not even need a check like the following in the beginning?
>> 
>> 	if (family != NFPROTO_IPV4
>> #ifdef CONFIG_IP_VS_IPV6
>> 	    && family != NFPROTO_IPV6
>> #endif
>> 		) {
>> 		match = false;
>> 		goto out;
>> 	}
>
>With the AF_UNSPEC registration of your match, it might be used

par->family always contains the NFPROTO of the invoking implementation,
which can never be UNSPEC (except, in future, xtables2 ;-)

par->match->family however may be UNSPEC if the module works that way.
Which is why we have par->family.
