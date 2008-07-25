From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 0/2] IPVS: Add Generic Netlink configuration interface
Date: Sat, 26 Jul 2008 01:29:56 +0200
Message-ID: <20080725232956.GF20815@postel.suug.ch>
References: <1216645375-20410-1-git-send-email-juliusv@google.com> <20080722003403.GC9041@verge.net.au> <4886665E.5060209@google.com> <4887A4FE.8080706@google.com> <20080725055806.GA5118@verge.net.au> <f4845fc0807251536l16cd6166gc62be740a14df93a@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0807251536l16cd6166gc62be740a14df93a@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, davem@davemloft.net

* Julius Volz <juliusv@google.com> 2008-07-26 00:36
> On Fri, Jul 25, 2008 at 7:58 AM, Simon Horman <horms@verge.net.au> wrote:
> > BUG: unable to handle kernel paging request at 44e30116
> > IP: [<c01e8b34>] ctrl_dumpfamily+0xa4/0xbc

> Thanks for reporting. I'm not in expert in interpreting these dumps,
> but it seems like there is no IPVS code in the trace, only the Generic
> Netlink functions? Thomas, is this correct?

Yes, the crash happens in ctrl_dumpfamily() which is not related
to the ipvs interface at all. I'm not familar with the new ipvadm
tool yet and whether it dumps the controller table but even if
does, this smells like a ipvs dump is being continued by calling
the wrong cb function. I have a similar report which may be related.
