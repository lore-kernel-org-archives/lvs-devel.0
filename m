From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Wed, 27 Oct 2010 00:25:10 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1010262331200.1928@ja.ssi.bg>
References: <201010261300.09827.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201010261300.09827.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>


 	Hello,

On Tue, 26 Oct 2010, Hans Schillstrom wrote:

> Type:  is one of this four
> -IPv4
> -IPv6
> -IPv4 with PE data
> -IPv6 with PE data

 	I'm thinking of different way to provide parameters. If before
now ip_vs_sync_conn_options uses cp->flags & IP_VS_CONN_F_SEQ_MASK
to check for present data now we can allow optional parameters
in such form:

- 1 octet length to next parameter: N
- 1 octet type: IPv4_Addresses, IPv6_Addresses, PE_Data, TCP_Seqs
- N-2 octets for data

 	The cost is 2 extra octets per parameter data and
that alignment is 2 octets, we must use memcpy for the
addresses.

 	By this way later we can add more parameters. If we
want master to specify that some parameter is optional
we can allocate 1 bit (bit 7) in 'type' for this. Most
of the parameters must be supported by backup server.
If backup does not recognize some type it will skip the
connection entry if bit 7 is not set.

 	While parsing the parameters we can set some bits
in local var to detect what params are received: only one of
IPv4_Addresses and IPv6_Addresses, etc.

 	FWMARK can be added in this way but may be it
is better to be in the mandatory structure.

 	The only problem is that it is difficult to
predict the entry size in ip_vs_sync_conn().

 	Also, we should add new define that will mask
all connection flags not supported by backup. Currently,
only IP_VS_CONN_F_HASHED is ignored:

#define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
 				IP_VS_CONN_F_NOOUTPUT | \
 				IP_VS_CONN_F_INACTIVE | \
 				IP_VS_CONN_F_SEQ_MASK | \
 				IP_VS_CONN_F_NO_CPORT | \
 				IP_VS_CONN_F_TEMPLATE | \
 				)

 	may be IP_VS_CONN_F_ONE_PACKET does not need to
be used in backup and master does not need to sync it.

> Ver.  Version of specified type right now it's 0
>
> fwmark:  Firewall mark from skb.

 	Is it really needed fwmark to be added in
struct ip_vs_conn_param? May be adding new argument just
to ip_vs_conn_new is enough?

> timeout: from ip_vs_conn struct.

 	May be timeout must be in seconds, in case both
boxes use different HZ.

> PATCH STATUS:
> - Persistence data is not tested.
>
> QUESTIONS:
> In ip_vs_nfct.c
> ip_vs_conn_fill_param()  fwmark is set to 0,
> Do we need to digg for it there ?
> (It is a callback from ct ..)

 	There is no ip_vs_conn_new in ip_vs_nfct.c, so it will
be simpler if fwmark is not added to struct ip_vs_conn_param

Regards

--
Julian Anastasov <ja@ssi.bg>
