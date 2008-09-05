From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] ipvs: load balance ipv6 connections from a local process
Date: Fri, 5 Sep 2008 18:37:28 +0200
Message-ID: <f4845fc0809050937m15b7fb1fs21ddc08765d1231c@mail.gmail.com>
References: <20080905013609.GD14128@verge.net.au>
	 <20080905013755.GE14128@verge.net.au>
	 <f4845fc0809050440g24f304d9xec7982e984830c6e@mail.gmail.com>
	 <48C15680.7010004@hp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1220632652; bh=mu1NiIndNr/hrmu8MSxEZ0AcQKE=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=AeVsckP51lbQp8eQyuK55pV81m+SqTtF
	bU+T5jDwNtLb0wHMlPd7UhMTALYkPhufpOi9U8EMFZVtntgyJLFDFw==
In-Reply-To: <48C15680.7010004@hp.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Brian Haley <brian.haley@hp.com>
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Malcolm Turnbull <malcolm@loadbalancer.org>, =?ISO-8859-1?Q?Siim_P=F5der?= <siim@p6drad-teel.net>, Vince Busam <vbusam@google.com>

On Fri, Sep 5, 2008 at 5:55 PM, Brian Haley <brian.haley@hp.com> wrote:
> Julius Volz wrote:
>>>
>>> -out:
>>> -       __ip_vs_conn_put(cp);
>>> -
>>> -       return verdict;
>>> +       snet.in6 = iph->saddr;
>>
>> I've always been told to use ipv6_addr_copy() for this. I'm not sure
>> what the problem with the direct struct assignment is though... would
>> be nice if someone could explain.
>
> Because an in6_addr is a union of 4 u32's, which won't all be copied in a
> struct assignment.  That's the way I've always understood it.

No, they _do_ all get copied and the result seems correct. There must
be another reason...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
