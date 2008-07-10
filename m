From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 16:43:08 +0200
Message-ID: <20080710144308.GV20815@postel.suug.ch>
References: <1215616317-11386-1-git-send-email-juliusv@google.com> <1215616317-11386-3-git-send-email-juliusv@google.com> <4874EABC.4000301@trash.net> <f4845fc0807091116s58b0b492p9f28281fcdca4e17@mail.gmail.com> <4875FD75.1090107@trash.net> <f4845fc0807100658i32f7ba5fo2e04ba81fec02eb1@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0807100658i32f7ba5fo2e04ba81fec02eb1@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

* Julius Volz <juliusv@google.com> 2008-07-10 15:58
> On Thu, Jul 10, 2008 at 2:15 PM, Patrick McHardy <kaber@trash.net> wrote:
> > There probably should be a struct module *owner in the
> > ops registered with genetlink. This is necessary at
> > least to make sure that modules don't disappear during
> > dumps.
> 
> There seems to be no such thing in genetlink. af_netlink.c tracks the
> owner of a netlink socket, but that would increase the use count of
> the genetlink module.
> 
> First I would have suspected the genl_mutex to be held while dumping,
> so that at least unregistering the family at module unload would
> block. But the mutex is explicitly unlocked for the duration of the
> netlink dump:

It used to be like before the locking during dumps was revised. I
promised to redo the locking and module owner tracking but haven't
gotten around. Patrick's suggestion certainly makes sense.

> net/netlink/genetlink.c:
> 
>                 genl_unlock();
>                 err = netlink_dump_start(genl_sock, skb, nlh,
>                                          ops->dumpit, ops->done);
>                 genl_lock();
> 
> Julius
