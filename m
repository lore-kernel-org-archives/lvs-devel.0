From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH ipvs,v3 00/20] Support v6 real servers in v4 pools and
 vice versa
Date: Fri, 29 Aug 2014 00:07:46 -0700
Message-ID: <540026C2.9050209@fb.com>
References: <1409204634-1123-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408281759150.1956@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=dvfe1pzFdDbGHQfLiz8Y0AwLKsnaUvTzXoti/AZdq6o=;
 b=gknEDjAqLoCK5lkCreVhAMygZoXnC7d8zZCl+G41WwGIWp/+tGMzOfcdQGYUQZE2PvvC
 Il2xMdx96E9oAh4d7amA0XfojfwVs2d0N+M6mHhLbtP0K+IW+50jVWG2yScsmk7/lnfb
 OFpNcu3GMalV32tufetbMZ7gbMxrx7HGw58= 
In-Reply-To: <alpine.LFD.2.11.1408281759150.1956@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

On 8/28/14 8:15 AM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Wed, 27 Aug 2014, Alex Gartrell wrote:
>
>> At Facebook we use ipip forwarding to deliver packets from our layer 4 ipvs
>> load balancers to our layer 7 proxies.  Today these layer 7 proxies are all
>> dual stacked, so we can simply send v4 over v4 and v6 over v6.  In the
>> future, we're going to have v6-only layer 7 load balancers (no internal v4
>> address).  To deal with this, we'll forward v4 packets in v6 tunnels.  This
>> patchset introduces the necessary functionality into ipvs.
>>
>> The noteworthy limitation of this is that it is not compatible with state
>> synchronization, so great care is taken to keep these things mutually
>> exclusive.
>>
>> This patchset includes changes that add an additional netlink attribute to
>> destinations and changes that plumb the destination address family through
>> parts of the code where it was assumed that it was the same as the service.
>> Finally, there's a change that updates the transmit functions for tunneling
>> to share common code and support v4 in v6 and vice versa.
>>
>> Changes for v2:
>>
>> Introduced crosses_local_route_boundary and update_pmtu functions and
>> conditionally do the ip_hdr operations.  The latter means that df will be
>> effectively zero when we forward an ipv6 packet over an ipv4 tunnel.
>>
>> Additionally, I addressed Julian's other statements.
>>
>> Changes for v3:
>>
>> added back the first two patches
>> checkpatch.pl all of the things
>> pull out the mtu changes
>> other previously detailed fixes
>
> 	I think, we are almost at the final:

Awesome :)

>
> Patch 5:
> 	- we can mix patch 5 and 6?

Yeah sure


>
> Patch 7:
> 	- I guess addr_type var should be in the
> 	'if (skb_af == AF_INET6) {' block. So, do not
> 	forget to compile next time with CONFIG_IP_VS_IPV6=n

I'll make sure I compile each patch with this option.

>
> Patch 9:
> 	- for ensure_mtu_is_adequate():
> 		- move 'struct netns_ipvs *ipvs' below, where ipvs is
> 		assigned
> 		- move 'struct net *net' below, where net is assigned

no problem

>
> Patch 10:
> 	- 'is'->'if' in
> 	/* We only care about the df field is sysctl_pmtu_disc(ipvs) is set */
>

Yeah

>
> 	After checking the cp->daddr usage I prepared
> a patch that we should insert somewhere before the last one.
> Attached.

I'm just going to make one small change: dbuf isn't declared without 
CONFIG_IP_VS_IPV6.

> Later we have to wait
> "ipvs: properly declare tunnel encapsulation" to appear in net-next.
>

No problem, it'll give me time to test it in our environment.

