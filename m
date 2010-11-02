From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 2 Nov 2010 02:17:39 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011020209520.2485@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <201011011103.41004.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011012312550.1621@ja.ssi.bg> <201011012347.07074.hans@schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011012347.07074.hans@schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Mon, 1 Nov 2010, Hans Schillstrom wrote:

>> As for ip_vs_sync_conn_options
>> there is no app in mainline kernel 2.6.36+ that will trigger
>> this parameter. And we do not know (yet) how to sync SEQs with
>> Netfilter in the case for ip_vs_ftp.
>
> If we receive packets with ip_vs_sync_conn_options what shoud be done
> - dropt that single conn msg ? (My vote)
> or
> - ignore ip_vs_sync_conn_options and try to process the message ?
>
> I leave the "dead code"  in case it's needed later on.
> (except for Version 1 receive)

 	Why? Just copy data to cp->in_seq and cp->out_seq
as before but for version 1 make sure the values in
struct ip_vs_seq are sent in network order. If some APP
provides diff != 0 these SEQs will be sent.

Regards

--
Julian Anastasov <ja@ssi.bg>
