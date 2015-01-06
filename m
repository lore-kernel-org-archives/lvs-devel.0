From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Tue, 6 Jan 2015 22:46:57 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1501062240130.2241@ja.home.ssi.bg>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg> <5481B944.2000002@smart-weblications.de>
 <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg> <54858948.2060007@smart-weblications.de> <alpine.LFD.2.11.1412082234350.2401@ja.home.ssi.bg> <5486CD9D.4060107@smart-weblications.de> <alpine.LFD.2.11.1412102331230.4043@ja.home.ssi.bg>
 <5489A465.6090305@smart-weblications.de> <alpine.LFD.2.11.1412132211260.3229@ja.home.ssi.bg> <54ABDB98.9060504@suse.cz>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <54ABDB98.9060504@suse.cz>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Slaby <jslaby@suse.cz>
Cc: Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>, Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Tue, 6 Jan 2015, Jiri Slaby wrote:

> So what should be done to fix the issue in stable 3.12? Are those
> patches needed in the upstream kernel too? In that case I suppose it
> will propagate to me through upstream. Otherwise, could you send "3.12
> only" patches to stable@ so that I can apply them?

	I asked Pablo for the old fix for IPVS-FTP:

http://www.spinics.net/lists/lvs-devel/msg03879.html

	The new fix for the xfrm crash is not applied yet:

http://www.spinics.net/lists/lvs-devel/msg03877.html

Regards

--
Julian Anastasov <ja@ssi.bg>
