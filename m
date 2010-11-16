From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [*v4 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence support
Date: Tue, 16 Nov 2010 15:51:52 +0100
Message-ID: <201011161551.52744.hans.schillstrom@ericsson.com>
References: <201011151931.26789.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1011152346120.1987@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1011152346120.1987@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horms <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

On Monday 15 November 2010 23:29:11 Julian Anastasov wrote:
> 
>  	Hello,
> 
> On Mon, 15 Nov 2010, Hans Schillstrom wrote:
> 
> > This patch series adds/(updates) the following functionality
> > in the synchronization between master and backup daemons.
> >
> > - IPv6
> > - Persistence Engine
> > - Firewall marks transferred
> > - Time-outs transferred.
> > - Flag field increased to 32 bits.
> 
>  	Great work! I don't see other fatal problems. May be you
> can finally fix some grammatical and space problems and we can
> wait next weeks for comments about the new message format from
> other IPVS users. We also talked about checking if cp->pe
> matches cp->dest->svc->pe in ip_vs_find_dest(). Or may be it
> is already handled by the recent change that compares p->pe
> with cp->pe before calling ct_match in ip_vs_ct_in_get?

I do think it's handled by patch
 "Only match pe_data created by the same pe"

> 
> v4 PATCH 1/3
>  	- still the case for pe_data_len=0 and pe_name_len!=0 is
>  	not handled properly as error because we now ignore
>  	pe_name silently

Do you mean that IP_VS_DBG should be replaced ?

	if (pe_data_len) {
		if (pe_name_len) {
...
		} else {
			IP_VS_DBG(3, "BACKUP, Invalid PE parameters\n");
			return 1;
		}
to this ?
	...
			IP_VS_ERR_RL("BACKUP, Invalid PE parameters\n");
    ...
> 
> v4 PATCH 2/3
>  	ip_vs_sync_conn:
>  		- I now see that we can calculate the padding
>  		from previous message, so that we can skip
>  		sending padding after the last connection:

Done.

> 
>  		pad = (4 - (int) curr_sb->head) & 3;
> 
>  		then we should clear the data before message:
> 
>  		p = curr_sb->head;
>  		curr_sb->head += pad;
>  		while (pad--)
>  			*(p++) = 0;
>  		s = (union ip_vs_sync_conn *) p;
> 
>  		- Some checks are not needed, may be
>  		cp->pe_data_len is enough:
> 
>  		-if (cp->pe_data_len && cp->dest->svc && cp->pe && cp->pe->name)
>  		+if (cp->pe_data_len)

OK, I'll do that
i.e. we should accept the result of: "pe or name is null" as a BUG...

> 
> v4 PATCH 3/3
>  	OK
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
