From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [*v4 PATCH 0/3] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Tue, 16 Nov 2010 00:29:11 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011152346120.1987@ja.ssi.bg>
References: <201011151931.26789.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011151931.26789.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horms <horms@verge.net.au>, LVS-Devel <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>


 	Hello,

On Mon, 15 Nov 2010, Hans Schillstrom wrote:

> This patch series adds/(updates) the following functionality
> in the synchronization between master and backup daemons.
>
> - IPv6
> - Persistence Engine
> - Firewall marks transferred
> - Time-outs transferred.
> - Flag field increased to 32 bits.

 	Great work! I don't see other fatal problems. May be you
can finally fix some grammatical and space problems and we can
wait next weeks for comments about the new message format from
other IPVS users. We also talked about checking if cp->pe
matches cp->dest->svc->pe in ip_vs_find_dest(). Or may be it
is already handled by the recent change that compares p->pe
with cp->pe before calling ct_match in ip_vs_ct_in_get?

v4 PATCH 1/3
 	- still the case for pe_data_len=0 and pe_name_len!=0 is
 	not handled properly as error because we now ignore
 	pe_name silently

v4 PATCH 2/3
 	ip_vs_sync_conn:
 		- I now see that we can calculate the padding
 		from previous message, so that we can skip
 		sending padding after the last connection:

 		pad = (4 - (int) curr_sb->head) & 3;

 		then we should clear the data before message:

 		p = curr_sb->head;
 		curr_sb->head += pad;
 		while (pad--)
 			*(p++) = 0;
 		s = (union ip_vs_sync_conn *) p;

 		- Some checks are not needed, may be
 		cp->pe_data_len is enough:

 		-if (cp->pe_data_len && cp->dest->svc && cp->pe && cp->pe->name)
 		+if (cp->pe_data_len)

v4 PATCH 3/3
 	OK

Regards

--
Julian Anastasov <ja@ssi.bg>
