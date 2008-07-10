From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Thu, 10 Jul 2008 16:41:31 +0200
Message-ID: <20080710144131.GU20815@postel.suug.ch>
References: <1215616317-11386-1-git-send-email-juliusv@google.com> <1215616317-11386-3-git-send-email-juliusv@google.com> <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com> <20080710113649.GS20815@postel.suug.ch> <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

* Julius Volz <juliusv@google.com> 2008-07-10 14:33
> Ah, this is how the family's attrbuf size is set. Looks like a bug
> actually, but it hasn't affected anything because the command enum is
> bigger than any of the first-level attribute enums. I might have
> gotten this from net/irda/irnetlink.c, where it's also set to the
> maximum command attribute value.

Thanks for the note, I will fix that.

> Note that I use different first level attributes depending on the
> command. Rather than calculating the largest needed size, it's
> probably best to join all attributes that may ever occur in the first
> level into one big enum, right?

Yes, that's the easiest solution and it doesn't really cost you
anything besides the slightly bigger allocation.

> > Typically, netlink code follows the following semantics WRT to
> > commands/message types:
> > -> GET_SERVICE (NLM_F_DUMP)
> > <- NEW_SERVICE
> > <- NEW_SERVICE
> > <- NEW_SERVICE
> 
> Ok, so I will set the answer message type to IPVS_CMD_NEW_SERVICE (and
> accordingly in the other dump cases). For non-dump GET commands, is it
> usual to have the response ID be the same as the request?

It should follow the same semantics as with dumps. Netlink is typically
used in an object context, where objects are requested, added or deleted. 
Basically, a dump is a request to fill the userspace listening part with
all objects of the specified type. genetlink is a bit special as it
moved away from the traditional 4 commands per family (get, new, set,
delete) but in a case like IPVS where you are in fact managing objects
it does make sense to stick to the known semantics.
