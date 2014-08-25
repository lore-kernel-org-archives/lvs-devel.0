From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] ipvs: properly declare tunnel encapsulation
Date: Mon, 25 Aug 2014 08:13:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1408250809380.1935@ja.home.ssi.bg>
References: <1406878577-4506-1-git-send-email-ja@ssi.bg> <20140825011852.GB31233@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20140825011852.GB31233@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>, kernel-team <Kernel-team@fb.com>


	Hello,

On Mon, 25 Aug 2014, Simon Horman wrote:

> On Fri, Aug 01, 2014 at 10:36:17AM +0300, Julian Anastasov wrote:
> > The tunneling method should properly use tunnel encapsulation.
> > Fixes problem with CHECKSUM_PARTIAL packets when TCP/UDP csum
> > offload is supported.
> > 
> > Thanks to Alex Gartrell for reporting the problem, providing
> > solution and for all suggestions.
> 
> With this patch is Alex's patch "[PATCH ipvs] ipvs: invoke
> skb_checksum_help prior to encapsulation in tunnel xmit " also needed?

	Not needed, we prefer to avoid csum calculation by CPU.

Regards

--
Julian Anastasov <ja@ssi.bg>
