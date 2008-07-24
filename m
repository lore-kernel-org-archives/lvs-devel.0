From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IPVS: Move userspace definitions to include/linux/ip_vs.h
Date: Thu, 24 Jul 2008 13:46:38 +0200
Message-ID: <f4845fc0807240446k224215cn7aee7f57a0fa9100@mail.gmail.com>
References: <1216894489-13060-1-git-send-email-juliusv@google.com>
	 <20080724111434.GA30382@verge.net.au> <488865FA.4040002@trash.net>
	 <f4845fc0807240434p4fef9f77u8dc1d006e393bc7b@mail.gmail.com>
	 <48886A3C.7050906@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1216900000; bh=CIOzA3JeEvfLmbLfoPCgvUcCs8s=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=XMppLBc8IIAsS9tHfq+/sz7auHfH55PM
	xwPBBQG1Zv+5zmkS1b1cvpizEDXYfZ8ulN8y0k0VfFo27a0D/p8d0Q==
In-Reply-To: <48886A3C.7050906@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net, vbusam@google.com

On Thu, Jul 24, 2008 at 1:40 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>>
>> On Thu, Jul 24, 2008 at 1:22 PM, Patrick McHardy <kaber@trash.net> wrote:
>>>>>
>>>>> +/* Move it to better place one day, for now keep it unique */
>>>>> +#define NFC_IPVS_PROPERTY      0x10000
>>>
>>> Does this have any connection to the skb flag? If so, does
>>> it really belong in the userspace interface?
>>
>> This doesn't seem to be used at all anymore, but I didn't want to
>> remove it in the same patch... should I?
>
> I'm not sure if this is (or has been) used by userspace, someone
> more familiar with IPVS should answer that.

I don't think so. It was once used as a bitmask into skb->nfcache,
which does not even exist anymore. There's no use of it in the current
ipvsadm. I think it can go away, I'll post an updated patch again.

Julius

-- 
Google Switzerland GmbH
