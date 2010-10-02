From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch v2 03/12] [PATCH 03/12] IPVS: compact
 ip_vs_sched_persist()
Date: Sat, 2 Oct 2010 10:56:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010021048260.1814@ja.ssi.bg>
References: <20101001143517.645421976@akiko.akashicho.tokyo.vergenet.net> <20101001143941.949669349@akiko.akashicho.tokyo.vergenet.net> <alpine.LFD.2.00.1010020129400.2462@ja.ssi.bg> <20101002022050.GA16593@verge.net.au>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101002022050.GA16593@verge.net.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org, Jan Engelhardt <jengelh@medozas.de>, Stephen Hemminger <shemminger@vyatta.com>, Wensong Zhang <wensong@linux-vs.org>, Patrick McHardy <kaber@trash.net>


 	Hello,

On Sat, 2 Oct 2010, Simon Horman wrote:

>> 	Here dport:
>>
>>> +	dport = dest->port;
>>
>> 	should be:
>>
>> 	dport = ports[1];
>> 	if (dport == svc->port && dest->port)
>> 		dport = dest->port;
>
> Thanks, fixed.

 	I'm still wondering, may be it needs separate patch
but we do not support NAT to different dest->port in the
case for fwmark. May be the above logic can be changed to
support it. By this way web to different VIPs and VPORTs
in a single virtual service (fwmark) can use single NAT
real server for name-based virtual hosting. But such change
can create compatibility problems for setups that used
different vports for the fwmark service and still expect
it in that way (vport to same dport).

Regards

--
Julian Anastasov <ja@ssi.bg>
