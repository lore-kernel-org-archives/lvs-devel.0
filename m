From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [v2 PATCH 3/4] IPVS: Backup, Adding Version 1 receive capability
Date: Sat, 30 Oct 2010 13:49:14 +0200
Message-ID: <201010301349.14934.hans@schillstrom.com>
References: <1288354599-10919-3-git-send-email-hans.schillstrom@ericsson.com> <20101030064710.GJ26727@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101030064710.GJ26727@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, lvs-devel@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org, daniel.lezcano@free.fr


On Saturday, October 30, 2010 08:47:10 Simon Horman wrote:
> > *v2
> >  A new option format added as with opt,opt-len,data
> >  as a general way to add options to a conn entry.
> >  timeout is now in seconds
> >  fwmark is not in ip_vs_conn_param any more.
> >  Mask for flags received by backup.
> >  Basically all changes implements Julians comments.
> 
> 
> I think that you need the patch
> "IPVS: Add persistence engine to connection entry" that I posted,
> or something similar in your series in order for connection
> templates with created by synchronisation to have the correct
> persistence engine associated with them.
> 
Thanks
Yes I need that one.

[ snip ]
> 
> Please align line-wrapped parameters against the opening (
> 
> 	ip_vs_conn_fill_param(af, sc->protocol,
> 			      (const union nf_inet_addr *)&sc->caddr,
> 			      sc->cport,
> 			      (const union nf_inet_addr *)&sc->vaddr,
> 			      sc->vport, p);
> 
> Also several more times below.
> This also applies to function definitions.
> 
> Actually, I think p_vs_conn_fill_param_sync_v0() can be
> replaced by a direct call to ip_vs_conn_fill_param(). But
> my comments regarding formatting still apply elsewhere.
> 
I do agree

[ snip ]
> >  	return 0;
> >  }
> >  
> >  /*
> > - *      Process received multicast message and create the corresponding
> > - *      ip_vs_conn entries.
> > + *  fill_param used by version 1
> >   */
> 
> I realise that the commenting syntax used throughout IPVS
> is a) inconsistent and b) for the most part does not comply with
> any variant of the style guidelines. However, for the record
> I believe that the preferred commenting style for code in net/
> and thus IPVS is:
> 
> /* This is a one line comment */
> 
> /* This is a
>  * multi-line comment
>  */
> 
I'll do my home work and hold on tight to the coding rules :-)

[ snip ]
> > @@ -505,103 +626,214 @@ static void ip_vs_process_message(const char *buffer, const size_t buflen)
> >  			}
> >  		}
> >  
> > -		{
> > -			if (ip_vs_conn_fill_param_sync(AF_INET, s->protocol,
> > -					      (union nf_inet_addr *)&s->caddr,
> > -					      s->cport,
> > -					      (union nf_inet_addr *)&s->vaddr,
> > -					      s->vport, &param)) {
> > -				pr_err("ip_vs_conn_fill_param_sync failed");
> > -				return;
> > -			}
> > -			if (!(flags & IP_VS_CONN_F_TEMPLATE))
> > -				cp = ip_vs_conn_in_get(&param);
> > -			else
> > -				cp = ip_vs_ct_in_get(&param);
> > +		if (ip_vs_conn_fill_param_sync_v0(AF_INET, s, &param)) {
> > +			pr_err("ip_vs_conn_fill_param_sync failed");
> > +			return;
> >  		}
> 
> I think we can just replace this with a direct call to
> ip_vs_conn_fill_param() and avoid the need for error checking.
> 
> The idea of the existing ip_vs_conn_fill_param_sync() was as a place holder.
> But this patch fills in the relevant bits in the v1 version of that function.

OK I will have a look at this
[ snip ]

> > +
> > +	/* SyncID sanity check */
> > +	if (ip_vs_backup_syncid != 0 && m2->syncid != ip_vs_backup_syncid) {
> > +		IP_VS_DBG(7, "Ignoring incoming msg with syncid = %d\n",
> > +			  m2->syncid);
> > +		return;
> > +	}
> > +	/* Prepare ptrs for version 1 or 2 message */
> > +	if ( m2->version==SYNC_PROTO_VER && m2->reserverd==0 && m2->spare==0) {
> 
> There shouldn't be a space between '(' and 'm2'.
> There should be a space either side of each '=='.
OK 
I'll break the line
> 
> > +	       p = (char *)buffer + sizeof(struct ip_vs_sync_mesg_v2);
> 
> This cast seems nasty to me. Is it there to un-const buffer?
> If so I think it would be better just remove the const qualification
> from the parameter, as its clearly not being used in a const way.
> 
> The patch "IPVS: buffer argument to ip_vs_process_message() should not be const"
> from my prototype series was my attempt to address this.
> 
OK, 

Thanks
 Hans
