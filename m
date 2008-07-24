From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH] IPVS: Move userspace definitions to include/linux/ip_vs.h
Date: Thu, 24 Jul 2008 13:34:27 +0200
Message-ID: <f4845fc0807240434p4fef9f77u8dc1d006e393bc7b@mail.gmail.com>
References: <1216894489-13060-1-git-send-email-juliusv@google.com>
	 <20080724111434.GA30382@verge.net.au> <488865FA.4040002@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1216899269; bh=yiBFks0q624Jo5rp18zd6MH3FYM=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=bPlhtmY2OHqQe5MeIiWrikrv2RkNZPm4
	JM3SE6O8oD/QFiJoeIboS4Aw07rMIdtGDhD2txEtIHTCG3+hm5TKbQ==
In-Reply-To: <488865FA.4040002@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net, vbusam@google.com

On Thu, Jul 24, 2008 at 1:22 PM, Patrick McHardy <kaber@trash.net> wrote:
>>> +/* Move it to better place one day, for now keep it unique */
>>> +#define NFC_IPVS_PROPERTY      0x10000
>
> Does this have any connection to the skb flag? If so, does
> it really belong in the userspace interface?

This doesn't seem to be used at all anymore, but I didn't want to
remove it in the same patch... should I?

>>> +struct ip_vs_service_user {
>>> +       /* virtual service addresses */
>>> +       u_int16_t               protocol;
>>> +       __be32                  addr;           /* virtual ip address */
>>> +       __be16                  port;
>
> If you switch the above two you plug two holes in the struct.

Unfortunately, these structs all have to stay as they are because they
are used by old ipvsadms. That was the whole reason for implementing
the Netlink interface.

Julius

-- 
Google Switzerland GmbH
