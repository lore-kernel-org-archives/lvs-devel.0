From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 02/26] IPVS: Change IPVS data structures to support IPv6 addresses.
Date: Wed, 11 Jun 2008 20:08:38 +0200
Message-ID: <f4845fc0806111108q27a3d4f5o84ac638e58fb6ff0@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <1213204329-10973-3-git-send-email-juliusv@google.com>
	 <4850076B.302@trash.net>
	 <f4845fc0806111041u2a9a197fseefe300ffbbda3c3@mail.gmail.com>
	 <485010E9.6000506@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213207720; bh=3YH7hA7fFQGh9kVD0COUpk9cjpg=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=A3L3KKjay+Y9qdyO8EYimKv5pm4elqX9
	Ua94WKivLA/gvL659suTLkAPz3x9cula8qThxERc7ex1JSb2N6h+Cg==
In-Reply-To: <485010E9.6000506@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 11, 2008 at 7:52 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>>
>> On Wed, Jun 11, 2008 at 7:12 PM, Patrick McHardy <kaber@trash.net> wrote:
>>
>>>
>>> include/net is always kernel only. At least it should be that way.
>>>
>>
>> ipvsadm has:
>>
>> INCLUDE         = -I/usr/src/linux/include -I.. -I.
>>
>> in its Makefile and then includes net/ip_vs.h. Even in the current version
>> :(
>>
>
> OK, thanks for the explanation.
>
>>>>  #define IP_VS_IFNAME_MAXLEN    16
>>>>  +union ip_vs_addr_user {
>>>> +       __be32                  v4;
>>>> +       struct in6_addr         v6;
>>>> +};
>>>>
>>>>
>>>
>>> Can't you use nf_inet_addr for this?
>>>
>>
>> Ah, yes. I either didn't know about this or wasn't sure if it was
>> appropriate to reuse that struct from netfilter. I will look into
>> putting this in!
>>
>>
>
> Thanks. But please remember to keep netdev CCed on responses
> to review.

Yes, sorry! Re-added the lists for this response.

Julius

-- 
Google Switzerland GmbH
