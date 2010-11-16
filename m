From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v5 PATCH 3/7] IPVS: skb defrag in L7 helpers
Date: Wed, 17 Nov 2010 01:23:04 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011170116300.2331@ja.ssi.bg>
References: <1289935971-4229-3-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1289935971-4229-3-git-send-email-hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: lvs-devel@vger.kernel.org, horms@verge.net.au, wensong@linux-vs.org, daniel.lezcano@free.fr, hans@schillstrom.com


 	Hello,

On Tue, 16 Nov 2010, Hans Schillstrom wrote:

> L7 helpers like sip needs skb defrag
> since L7 data can be fragmented.

 	I now see that something is missing here,
ip_vs_conn_fill_param_persist does not propagate the error
code from fill_param and then to *ignored flag in
ip_vs_sched_persist. This problem was discussed on
November 08.

Regards

--
Julian Anastasov <ja@ssi.bg>
