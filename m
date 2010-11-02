From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 2 Nov 2010 07:13:05 +0100
Message-ID: <201011020713.06154.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <201011012347.07074.hans@schillstrom.com> <alpine.LFD.2.00.1011020209520.2485@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1011020209520.2485@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans@schillstrom.com>, LVS-Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Tuesday 02 November 2010 01:17:39 Julian Anastasov wrote:
>
>  	Hello,
>
> On Mon, 1 Nov 2010, Hans Schillstrom wrote:
>
> >> As for ip_vs_sync_conn_options
> >> there is no app in mainline kernel 2.6.36+ that will trigger
> >> this parameter. And we do not know (yet) how to sync SEQs with
> >> Netfilter in the case for ip_vs_ftp.
> >
> > If we receive packets with ip_vs_sync_conn_options what shoud be done
> > - dropt that single conn msg ? (My vote)
> > or
> > - ignore ip_vs_sync_conn_options and try to process the message ?
> >
> > I leave the "dead code"  in case it's needed later on.
> > (except for Version 1 receive)
>
>  	Why? Just copy data to cp->in_seq and cp->out_seq
> as before but for version 1 make sure the values in
> struct ip_vs_seq are sent in network order. If some APP
> provides diff != 0 these SEQs will be sent.
>
OK, I'll do that
--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
