From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Wed, 27 Oct 2010 11:19:20 +0200
Message-ID: <201010271119.21590.hans.schillstrom@ericsson.com>
References: <201010261300.09827.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010262331200.1928@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010262331200.1928@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "lvs-devel@vger.kernel.org" <lvs-devel@vger.kernel.org>, Daniel Lezcano <daniel.lezcano@free.fr>

Hello

On Tuesday 26 October 2010 23:25:10 Julian Anastasov wrote:
>
>  	Hello,
>
> On Tue, 26 Oct 2010, Hans Schillstrom wrote:
>
> > Type:  is one of this four
> > -IPv4
> > -IPv6
> > -IPv4 with PE data
> > -IPv6 with PE data
>
>  	I'm thinking of different way to provide parameters. If before
> now ip_vs_sync_conn_options uses cp->flags & IP_VS_CONN_F_SEQ_MASK
> to check for present data now we can allow optional parameters
> in such form:
>
> - 1 octet length to next parameter: N
> - 1 octet type: IPv4_Addresses, IPv6_Addresses, PE_Data, TCP_Seqs
> - N-2 octets for data
>
>  	The cost is 2 extra octets per parameter data and
> that alignment is 2 octets, we must use memcpy for the
> addresses.
>
I have no problem with that,
So you mean something like this ?

       0                   1                   2                   3
       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |    Type       |    Protocol   | Ver.  |        Size           |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                         Flags                                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |            State              |         cport                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |            vport              |         dport                 |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             fwmark                            |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             timeout                           |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                              ...                              |
      |                        IP-Addresses  (v4 or v6)               |
      |                              ...                              |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      +- Optional: ip_vs_cync_conn_options -+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                             init_seq                          |
      |                in_seq       delta                             |
      | __________________________  prev_delta ______________________ |
      |                             init_seq                          |
      |               out_seq       delta                             |
      |                             prev_delta                        |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Options header with alignment examples.
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      | Option Type   | Option length |    Option data                |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
      |                                                               |
      |               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |               | Opt padding   | Option Type   | Option length |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      |                 Opt data                                      |
      |                                                               |
      |               +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
      | Last Opt data |  Last option Padded to 32 bit alignment       |
      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

/* Option types */
#define IPVS_OPT_SEQ_DATA    1
#define IPVS_OPT_PE_DATA     2
#define IPVS_OPT_PE_NAME     3


>  	By this way later we can add more parameters. If we
> want master to specify that some parameter is optional
> we can allocate 1 bit (bit 7) in 'type' for this. Most
> of the parameters must be supported by backup server.
> If backup does not recognize some type it will skip the
> connection entry if bit 7 is not set.
>
A New Spec of Type field:

Bit    7        6        . . .      2         1           0
  +----------+--------------------------+-------------+-------+
  | Opt.Data |          Spare           | Packed IPv6 |  IPv6 |
  +----------+--------------------------+-------------+-------+

>  	While parsing the parameters we can set some bits
> in local var to detect what params are received: only one of
> IPv4_Addresses and IPv6_Addresses, etc.
>
>  	FWMARK can be added in this way but may be it
> is better to be in the mandatory structure.
>

I think we should leave it in the struct as mandatory,
the code will be messy if everything is options :-)

>  	The only problem is that it is difficult to
> predict the entry size in ip_vs_sync_conn().
>
>  	Also, we should add new define that will mask
> all connection flags not supported by backup. Currently,
> only IP_VS_CONN_F_HASHED is ignored:
>
> #define IP_VS_CONN_F_BACKUP_MASK (IP_VS_CONN_F_FWD_MASK | \
>  				IP_VS_CONN_F_NOOUTPUT | \
>  				IP_VS_CONN_F_INACTIVE | \
>  				IP_VS_CONN_F_SEQ_MASK | \
>  				IP_VS_CONN_F_NO_CPORT | \
>  				IP_VS_CONN_F_TEMPLATE | \
>  				)
>
>  	may be IP_VS_CONN_F_ONE_PACKET does not need to
> be used in backup and master does not need to sync it.
>

I do agree

> > Ver.  Version of specified type right now it's 0
> >
> > fwmark:  Firewall mark from skb.
>
>  	Is it really needed fwmark to be added in
> struct ip_vs_conn_param? May be adding new argument just
> to ip_vs_conn_new is enough?
>

OK

> > timeout: from ip_vs_conn struct.
>
>  	May be timeout must be in seconds, in case both
> boxes use different HZ.

Yeah, you are right.

>
> > PATCH STATUS:
> > - Persistence data is not tested.
> >
> > QUESTIONS:
> > In ip_vs_nfct.c
> > ip_vs_conn_fill_param()  fwmark is set to 0,
> > Do we need to digg for it there ?
> > (It is a callback from ct ..)
>
>  	There is no ip_vs_conn_new in ip_vs_nfct.c, so it will
> be simpler if fwmark is not added to struct ip_vs_conn_param

Sure, I'll do that-

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>
>

--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
