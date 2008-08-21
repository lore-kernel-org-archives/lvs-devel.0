From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 08/24] IPVS: Make protocol handler functions support IPv6
Date: Thu, 21 Aug 2008 16:55:50 +0200
Message-ID: <f4845fc0808210755i1d3e37a0q8ff27af8d59bba0@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <1219248931-15064-9-git-send-email-juliusv@google.com>
	 <48AD6DBB.9030607@hp.com>
	 <f4845fc0808210652o3b586e7cjbeadc41533f9ac7d@mail.gmail.com>
	 <48AD76DE.4030000@hp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1219330551; bh=5EdqBXqebofK29RIA3FLseZXhtI=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=d6tJ6kxI00RnbSr+DBWCysEoCGPWr8xS
	1J6JXINXIdyxqKuQE74FhmqphJsuZy7942mLapAnBqQX6rZIkGmFuw==
In-Reply-To: <48AD76DE.4030000@hp.com>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Brian Haley <brian.haley@hp.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, horms@verge.net.au, kaber@trash.net, vbusam@google.com

On Thu, Aug 21, 2008 at 4:08 PM, Brian Haley <brian.haley@hp.com> wrote:
> Julius Volz wrote:
>>
>> I guessed from the name and other uses that __constant_htons() is just
>> a version of htons() optimized for values that are constant at compile
>> time. Is this right? But htons() is fine too in any case.
>
> I think the __constant one is for initializations.  All I know is that
> someone (Stephen Hemminger?) always points this out in other patchsets, so I
> beat him to it.

He :)

Still, I think my original interpretation was correct? It's always
used with constant values and there are many usages similar to this:

skb->protocol = __constant_htons(ETH_P_802_3);

Someone feel free to correct me.

>>> So why can't you just create one ip_vs_debug_packet_v6() instead of these
>>> ah
>>> and esp ones which are identical?
>>
>> If you look at the original files, the whole ip_vs_proto_ah.c and
>> ip_vs_proto_esp.c are 100% identical except for the protocol names /
>> constants :-/ So I stuck with this pattern for now. Maybe it would
>> make sense to join those two files in a change separate from the v6
>> functionality? There's already a lot of duplication in the existing
>> IPVS that could be removed...
>
> I didn't look too closely, there's a lot of patches! :)  Doing it in a

Yep, it's too big, I know :) And reworking the complete patch into a
sane series didn't really work out that well because everything is so
interdependent. Sometimes it might even be easier to look at the
complete, big patch...

> separate patch is probably a good idea though.

Yeah, should be easy. I'll look at it (if there is any interest).

Julius

-- 
Google Switzerland GmbH
