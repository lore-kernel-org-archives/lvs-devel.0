From: Andrew Kim <kim.andrewsy@gmail.com>
Subject: Re: [PATCHv2 net-next] ipvs: queue delayed work to expire no
 destination connections if expire_nodest_conn=1
Date: Wed, 8 Jul 2020 12:14:38 -0400
Message-ID: <CABc050E9F2=g95eogkZPoh6NPTKZaL3SRt6mYA=8aL8iPkO6mg@mail.gmail.com>
References: <alpine.LFD.2.23.451.2007081847310.3373@ja.home.ssi.bg>
 <20200708160618.13013-1-kim.andrewsy@gmail.com> <20200708161245.GB14873@salvia>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JrrGDnvTwQQpCDyz7V+eXlis568H+dx//YDRvtMgaRk=;
        b=TgzsOD0mVl94q884+wc1OCspl0e/zwgiFV3RTRQYd64GxQXyhP7vDp/fiya43JBD3R
         W0niatKqu+1Q6Akdy+eP+gPWg2zVkIOx0GTFdP96ack1aevHfsjtvKtYFuhSua/Bd5iV
         Tk/IXf77ZlPvtqWBNDBvVfVg3IGBsAofX0rtN/OgJmo0P41PpmwjFyidaV5rM+LS7klJ
         ZETAnDTxScxih4oPRk+jKMgneAJGStf9XG5W2RwR63/XyGViv9UL2iiwRsODtmU1FhAc
         lDrkJEQe37zV5U66hk7qs+an6Kqu5gNpbFjMptA121FB3Ie+EE3xL7VCd7jNZXQEGw7i
         cBmg==
In-Reply-To: <20200708161245.GB14873@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, "open list:IPVS" <lvs-devel@vger.kernel.org>, "open list:NETFILTER" <netfilter-devel@vger.kernel.org>

Sorry -- I think I misunderstood what Julian said. Nothing has changed
aside from some formatting on the patch file.

Will resend this patch with the v2 in the subject removed.


On Wed, Jul 8, 2020 at 12:12 PM Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>
> On Wed, Jul 08, 2020 at 12:06:18PM -0400, Andrew Sy Kim wrote:
> > When expire_nodest_conn=1 and a destination is deleted, IPVS does not
> > expire the existing connections until the next matching incoming packet.
> > If there are many connection entries from a single client to a single
> > destination, many packets may get dropped before all the connections are
> > expired (more likely with lots of UDP traffic). An optimization can be
> > made where upon deletion of a destination, IPVS queues up delayed work
> > to immediately expire any connections with a deleted destination. This
> > ensures any reused source ports from a client (within the IPVS timeouts)
> > are scheduled to new real servers instead of silently dropped.
>
> Is this the same patch ?
>
> https://patchwork.ozlabs.org/project/netfilter-devel/patch/20200708135854.28944-1-kim.andrewsy@gmail.com/
>
> Julian has "Signed-off-by:" previous patch and this v2 does not say
> what has been updated.
>
> Thanks.
