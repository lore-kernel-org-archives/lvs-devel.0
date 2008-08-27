From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 10/24] IPVS: Extend scheduling functions for IPv6 support
Date: Wed, 27 Aug 2008 18:02:59 +0200
Message-ID: <f4845fc0808270902l4b5a6f5br7e0a749a5741a1b5@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <1219248931-15064-11-git-send-email-juliusv@google.com>
	 <20080827062822.GC3816@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219852983; bh=uNNcGpYqPVIuVL+naq+ILklwwdE=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=hqKfHJ/0i7ub0ibjbHKge8Z2/iJWyXtF
	8Ac8v7muDAvikvNt2qOdCDbEZDL2j3cS+iUe86ceV9bGeN6tIWlODg==
In-Reply-To: <20080827062822.GC3816@verge.net.au>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Wed, Aug 27, 2008 at 8:28 AM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Aug 20, 2008 at 06:15:17PM +0200, Julius Volz wrote:
>> Convert ip_vs_schedule() and ip_vs_sched_persist() to support scheduling
>> IPv6 connections.
>>
>> Signed-off-by: Julius Volz <juliusv@google.com>
>>
>>  1 files changed, 58 insertions(+), 43 deletions(-)
>>
>> diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
>> index 99e8938..0f9a0a2 100644
>> --- a/net/ipv4/ipvs/ip_vs_core.c
>> +++ b/net/ipv4/ipvs/ip_vs_core.c
>> @@ -183,14 +183,21 @@ ip_vs_sched_persist(struct ip_vs_service *svc,
>>                   __be16 ports[2])
>>  {
>>       struct ip_vs_conn *cp = NULL;
>> -     struct iphdr *iph = ip_hdr(skb);
>> +     struct ip_vs_iphdr iph;
>>       struct ip_vs_dest *dest;
>>       struct ip_vs_conn *ct;
>> -     __be16  dport;   /* destination port to forward */
>> -     __be32  snet;    /* source network of the client, after masking */
>> +     __be16  dport;                  /* destination port to forward */
>> +     union nf_inet_addr snet;        /* source network of the client, after masking */
>
> Can you break the line above so that it is <= 80 columns wide?

Sure! Same for all the other cases.

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
