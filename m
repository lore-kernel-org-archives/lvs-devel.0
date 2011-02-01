From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re: Re: [GIT PULL nf-next-2.6 v2] IPVS build fixes and 
	clean-ups
Date: Tue, 1 Feb 2011 14:58:24 +0100 (CET)
Message-ID: <7j2t3lt.781331916c4d6de1c741d542224b3c64@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>

>---- Original Message ----
>From: Patrick McHardy <kaber@trash.net>
>To: "Simon Horman" <horms@verge.net.au>
>Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org, "Randy Dunlap" <randy.dunlap@oracle.com>, "Stephen Rothwell" <sfr@canb.auug.org.au>, "Hans Schillstrom" <hans@schillstrom.com>
>Sent: Tue, Feb 1, 2011, 14:25 PM
>Subject: Re: [GIT PULL nf-next-2.6 v2] IPVS build fixes and clean-ups
>
>On 01.02.2011 11:07, Simon Horman wrote:
>> This short patch series addresses two linux-next build problems
>> raised by Randy Dunlap:
>> 
>> * net/netfilter/ipvs/ip_vs_core.c:1891: warning: format '%lu' expects type 'long unsigned int', but argument 2 has type 'unsigned int'
>> * ERROR: "unregister_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko]
>>   ERROR: "register_net_sysctl_table" [net/netfilter/ipvs/ip_vs.ko] undefined!
>> * WARNING: net/netfilter/ipvs/ip_vs.o(.init.text+0x161): Section mismatch in reference from the function init_module() to the function .exit.text:ip_vs_sync_cleanup()
>> 
>> The remainder of the changsets are cleanups that I noticed along the way.
>> 
>> The changes are available at
>> git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git master
>> 
>> They are currently compile-tested only.
>
>Just to avoid any confusion, do you want me to pull these patches
>already?

Let me do a sanity check of this,
It takes a couple of hours

/Hans Schillstrom

