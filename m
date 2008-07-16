From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Wed, 16 Jul 2008 14:15:24 +0200
Message-ID: <20080716121524.GZ20815@postel.suug.ch>
References: <1215616317-11386-1-git-send-email-juliusv@google.com> <1215616317-11386-3-git-send-email-juliusv@google.com> <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com> <20080710113649.GS20815@postel.suug.ch> <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com> <20080710144131.GU20815@postel.suug.ch> <f4845fc0807100813o65dee75bgfc53a395dccf74f6@mail.gmail.com> <20080710211630.GW20815@postel.suug.ch> <f4845fc0807101616r1f383e7dx5d85cb3c2dfbed57@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0807101616r1f383e7dx5d85cb3c2dfbed57@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au, davem@davemloft.net

* Julius Volz <juliusv@google.com> 2008-07-11 01:16
> If a single operation just means create _or_ update (NLM_F_EXCL, etc.
> flags don't work with genetlink), then ipvsadm would have to query for
> an entry first, which is racy and ugly. So I'd like to keep ADD/EDIT
> in separate commands. But then I need a different response id (or just
> use the ADD id?) for a GET.

That's fine, both methods a) adding your own NLM_F_ flags to genetlink
and b) using separate commands would be straight forward and easy to
understand. 

The key point is that a GET or DUMP request should be answered with
one or more NEW requests. An ADD, SET, or DEL request should be simply
ACKed or aborted with an error message. Optionally it can trigger a
notification message which should be either a NEW or DEL request.

Using SET to explicitely update an object is fine as well. The reason we
are not using it in the context of notifications is that listeners can
appear at any time so the listener may not have been around at the time
the object was created.

Anyways, it's not a requirement, just common patterns we have been
using so far.
