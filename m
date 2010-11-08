From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 9 Nov 2010 01:01:46 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011090056220.2588@ja.ssi.bg>
References: <20101030231601.GA5908@verge.net.au> <201011032108.07311.hans.schillstrom@ericsson.com> <20101106005614.GA11220@verge.net.au> <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg> <20101106143405.GB27212@verge.net.au> <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg>
 <20101108062121.GA17685@verge.net.au> <alpine.LFD.2.00.1011081027080.1504@ja.ssi.bg> <20101108111600.GA14454@verge.net.au> <alpine.LFD.2.00.1011082245360.1690@ja.ssi.bg> <20101108214943.GC6502@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108214943.GC6502@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Tue, 9 Nov 2010, Simon Horman wrote:

>> - backup creates template but there is no PE => cp->pe remains NULL if
>> 	we want to keep conn entry. Option 2 is that we can ignore
>> 	the conn entry if the PE module is not loaded before this step
>
> I think that is better to drop the entry as (at least the way PE SIP works)
> its entirely likely that it could be used by the scheduler to use
> the wont real server if the pe_data is missing. Or in other words,
> it is no better than the entry being missing all together.

 	Agreed.

> If later we have PE engines that behave differently, and creating
> templates without pe_data makes sense, we can revisit this.
>
>> - svc is added => PE module is loaded (request_module)
>>
>> - next sync message comes and we bind cp->dest => if cp->pe
>> is NULL we should set cp->pe to svc->pe. The problem here is
>> that svc can be added without PE, then this template will not
>> work as expected.
>
> I'm unsure what you mean by "svc can be added without PE"

 	-A without --pe [engine] option in backup.

Regards

--
Julian Anastasov <ja@ssi.bg>
