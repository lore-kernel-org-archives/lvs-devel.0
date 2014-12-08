From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Mon, 8 Dec 2014 22:40:43 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412082234350.2401@ja.home.ssi.bg>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg> <5481B944.2000002@smart-weblications.de>
 <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg> <54858948.2060007@smart-weblications.de>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54858948.2060007@smart-weblications.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Mon, 8 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:

> Am 07.12.2014 19:27, schrieb Julian Anastasov:>
> >
> > 	I'm attaching a patch that avoids rerouting in
> > IPVS for LOCAL_IN. Please test it in your setup. My tests
> > were with NAT on today's net tree. I checked that it
> > compiles for 3.12.33. You can use the default snat_reroute=1.
> >
> 
> I'm sorry to tell you that your patch does not fix the problem. The BUG happens
> as soon as the client sends PASV, the ftp server does not return "Entering
> Passive Mode":

	Patch is to avoid the xfrm_selector_match crash,
may be caused when using local client (mail?).
For nf_ct_seqadj_set you have to use commit b25adce16064
("ipvs: correct usage/allocation of seqadj ext in ipvs").
I'll send it to you privately...

Regards

--
Julian Anastasov <ja@ssi.bg>
