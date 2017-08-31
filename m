From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net 0/2] netfilter: ipvs: some fixes in sctp_conn_schedule
Date: Thu, 31 Aug 2017 13:59:08 +0200
Message-ID: <20170831115904.GA16979@verge.net.au>
References: <cover.1503207076.git.lucien.xin@gmail.com>
 <20170828161732.GA13738@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1504180754; bh=tEoRBZwk2L94vsYBxQdA2iqN8wkBVDfaxmEzyyhDhZA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=NWqa8ecb/uVUXotMl4lbTlj/wLXFW6FGW88S+k1ZeyrDquGZDe28XJSI7pwPPJHIj
         pHIw7Ag5WDRtrbOWFL1SjtSsYAq/0rf/uxYIwHnkghLWmOuM02/UbYe0GSO6gCytri
         0iInj2irAjMJGDcEcgeiHpBE5awB3UW2rLie/5MQ=
Content-Disposition: inline
In-Reply-To: <20170828161732.GA13738@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Xin Long <lucien.xin@gmail.com>, netfilter-devel@vger.kernel.org, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org

On Mon, Aug 28, 2017 at 06:17:32PM +0200, Pablo Neira Ayuso wrote:
> On Sun, Aug 20, 2017 at 01:38:06PM +0800, Xin Long wrote:
> > Patch 1/2 fixes the regression introduced by commit 5e26b1b3abce.
> > Patch 2/2 makes ipvs not create conn for sctp ABORT packet.
> 
> Will wait for Julian and Simon to tell me what I should do with this.

Hi Pablo,

could you take these directly with Julian's Ack and the following?

Signed-off-by: Simon Horman <horms@verge.net.au>

