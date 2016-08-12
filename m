From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v2] ipvs: use nf_ct_kill helper
Date: Fri, 12 Aug 2016 12:24:43 +0200
Message-ID: <20160812102443.GA3086@salvia>
References: <1470230488-302-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470230488-302-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au

On Wed, Aug 03, 2016 at 03:21:28PM +0200, Florian Westphal wrote:
> Once timer is removed from nf_conn struct we cannot open-code
> the removal sequence anymore.

@Simon and other IPVS folks: I'm going to take this patch since
Florian needs this merged for follow up patches.

So I'm dealing with this small one.

Thanks.
