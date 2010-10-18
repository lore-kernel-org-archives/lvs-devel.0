From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 00/12] ipvs: changes for local server and local client
Date: Mon, 18 Oct 2010 23:08:00 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010182259500.1763@ja.ssi.bg>
References: <alpine.LFD.2.00.1010171607550.20665@ja.ssi.bg> <201010181042.27654.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201010181042.27654.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>


 	Hello,

On Mon, 18 Oct 2010, Hans Schillstrom wrote:

>> Not tested: IPv6. I'll need help here from people with IPv6 setups.
>>
>
> I can help you with some IPv6 testing this week.

 	Thanks in advance

> I would be nice to change the IPv6 address print format from %pI6 to %pI6c to get a more compact debug output.

 	Yes, may be in following cleanup patches because the
IPVS debugging needs improvement.

Regards

--
Julian Anastasov <ja@ssi.bg>
