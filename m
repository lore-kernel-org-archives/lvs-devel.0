From: Graeme Fowler <graeme@graemef.net>
Subject: Re: [*v2 PATCH 00/22] IPVS, Network Name Space aware
Date: Wed, 15 Dec 2010 12:15:26 +0000
Message-ID: <1292415326.7459.8.camel@localhost>
References: <1292247510-753-1-git-send-email-hans.schillstrom@ericsson.com>
	 <alpine.LFD.2.00.1012150136410.2010@ja.ssi.bg>
	 <1292410332.4983.321.camel@seasc0214>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1292410332.4983.321.camel@seasc0214>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, "horms@verge.net.au" <horms@verge.net.au>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>, "hans@schillstrom.com" <hans@schillstrom.com>

On Wed, 2010-12-15 at 11:52 +0100, Hans Schillstrom wrote:
> Should I keep /proc/net/ip_vs_stats as it was before and add a new entry
> like /proc/net/ip_vs_stats_percpu ?
> (or maybe just skip the per cpu info ?)

In my opinion you should keep the existing /proc/net/ip_vs_stats as it
is or you may find that you inadvertently break 3rd party code which
parses it.

Graeme


