From: Simon Horman <horms@verge.net.au>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 9 Nov 2010 09:48:25 +0900
Message-ID: <20101109004825.GJ6502@verge.net.au>
References: <201010291415.35299.hans.schillstrom@ericsson.com>
 <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg>
 <20101108062121.GA17685@verge.net.au>
 <201011081615.11335.hans.schillstrom@ericsson.com>
 <20101108220029.GD6502@verge.net.au>
 <alpine.LFD.2.00.1011090105480.2588@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1011090105480.2588@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Tue, Nov 09, 2010 at 01:19:54AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Tue, 9 Nov 2010, Simon Horman wrote:
> 
> >I have added this and the other patches that I am completely happy with
> >to the staging branch of lvs-test-2.6.
> >
> >Specifically the patches in there are:
> >
> >* IPVS: Only match pe_data created by the same pe
> >* IPVS: Add persistence engine to connection entry
> >* IPVS: Backup, Adding structs for new sync format
> >* IPVS: Prepare for transferring firewall marks (fwmark) to the backup daemon.
> >* IPVS: ip_vs_pe.c, use strncmp to be safe.
> 
> 	Using if (strncmp(pe_name, pe->name, IP_VS_PENAME_MAXLEN )==0
> does not look useful. If the goal is to match data from
> sync message I expect to see the already discussed check
> for pe_name_len, for example:
> 
> if (!strncmp(pe_name, pe->name, pe_name_len) &&
>     !pe->name[pe_name_len])
> 
> 	and somewhere check for pe_name_len > 0.

To be honest, I am a bit dubious about the need for strncmp() at all.
I think it all depends on how/if pe_name can be trusted.
And I think that will depend on how Hans codes up the synchronisation code.
