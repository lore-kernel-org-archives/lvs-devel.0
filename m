From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 15:58:34 +0200
Message-ID: <f4845fc0807100658i32f7ba5fo2e04ba81fec02eb1@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <1215616317-11386-3-git-send-email-juliusv@google.com>
	 <4874EABC.4000301@trash.net>
	 <f4845fc0807091116s58b0b492p9f28281fcdca4e17@mail.gmail.com>
	 <4875FD75.1090107@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1215698317; bh=2fGzB02aJu5k6ObK0RIQXM2ZPck=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=n14dHP0glEbILNsJ+dFsgxYBQIMa8tGR
	4pinkCZUxYP165Ei0lYTaDxn78953TeP3L4grjWF/V9NfobQmh0J+Q==
In-Reply-To: <4875FD75.1090107@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

On Thu, Jul 10, 2008 at 2:15 PM, Patrick McHardy <kaber@trash.net> wrote:
> There probably should be a struct module *owner in the
> ops registered with genetlink. This is necessary at
> least to make sure that modules don't disappear during
> dumps.

There seems to be no such thing in genetlink. af_netlink.c tracks the
owner of a netlink socket, but that would increase the use count of
the genetlink module.

First I would have suspected the genl_mutex to be held while dumping,
so that at least unregistering the family at module unload would
block. But the mutex is explicitly unlocked for the duration of the
netlink dump:

net/netlink/genetlink.c:

                genl_unlock();
                err = netlink_dump_start(genl_sock, skb, nlh,
                                         ops->dumpit, ops->done);
                genl_lock();

Julius

-- 
Google Switzerland GmbH
