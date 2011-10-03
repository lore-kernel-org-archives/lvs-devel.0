From: =?iso-8859-1?Q?Hans_Schillstr=F6m?= <hans.schillstrom@ericsson.com>
Subject: [PATCH 0/2] IPVS netns shutdown/startup dead-lock Take II
Date: Mon, 3 Oct 2011 12:55:51 +0200
Message-ID: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903144@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Transfer-Encoding: 7BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Language: en-US
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: "horms@verge.net.au" <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, netdev@vger.k

Hello,
This two patches are for the current kernel, i.e. based on ipvs.git

The first one is a trivial fix for lockdep warnings,
and the second is to solve a Deadlock.

We have observed one more Deadlock case in our lab during startup of multiple containers i.e. netns.
The back trace indicates some more issues with "sk_lock-AF_INET"
However it has only been seen once during almost 4 month of testing.
I can't reproduce it and not find any possibly scenario where it could occur.

This patch fix the case when a name-space dies while another is created.

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>

