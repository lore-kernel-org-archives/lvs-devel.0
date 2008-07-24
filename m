From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPVS: Move userspace definitions to	include/linux/ip_vs.h
Date: Thu, 24 Jul 2008 13:22:34 +0200
Message-ID: <488865FA.4040002@trash.net>
References: <1216894489-13060-1-git-send-email-juliusv@google.com> <20080724111434.GA30382@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20080724111434.GA30382@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Simon Horman <horms@verge.net.au>
Cc: Julius Volz <juliusv@google.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, davem@davemloft.net, vbusam@google.com

Simon Horman wrote:
> On Thu, Jul 24, 2008 at 12:14:49PM +0200, Julius Volz wrote:
>> Current versions of ipvsadm include "/usr/src/linux/include/net/ip_vs.h"
>> directly. This file also contains kernel-only definitions. Normally, public
>> definitions should live in include/linux, so this patch moves the
>> definitions shared with userspace to a new file, "include/linux/ip_vs.h".
>>
>> To make old ipvsadms still compile with this, the old header file includes
>> the new one.
>>
>> Thanks to Dave Miller and Horms for noting/adding the missing Kbuild entry
>> for the new header file.
>>
>> Signed-off-by: Julius Volz <juliusv@google.com>
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
>> ---
>> +/* Move it to better place one day, for now keep it unique */
>> +#define NFC_IPVS_PROPERTY	0x10000

Does this have any connection to the skb flag? If so, does
it really belong in the userspace interface?

>> +struct ip_vs_service_user {
>> +	/* virtual service addresses */
>> +	u_int16_t		protocol;
>> +	__be32			addr;		/* virtual ip address */
>> +	__be16			port;

If you switch the above two you plug two holes in the struct.

>> +	u_int32_t		fwmark;		/* firwall mark of service */
>> +
>> +	/* virtual service options */
>> +	char			sched_name[IP_VS_SCHEDNAME_MAXLEN];
>> +	unsigned		flags;		/* virtual service flags */
>> +	unsigned		timeout;	/* persistent timeout in sec */
>> +	__be32			netmask;	/* persistent netmask */
>> +};
>> +
>> +
>> +struct ip_vs_dest_user {
>> +	/* destination server address */
>> +	__be32			addr;
>> +	__be16			port;

This also leaves a hole, you should make sure its zeroed explicitly
to avoid leaking information to userspace.

>> +
>> +	/* real server options */
>> +	unsigned		conn_flags;	/* connection flags */
>> +	int			weight;		/* destination weight */
>> +
>> +	/* thresholds for active connections */
>> +	u_int32_t		u_threshold;	/* upper threshold */
>> +	u_int32_t		l_threshold;	/* lower threshold */
>> +};
>> +
>> +
>> +/*
>> + *	IPVS statistics object (for user space)
>> + */
>> +struct ip_vs_stats_user
>> +{
>> +	__u32                   conns;          /* connections scheduled */
>> +	__u32                   inpkts;         /* incoming packets */
>> +	__u32                   outpkts;        /* outgoing packets */
>> +	__u64                   inbytes;        /* incoming bytes */
>> +	__u64                   outbytes;       /* outgoing bytes */

Putting the u64s first would also plug a hole.

>> +
>> +	__u32			cps;		/* current connection rate */
>> +	__u32			inpps;		/* current in packet rate */
>> +	__u32			outpps;		/* current out packet rate */
>> +	__u32			inbps;		/* current in byte rate */
>> +	__u32			outbps;		/* current out byte rate */
>> +};
>> +
>> +
>> +/* The argument to IP_VS_SO_GET_INFO */
>> +struct ip_vs_getinfo {
>> +	/* version number */
>> +	unsigned int		version;
>> +
>> +	/* size of connection hash table */
>> +	unsigned int		size;
>> +
>> +	/* number of virtual services */
>> +	unsigned int		num_services;
>> +};
>> +
>> +
>> +/* The argument to IP_VS_SO_GET_SERVICE */
>> +struct ip_vs_service_entry {
>> +	/* which service: user fills in these */
>> +	u_int16_t		protocol;
>> +	__be32			addr;		/* virtual address */
>> +	__be16			port;

Same as above.

>> +	u_int32_t		fwmark;		/* firwall mark of service */
>> +
>> +	/* service options */
>> +	char			sched_name[IP_VS_SCHEDNAME_MAXLEN];
>> +	unsigned		flags;          /* virtual service flags */
>> +	unsigned		timeout;	/* persistent timeout */
>> +	__be32			netmask;	/* persistent netmask */
>> +
>> +	/* number of real servers */
>> +	unsigned int		num_dests;
>> +
>> +	/* statistics */
>> +	struct ip_vs_stats_user stats;
>> +};
>> +
>> +
>> +struct ip_vs_dest_entry {
>> +	__be32			addr;		/* destination address */
>> +	__be16			port;

Also a hole that should be cleared.

>> +	unsigned		conn_flags;	/* connection flags */
>> +	int			weight;		/* destination weight */
>> +
>> +	u_int32_t		u_threshold;	/* upper threshold */
>> +	u_int32_t		l_threshold;	/* lower threshold */
>> +
>> +	u_int32_t		activeconns;	/* active connections */
>> +	u_int32_t		inactconns;	/* inactive connections */
>> +	u_int32_t		persistconns;	/* persistent connections */
>> +
>> +	/* statistics */
>> +	struct ip_vs_stats_user stats;

You might also have a hole before stats since it has 8b alignment.
I'd suggest to use pahole to figure out which structs need to be
restructured.

>> ...

