From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 1 Nov 2010 23:47:06 +0100
Message-ID: <201011012347.07074.hans@schillstrom.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <201011011103.41004.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011012312550.1621@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1011012312550.1621@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

On Monday, November 01, 2010 22:53:38 Julian Anastasov wrote:
> 
>  	Hello,
[ snip ]

> >>  	- lets drop the optional parameters from ip_vs_process_message()?
> >
> > I guess that you mean ip_vs_sync_conn_options,
> > in that case I do agree.
> 
>  	Not ip_vs_sync_conn_options but the support for
> accepting connection entries with unknown parameters,
> i.e. unknownOpt code. 

Yes, I will do that

> As for ip_vs_sync_conn_options
> there is no app in mainline kernel 2.6.36+ that will trigger
> this parameter. And we do not know (yet) how to sync SEQs with
> Netfilter in the case for ip_vs_ftp.

If we receive packets with ip_vs_sync_conn_options what shoud be done 
 - dropt that single conn msg ? (My vote)
or
 - ignore ip_vs_sync_conn_options and try to process the message ?

I leave the "dead code"  in case it's needed later on.
(except for Version 1 receive)

[ snip ]
> >> v2 PATCH 4/4
> >>  	May be we should add configuration option if sync is enabled
> >>  	to default to version 0 because how we solve the problem if
> >>  	backup can not be upgraded?
> >
> > That means that we need to have a "version 0 sending functions" as well.
> > I think that version 1 should be default, if you ran into problems activate ver 0.
> 
>  	I'm not sure how to solve this problem. I worry to
> leave users without option to sync to some old backups that can
> not be upgraded to new kernel. And if we have such config
> option it is not fatal if it defaults to 1. At least, it
> can be changed.

I have made the implementation already, at it did not become so many extra bytes.
It will be added as the last patch in the serie.

> 
> >>  	For IPVS_OPT_PE_NAME: because we have length better not to
> >>  	add zero terminator in sync message. It complicates the
> >>  	checks in backup. Or backup prefers to check with zero
> >>  	terminated string directly from message? In this case we
> >>  	should check for existing terminator.
> >
> > My hart says, don't use terminating Zeroes when there is a length but:
> > "Since there is no space to add a trailing Zero in the buffer
> > some changes has to be done. (I'm not going to make temp copy!)
> > Length param needs to be added to ip_vs_pe_get() and ip_vs_pe_getbyname()
> > which affects ip_vs_add_service() and  ip_vs_edit_service()"
> 
>  	May be adding pe_name_len argument to ip_vs_pe_getbyname
> is a better way.

Yes, I do agree.

> 
> > Leave it as is or remove the trailing Zero thats the question ?
> 
>  	With above method terminator is not needed.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

Regards
 Hans Schillstrom <hans@schillstrom.com>
