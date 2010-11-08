From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 9 Nov 2010 07:00:29 +0900
Message-ID: <20101108220029.GD6502@verge.net.au>
References: <201010291415.35299.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg>
 <20101108062121.GA17685@verge.net.au>
 <201011081615.11335.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201011081615.11335.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Julian Anastasov <ja@ssi.bg>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Mon, Nov 08, 2010 at 04:15:10PM +0100, Hans Schillstrom wrote:
> On Monday 08 November 2010 07:21:23 Simon Horman wrote:
> [ snip ]
> 
> > How about this, which applies on top of
> > "IPVS: Add persistence engine to connection entry".
> >
> > From: Simon Horman <horms@verge.net.au>
> > Subject: IPVS: Only match pe_data created by the same pe
> >
> > Only match persistence engine data if it was
> > created by the same persistence engine.
> >
> > Reported-by: Julian Anastasov <ja@ssi.bg>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> Thanks I'll will use that one,
> I think it's time to cook a new backup patch,
> or do any one have more patches in the pipe ?

I have added this and the other patches that I am completely happy with
to the staging branch of lvs-test-2.6.

Specifically the patches in there are:

* IPVS: Only match pe_data created by the same pe
* IPVS: Add persistence engine to connection entry
* IPVS: Backup, Adding structs for new sync format
* IPVS: Prepare for transferring firewall marks (fwmark) to the backup daemon.
* IPVS: ip_vs_pe.c, use strncmp to be safe.

If you are unhappy with any of those changes let me know,
I'm happy to revert and rebase the staging branch
(its mainly for your benefit at this stage).

I would also like to add the following clean-up changes,
could I get an Ack or Nack from you on each of them?

* IPVS: Make the cp argument to ip_vs_sync_conn() static
  http://www.spinics.net/lists/lvs-devel/msg01375.html
* IPVS: Remove useless { } block from ip_vs_process_message()
  http://www.spinics.net/lists/lvs-devel/msg01369.html
* IPVS: buffer argument to ip_vs_process_message() should not be const
  http://www.spinics.net/lists/lvs-devel/msg01377.html

