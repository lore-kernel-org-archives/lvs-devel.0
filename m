From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 9 Nov 2010 01:19:54 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011090105480.2588@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg> <20101108062121.GA17685@verge.net.au> <201011081615.11335.hans.schillstrom@ericsson.com> <20101108220029.GD6502@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108220029.GD6502@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Tue, 9 Nov 2010, Simon Horman wrote:

> I have added this and the other patches that I am completely happy with
> to the staging branch of lvs-test-2.6.
>
> Specifically the patches in there are:
>
> * IPVS: Only match pe_data created by the same pe
> * IPVS: Add persistence engine to connection entry
> * IPVS: Backup, Adding structs for new sync format
> * IPVS: Prepare for transferring firewall marks (fwmark) to the backup daemon.
> * IPVS: ip_vs_pe.c, use strncmp to be safe.

 	Using if (strncmp(pe_name, pe->name, IP_VS_PENAME_MAXLEN )==0
does not look useful. If the goal is to match data from
sync message I expect to see the already discussed check
for pe_name_len, for example:

if (!strncmp(pe_name, pe->name, pe_name_len) &&
     !pe->name[pe_name_len])

 	and somewhere check for pe_name_len > 0.

> If you are unhappy with any of those changes let me know,
> I'm happy to revert and rebase the staging branch
> (its mainly for your benefit at this stage).
>
> I would also like to add the following clean-up changes,
> could I get an Ack or Nack from you on each of them?

 	I don't see problem here:

> * IPVS: Make the cp argument to ip_vs_sync_conn() static
>  http://www.spinics.net/lists/lvs-devel/msg01375.html
> * IPVS: Remove useless { } block from ip_vs_process_message()
>  http://www.spinics.net/lists/lvs-devel/msg01369.html
> * IPVS: buffer argument to ip_vs_process_message() should not be const
>  http://www.spinics.net/lists/lvs-devel/msg01377.html

Regards

--
Julian Anastasov <ja@ssi.bg>
