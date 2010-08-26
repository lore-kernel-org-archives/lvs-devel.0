From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
Subject: Re: [patch][enhancement] ldirectord: IPv6: new directives:
 virtual6, real6, fallback6
Date: Thu, 26 Aug 2010 23:41:00 +0900 (JST)
Message-ID: <20100826.234100.246516967.sohgo@sohgo.dyndns.org>
References: <20100807.195010.226787800.sohgo@sohgo.dyndns.org>
	<20100826.224213.260099549.sohgo@sohgo.dyndns.org>
	<20100826141646.GA12934@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100826141646.GA12934@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org
Cc: horms@verge.net.au


Hi simon,

From: Simon Horman <horms@verge.net.au>
|
> On Thu, Aug 26, 2010 at 10:42:13PM +0900, Sohgo Takeuchi wrote:
>> From: Sohgo Takeuchi <sohgo@sohgo.dyndns.org>
>> > 
>> > I attached a patch to enhance an IPv6 support of ldirectord.
>> > 
>> > - Added new directives: virtual6, real6, fallback6.
>> >   These are used to specify IPv6 as addresses or hostnames.
>> >   Now cannot specify an IPv6 address in a "virtual" and "real"
>> >   line (This breaks backwards compatibility).
>> > - Supported following checktypes and services.
>> >   checktype: connect, external, external-perl, negotiate, off,
>> >              on, checktimeoutN
>> >   service: dns, nntp, none, simpletcp, sip
>> > - firewall-mark + IPv6 works.
>> 
>> Any comments and any refinement of my code are appreciated.
> 
> Sorry for not getting to this earlier.

No problem.

> The patch looks good, I have pushed as
> http://hg.linux-ha.org/agents/rev/6e8b562f5414

Thank you!

