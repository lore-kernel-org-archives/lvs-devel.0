From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: [*v2 PATCH 0/9] IPVS: staging head
Date: Fri, 12 Nov 2010 08:34:56 +0100
Message-ID: <201011120834.56591.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>

Hello Simon

I had some probelms with the mailer and will resend this a gain...

The first patch in the staging head was not the "current" so I switched them
That effected the patch 2,3 and 4
There was no changes in patch 5,6 and 7

The changes is in the class - trivial.
  Removed fwmark from ip_vs_conn_param,
  and add fwmark to ip_vs_conn_new()

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
