From: juliusv@google.com (Julius Volz)
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Tue, 17 Jun 2008 19:18:41 +0200
Message-ID: <20080617171840.GB4064@google.com>
References: <f4845fc0806120834xd904f45x19e100c832d3417@mail.gmail.com> <485144DF.3030102@trash.net> <f4845fc0806121233i54099a18k9104eb34359b923f@mail.gmail.com> <20080613062621.GA10474@verge.net.au> <f4845fc0806130717v2e892707tee1e401b39dbab81@mail.gmail.com> <48528EED.7090307@trash.net> <f4845fc0806151714r515545b1l443200d3377b59ad@mail.gmail.com> <485652EA.2020004@trash.net> <f4845fc0806161619i4dc81dcao933d95aa6e09b45e@mail.gmail.com> <4857A58E.6080304@trash.net>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213723128; bh=Bgpi39cmsZ/zpPK1PbGsiZzv4+k=;
	h=DomainKey-Signature:Date:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 User-Agent:From; b=Mf2rtdMTs8dE1xANg9JYqJQ/oHQMLn6mz0Ai9P8SBtDLQyE
	/tyfjU4Fm+oc+iQzqjigzxDLTzVqG8co978Ntig==
Content-Disposition: inline
In-Reply-To: <4857A58E.6080304@trash.net>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: Simon Horman <horms@verge.net.au>, Vince Busam <vbusam@google.com>, Ben Greear <greearb@candelatech.com>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Tue, Jun 17, 2008 at 01:52:46PM +0200, Patrick McHardy wrote:
> Julius Volz wrote:
> >Btw., couldn't we change nla_nest_start() to always add NLA_F_NESTED
> >to the type?
> 
> The NLA_F_NESTED bit originated in nfnetlink, but was moved
> to netlink so the new netlink parsing helpers could also be
> used for nfnetlink. It can't be added to existing attributes
> since userspace needs to mask it out again to get the real
> attribute value and the non-nfnetlink userspace code doesn't
> expect it.
> 
> >2) To send an array of attributes of the same type, you just add them
> >serially? I was just confused at first that nla_parse() will save only
> >one attribute of each type (the last one) in the destination array, so
> >when dealing with arrays, it doesn't help. So I just iterate over the
> >array with nla_for_each_attr() and parse each element manually, right?
> 
> Exactly, net/8021q/vlan_netlink.c has two examples of this (the
> QoS mapping attributes).

Thanks for these explanations!

Ok, so this is my draft version of the IPVS Generic Netlink interface
definition. I'm posting this to see if anyone notices general problems
with it right away.

Arrays of the same attribute type are always put into a nested container
so that it is easy to add new attributes which are parallel to the array
later on. Perhaps integer flag fields should also be split up into
NLA_FLAG attributes, haven't done that yet.

First is a text listing attribute types and how they occur and nest in
all of the commands and their replies. After that are the corresponding
source excerpts (no patch material yet).

Julius


======================================
|    IPVS NETLINK ATTRIBUTE TYPES    |
|          (grouped as enums)        |
======================================

IPVS_ENTRY_ATTR_SERVICE		- NLA_NESTED
IPVS_ENTRY_ATTR_SERVICES	- NLA_NESTED
IPVS_ENTRY_ATTR_DEST		- NLA_NESTED
IPVS_ENTRY_ATTR_DESTS		- NLA_NESTED
IPVS_ENTRY_ATTR_DAEMON		- NLA_NESTED
IPVS_ENTRY_ATTR_DAEMONS		- NLA_NESTED

IPVS_SVC_ATTR_AF		- NLA_U32
IPVS_SVC_ATTR_PROTOCOL		- NLA_U32
IPVS_SVC_ATTR_ADDR		- union nf_inet_addr
IPVS_SVC_ATTR_PORT		- NLA_U16
IPVS_SVC_ATTR_FWMARK		- NLA_U32
IPVS_SVC_ATTR_SCHED_NAME	- NLA_STRING
IPVS_SVC_ATTR_FLAGS		- NLA_U32
IPVS_SVC_ATTR_TIMEOUT		- NLA_U32
IPVS_SVC_ATTR_NETMASK		- NLA_U32
IPVS_SVC_ATTR_NUM_DESTS		- NLA_U32
IPVS_SVC_ATTR_STATS		- NLA_NESTED

IPVS_DEST_ATTR_AF		- NLA_U32
IPVS_DEST_ATTR_ADDR		- union nf_inet_addr
IPVS_DEST_ATTR_PORT		- NLA_U16
IPVS_DEST_ATTR_CONN_FLAGS	- NLA_U32
IPVS_DEST_ATTR_WEIGHT		- NLA_U32
IPVS_DEST_ATTR_U_THRESH		- NLA_U32
IPVS_DEST_ATTR_L_THRESH		- NLA_U32
IPVS_DEST_ATTR_ACTIVE_CONNS	- NLA_U32
IPVS_DEST_ATTR_INACT_CONNS	- NLA_U32
IPVS_DEST_ATTR_PERSIST_CONNS	- NLA_U32
IPVS_DEST_ATTR_STATS		- NLA_NESTED

IPVS_STATS_ATTR_CONNS		- NLA_U32
IPVS_STATS_ATTR_INPKTS		- NLA_U32
IPVS_STATS_ATTR_OUTPKTS		- NLA_U32
IPVS_STATS_ATTR_INBYTES		- NLA_U64
IPVS_STATS_ATTR_OUTBYTES	- NLA_U64
IPVS_STATS_ATTR_CPS		- NLA_U32
IPVS_STATS_ATTR_INPPS		- NLA_U32
IPVS_STATS_ATTR_OUTPPS		- NLA_U32
IPVS_STATS_ATTR_INBPS		- NLA_U32
IPVS_STATS_ATTR_OUTBPS		- NLA_U32

IPVS_TIMEOUT_ATTR_TCP		- NLA_U32
IPVS_TIMEOUT_ATTR_TCP_FIN	- NLA_U32
IPVS_TIMEOUT_ATTR_UDP		- NLA_U32

IPVS_DAEMON_ATTR_STATE		- NLA_U32
IPVS_DAEMON_ATTR_MCAST_IFN	- NLA_STRING
IPVS_DAEMON_ATTR_SYNC_ID	- NLA_U32

IPVS_INFO_ATTR_VERSION		- NLA_U32
IPVS_INFO_ATTR_CONNTAB_SIZE	- NLA_U32
IPVS_INFO_ATTR_NUM_SERVICES	- NLA_U32


====================================================
|    ATTRIBUTES PASSED AS ARGUMENTS TO COMMANDS    |
====================================================

IPVS_CMD_ADD_SERVICE (with add/edit flag)
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK
		IPVS_SVC_ATTR_SCHED_NAME
		IPVS_SVC_ATTR_FLAGS
		IPVS_SVC_ATTR_TIMEOUT
		IPVS_SVC_ATTR_NETMASK

IPVS_CMD_DEL_SERVICE
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK

IPVS_CMD_ADD_DEST (with add/edit flag)
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK
	IPVS_ENTRY_ATTR_DEST
		IPVS_DEST_ATTR_AF
		IPVS_DEST_ATTR_ADDR
		IPVS_DEST_ATTR_PORT
		IPVS_DEST_ATTR_CONN_FLAGS
		IPVS_DEST_ATTR_WEIGHT
		IPVS_DEST_ATTR_U_THRESH
		IPVS_DEST_ATTR_L_THRESH

IPVS_CMD_DEL_DEST
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK
	IPVS_ENTRY_ATTR_DEST
		IPVS_DEST_ATTR_AF
		IPVS_DEST_ATTR_ADDR
		IPVS_DEST_ATTR_PORT

IPVS_CMD_FLUSH (no arguments)

IPVS_CMD_SET_TIMEOUT
	IPVS_TIMEOUT_ATTR_TCP
	IPVS_TIMEOUT_ATTR_TCP_FIN
	IPVS_TIMEOUT_ATTR_UDP

IPVS_CMD_START_DAEMON
	IPVS_ENTRY_ATTR_DAEMON
		IPVS_DAEMON_ATTR_STATE
		IPVS_DAEMON_ATTR_MCAST_IFN
		IPVS_DAEMON_ATTR_SYNC_ID

IPVS_CMD_STOP_DAEMON
	IPVS_ENTRY_ATTR_DAEMON
		IPVS_DAEMON_ATTR_STATE

IPVS_CMD_ZERO (no arguments)

IPVS_CMD_GET_INFO (no arguments)

IPVS_CMD_GET_SERVICES (no arguments)

IPVS_CMD_GET_SERVICE
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK

IPVS_CMD_GET_DESTS
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK

IPVS_CMD_GET_TIMEOUT (no arguments)

IPVS_CMD_GET_DAEMON (no arguments)

=====================================================
|    ATTRIBUTES RETURNED IN RESPONSE TO COMMANDS    |
=====================================================

IPVS_CMD_ADD_SERVICE (only return code)

IPVS_CMD_DEL_SERVICE (only return code)

IPVS_CMD_ADD_DEST (only return code)

IPVS_CMD_DEL_DEST (only return code)

IPVS_CMD_FLUSH (only return code)

IPVS_CMD_SET_TIMEOUT (only return code)

IPVS_CMD_START_DAEMON (only return code)

IPVS_CMD_STOP_DAEMON (only return code)

IPVS_CMD_ZERO (only return code)

IPVS_CMD_GET_INFO
	IPVS_INFO_ATTR_VERSION
	IPVS_INFO_ATTR_CONNTAB_SIZE
	IPVS_INFO_ATTR_NUM_SERVICES

IPVS_CMD_GET_SERVICES
	IPVS_ENTRY_ATTR_SERVICES
		IPVS_ENTRY_ATTR_SERVICES (array)
			IPVS_SVC_ATTR_AF
			IPVS_SVC_ATTR_PROTOCOL
			IPVS_SVC_ATTR_ADDR
			IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK
			IPVS_SVC_ATTR_SCHED_NAME
			IPVS_SVC_ATTR_FLAGS
			IPVS_SVC_ATTR_TIMEOUT
			IPVS_SVC_ATTR_NETMASK
			IPVS_SVC_ATTR_NUM_DESTS
			IPVS_SVC_ATTR_STATS

IPVS_CMD_GET_SERVICE
	IPVS_ENTRY_ATTR_SERVICE
		IPVS_SVC_ATTR_AF
		IPVS_SVC_ATTR_PROTOCOL
		IPVS_SVC_ATTR_ADDR
		IPVS_SVC_ATTR_PORT || IPVS_SVC_ATTR_FWMARK
		IPVS_SVC_ATTR_SCHED_NAME
		IPVS_SVC_ATTR_FLAGS
		IPVS_SVC_ATTR_TIMEOUT
		IPVS_SVC_ATTR_NETMASK
		IPVS_SVC_ATTR_NUM_DESTS
		IPVS_SVC_ATTR_STATS

IPVS_CMD_GET_DESTS
	IPVS_ENTRY_ATTR_DESTS
		IPVS_ENTRY_ATTR_DEST (array)
			IPVS_DEST_ATTR_AF
			IPVS_DEST_ATTR_ADDR
			IPVS_DEST_ATTR_PORT
			IPVS_DEST_ATTR_CONN_FLAGS
			IPVS_DEST_ATTR_WEIGHT
			IPVS_DEST_ATTR_U_THRESH
			IPVS_DEST_ATTR_L_THRESH
			IPVS_DEST_ATTR_ACTIVE_CONNS
			IPVS_DEST_ATTR_INACT_CONNS
			IPVS_DEST_ATTR_PERSIST_CONNS
			IPVS_DEST_ATTR_STATS

IPVS_CMD_GET_TIMEOUT
	IPVS_TIMEOUT_ATTR_TCP
	IPVS_TIMEOUT_ATTR_TCP_FIN
	IPVS_TIMEOUT_ATTR_UDP

IPVS_CMD_GET_DAEMON
	IPVS_ENTRY_ATTR_DAEMONS
		IPVS_ENTRY_ATTR_DAEMON (array)
			IPVS_DAEMON_ATTR_STATE
			IPVS_DAEMON_ATTR_MCAST_IFN
			IPVS_DAEMON_ATTR_SYNC_ID



========================== include/net/ip_vs.h ==========================

/*
 *
 * IPVS Generic Netlink interface definitions
 *
 */

/* Generic Netlink family info */

#define IPVS_GENL_NAME		"IPVS"
#define IPVS_GENL_VERSION	0x1

/* Generic Netlink command attributes */
enum {
	IPVS_CMD_UNSPEC = 0,
	IPVS_CMD_ADD_SERVICE,		/* add or modify service */
	IPVS_CMD_DEL_SERVICE,		/* delete service */
	IPVS_CMD_ADD_DEST,		/* add or modify destination */
	IPVS_CMD_DEL_DEST,		/* delete destination */
	IPVS_CMD_FLUSH,			/* flush all services and dests */
	IPVS_CMD_SET_TIMEOUT,		/* set TCP and UDP timeouts */
	IPVS_CMD_START_DAEMON,		/* start sync daemon */
	IPVS_CMD_STOP_DAEMON,		/* stop sync daemon */
	IPVS_CMD_ZERO,			/* zero all counters and stats */

	IPVS_CMD_GET_INFO,		/* get general IPVS info */
	IPVS_CMD_GET_SERVICES,		/* get list of all services */
	IPVS_CMD_GET_SERVICE,		/* get info about specific service */
	IPVS_CMD_GET_DESTS,		/* get list of all service dests */
	IPVS_CMD_GET_TIMEOUT,		/* get TCP and UDP timeouts */
	IPVS_CMD_GET_DAEMON,		/* get sync daemon status */
	__IPVS_CMD_MAX,
};

#define IPVS_CMD_MAX (__IPVS_CMD_MAX - 1)

/*
 * Attributes used in the first level of commands that maintain multiple entries
 * of the same element type (services, destinations, sync daemons)
 *
 * Arrays of the same attribute type are always nested in the plural version of
 * the attribute to allow adding attributes in parallel to the array later on
 */
enum {
	IPVS_ENTRY_ATTR_UNSPEC = 0,
	IPVS_ENTRY_ATTR_SERVICE,	/* nested service attribute */
	IPVS_ENTRY_ATTR_SERVICES,	/* nested service list attribute */
	IPVS_ENTRY_ATTR_DEST,		/* nested destination attribute */
	IPVS_ENTRY_ATTR_DESTS,		/* nested destination list attribute */
	IPVS_ENTRY_ATTR_DAEMON,		/* nested sync daemon attribute */
	IPVS_ENTRY_ATTR_DAEMONS,	/* nested sync daemon list attribute */
	__IPVS_ENTRY_ATTR_MAX,
};

#define IPVS_ENTRY_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)

/*
 * Attributes used to describe a service
 *
 * Used inside nested attribute IPVS_ENTRY_ATTR_SERVICE
 */
enum {
	IPVS_SVC_ATTR_UNSPEC = 0,
	IPVS_SVC_ATTR_AF,		/* address family */
	IPVS_SVC_ATTR_PROTOCOL,		/* virtual service protocol */
	IPVS_SVC_ATTR_ADDR,		/* virtual service address */
	IPVS_SVC_ATTR_PORT,		/* virtual service port */
	IPVS_SVC_ATTR_FWMARK,		/* firewall mark of service */

	IPVS_SVC_ATTR_SCHED_NAME,	/* name of scheduler */
	IPVS_SVC_ATTR_FLAGS,		/* virtual service flags */
	IPVS_SVC_ATTR_TIMEOUT,		/* persistent timeout */
	IPVS_SVC_ATTR_NETMASK,		/* persistent netmask */

	IPVS_SVC_ATTR_NUM_DESTS,	/* number of real servers in service */
	IPVS_SVC_ATTR_STATS,		/* nested attribute for service stats */
	__IPVS_SVC_ATTR_MAX,
};

#define IPVS_SVC_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)

/*
 * Attributes used to describe a destination (real server)
 *
 * Used inside nested attribute IPVS_ENTRY_ATTR_DEST
 */
enum {
	IPVS_DEST_ATTR_UNSPEC = 0,
	IPVS_DEST_ATTR_AF,		/* address family */
	IPVS_DEST_ATTR_ADDR,		/* real server address */
	IPVS_DEST_ATTR_PORT,		/* real server port */

	IPVS_DEST_ATTR_CONN_FLAGS,	/* connection flags */
	IPVS_DEST_ATTR_WEIGHT,		/* destination weight */

	IPVS_DEST_ATTR_U_THRESH,	/* upper threshold */
	IPVS_DEST_ATTR_L_THRESH,	/* lower threshold */

	IPVS_DEST_ATTR_ACTIVE_CONNS,	/* active connections */
	IPVS_DEST_ATTR_INACT_CONNS,	/* inactive connections */
	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */

	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
	__IPVS_DEST_ATTR_MAX,
};

#define IPVS_DEST_ATTR_MAX (__IPVS_DEST_ATTR_MAX - 1)

/*
 * Attributes describing a sync daemon
 *
 * Used inside nested attribute IPVS_ENTRY_ATTR_DAEMON
 */
enum {
	IPVS_DAEMON_ATTR_UNSPEC = 0,
	IPVS_DAEMON_ATTR_STATE,		/* sync daemon state (master/backup) */
	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
	__IPVS_DAEMON_ATTR_MAX,
};

#define IPVS_DAEMON_ATTR_MAX (__IPVS_DAEMON_ATTR_MAX - 1)

/*
 * Attributes used to describe service or destination entry statistics
 *
 * Used inside nested attributes IPVS_SVC_ATTR_STATS and IPVS_DEST_ATTR_STATS
 */
enum {
	IPVS_STATS_ATTR_UNSPEC = 0,
	IPVS_STATS_ATTR_CONNS,		/* connections scheduled */
	IPVS_STATS_ATTR_INPKTS,		/* incoming packets */
	IPVS_STATS_ATTR_OUTPKTS,	/* outgoing packets */
	IPVS_STATS_ATTR_INBYTES,	/* incoming bytes */
	IPVS_STATS_ATTR_OUTBYTES,	/* outgoing bytes */

	IPVS_STATS_ATTR_CPS,		/* current connection rate */
	IPVS_STATS_ATTR_INPPS,		/* current in packet rate */
	IPVS_STATS_ATTR_OUTPPS,		/* current out packet rate */
	IPVS_STATS_ATTR_INBPS,		/* current in byte rate */
	IPVS_STATS_ATTR_OUTBPS,		/* current out byte rate */
	__IPVS_STATS_ATTR_MAX,
};

#define IPVS_STATS_ATTR_MAX (__IPVS_STATS_ATTR_MAX - 1)

/* Attributes used in IPVS_CMD_SET_TIMEOUT and IPVS_CMD_GET_TIMEOUT commands */
enum {
	IPVS_TIMEOUT_ATTR_UNSPEC = 0,
	IPVS_TIMEOUT_ATTR_TCP,		/* TCP connection timeout */
	IPVS_TIMEOUT_ATTR_TCP_FIN,	/* TCP FIN wait timeout */
	IPVS_TIMEOUT_ATTR_UDP,		/* UDP timeout */
	__IPVS_TIMEOUT_ATTR_MAX,
};

#define IPVS_TIMEOUT_ATTR_MAX (__IPVS_TIMEOUT_ATTR_MAX - 1)

/* Attributes used in response to IPVS_CMD_GET_INFO command */
enum {
	IPVS_INFO_ATTR_UNSPEC = 0,
	IPVS_INFO_ATTR_VERSION,		/* IPVS version number */
	IPVS_INFO_ATTR_CONNTAB_SIZE,	/* size of connection hash table */
	IPVS_INFO_ATTR_NUM_SERVICES,	/* number of virtual services */
	__IPVS_INFO_ATTR_MAX,
};

#define IPVS_INFO_ATTR_MAX (__IPVS_INFO_ATTR_MAX - 1)

/* End of Generic Netlink interface definitions */

 

========================== net/ipv4/ipvs/ip_vs_ctl.c ==========================

/*
 *
 * IPVS Generic Netlink interface definitions
 *
 */

/* Generic Netlink family info */

#define IPVS_GENL_NAME		"IPVS"
#define IPVS_GENL_VERSION	0x1

/* Generic Netlink command attributes */
enum {
	IPVS_CMD_UNSPEC = 0,
	IPVS_CMD_ADD_SERVICE,		/* add or modify service */
	IPVS_CMD_DEL_SERVICE,		/* delete service */
	IPVS_CMD_ADD_DEST,		/* add or modify destination */
	IPVS_CMD_DEL_DEST,		/* delete destination */
	IPVS_CMD_FLUSH,			/* flush all services and dests */
	IPVS_CMD_SET_TIMEOUT,		/* set TCP and UDP timeouts */
	IPVS_CMD_START_DAEMON,		/* start sync daemon */
	IPVS_CMD_STOP_DAEMON,		/* stop sync daemon */
	IPVS_CMD_ZERO,			/* zero all counters and stats */

	IPVS_CMD_GET_INFO,		/* get general IPVS info */
	IPVS_CMD_GET_SERVICES,		/* get list of all services */
	IPVS_CMD_GET_SERVICE,		/* get info about specific service */
	IPVS_CMD_GET_DESTS,		/* get list of all service dests */
	IPVS_CMD_GET_TIMEOUT,		/* get TCP and UDP timeouts */
	IPVS_CMD_GET_DAEMON,		/* get sync daemon status */
	__IPVS_CMD_MAX,
};

#define IPVS_CMD_MAX (__IPVS_CMD_MAX - 1)

/*
 * Attributes used in the first level of commands that maintain multiple entries
 * of the same element type (services, destinations, sync daemons)
 *
 * Arrays of the same attribute type are always nested in the plural version of
 * the attribute to allow adding attributes in parallel to the array later on
 */
enum {
	IPVS_ENTRY_ATTR_UNSPEC = 0,
	IPVS_ENTRY_ATTR_SERVICE,	/* nested service attribute */
	IPVS_ENTRY_ATTR_SERVICES,	/* nested service list attribute */
	IPVS_ENTRY_ATTR_DEST,		/* nested destination attribute */
	IPVS_ENTRY_ATTR_DESTS,		/* nested destination list attribute */
	IPVS_ENTRY_ATTR_DAEMON,		/* nested sync daemon attribute */
	IPVS_ENTRY_ATTR_DAEMONS,	/* nested sync daemon list attribute */
	__IPVS_ENTRY_ATTR_MAX,
};

#define IPVS_ENTRY_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)

/*
 * Attributes used to describe a service
 *
 * Used inside nested attribute IPVS_ENTRY_ATTR_SERVICE
 */
enum {
	IPVS_SVC_ATTR_UNSPEC = 0,
	IPVS_SVC_ATTR_AF,		/* address family */
	IPVS_SVC_ATTR_PROTOCOL,		/* virtual service protocol */
	IPVS_SVC_ATTR_ADDR,		/* virtual service address */
	IPVS_SVC_ATTR_PORT,		/* virtual service port */
	IPVS_SVC_ATTR_FWMARK,		/* firewall mark of service */

	IPVS_SVC_ATTR_SCHED_NAME,	/* name of scheduler */
	IPVS_SVC_ATTR_FLAGS,		/* virtual service flags */
	IPVS_SVC_ATTR_TIMEOUT,		/* persistent timeout */
	IPVS_SVC_ATTR_NETMASK,		/* persistent netmask */

	IPVS_SVC_ATTR_NUM_DESTS,	/* number of real servers in service */
	IPVS_SVC_ATTR_STATS,		/* nested attribute for service stats */
	__IPVS_SVC_ATTR_MAX,
};

#define IPVS_SVC_ATTR_MAX (__IPVS_SVC_ATTR_MAX - 1)

/*
 * Attributes used to describe a destination (real server)
 *
 * Used inside nested attribute IPVS_ENTRY_ATTR_DEST
 */
enum {
	IPVS_DEST_ATTR_UNSPEC = 0,
	IPVS_DEST_ATTR_AF,		/* address family */
	IPVS_DEST_ATTR_ADDR,		/* real server address */
	IPVS_DEST_ATTR_PORT,		/* real server port */

	IPVS_DEST_ATTR_CONN_FLAGS,	/* connection flags */
	IPVS_DEST_ATTR_WEIGHT,		/* destination weight */

	IPVS_DEST_ATTR_U_THRESH,	/* upper threshold */
	IPVS_DEST_ATTR_L_THRESH,	/* lower threshold */

	IPVS_DEST_ATTR_ACTIVE_CONNS,	/* active connections */
	IPVS_DEST_ATTR_INACT_CONNS,	/* inactive connections */
	IPVS_DEST_ATTR_PERSIST_CONNS,	/* persistent connections */

	IPVS_DEST_ATTR_STATS,		/* nested attribute for dest stats */
	__IPVS_DEST_ATTR_MAX,
};

#define IPVS_DEST_ATTR_MAX (__IPVS_DEST_ATTR_MAX - 1)

/*
 * Attributes describing a sync daemon
 *
 * Used inside nested attribute IPVS_ENTRY_ATTR_DAEMON
 */
enum {
	IPVS_DAEMON_ATTR_UNSPEC = 0,
	IPVS_DAEMON_ATTR_STATE,		/* sync daemon state (master/backup) */
	IPVS_DAEMON_ATTR_MCAST_IFN,	/* multicast interface name */
	IPVS_DAEMON_ATTR_SYNC_ID,	/* SyncID we belong to */
	__IPVS_DAEMON_ATTR_MAX,
};

#define IPVS_DAEMON_ATTR_MAX (__IPVS_DAEMON_ATTR_MAX - 1)

/*
 * Attributes used to describe service or destination entry statistics
 *
 * Used inside nested attributes IPVS_SVC_ATTR_STATS and IPVS_DEST_ATTR_STATS
 */
enum {
	IPVS_STATS_ATTR_UNSPEC = 0,
	IPVS_STATS_ATTR_CONNS,		/* connections scheduled */
	IPVS_STATS_ATTR_INPKTS,		/* incoming packets */
	IPVS_STATS_ATTR_OUTPKTS,	/* outgoing packets */
	IPVS_STATS_ATTR_INBYTES,	/* incoming bytes */
	IPVS_STATS_ATTR_OUTBYTES,	/* outgoing bytes */

	IPVS_STATS_ATTR_CPS,		/* current connection rate */
	IPVS_STATS_ATTR_INPPS,		/* current in packet rate */
	IPVS_STATS_ATTR_OUTPPS,		/* current out packet rate */
	IPVS_STATS_ATTR_INBPS,		/* current in byte rate */
	IPVS_STATS_ATTR_OUTBPS,		/* current out byte rate */
	__IPVS_STATS_ATTR_MAX,
};

#define IPVS_STATS_ATTR_MAX (__IPVS_STATS_ATTR_MAX - 1)

/* Attributes used in IPVS_CMD_SET_TIMEOUT and IPVS_CMD_GET_TIMEOUT commands */
enum {
	IPVS_TIMEOUT_ATTR_UNSPEC = 0,
	IPVS_TIMEOUT_ATTR_TCP,		/* TCP connection timeout */
	IPVS_TIMEOUT_ATTR_TCP_FIN,	/* TCP FIN wait timeout */
	IPVS_TIMEOUT_ATTR_UDP,		/* UDP timeout */
	__IPVS_TIMEOUT_ATTR_MAX,
};

#define IPVS_TIMEOUT_ATTR_MAX (__IPVS_TIMEOUT_ATTR_MAX - 1)

/* Attributes used in response to IPVS_CMD_GET_INFO command */
enum {
	IPVS_INFO_ATTR_UNSPEC = 0,
	IPVS_INFO_ATTR_VERSION,		/* IPVS version number */
	IPVS_INFO_ATTR_CONNTAB_SIZE,	/* size of connection hash table */
	IPVS_INFO_ATTR_NUM_SERVICES,	/* number of virtual services */
	__IPVS_INFO_ATTR_MAX,
};

#define IPVS_INFO_ATTR_MAX (__IPVS_INFO_ATTR_MAX - 1)

/* End of Generic Netlink interface definitions */

/*
 * Generic Netlink definitions
 */

/* IPVS genetlink family*/
static struct genl_family ip_vs_genl_family = {
	.id		= GENL_ID_GENERATE,
	.hdrsize	= 0,
	.name		= IPVS_GENL_NAME,
	.version	= IPVS_GENL_VERSION,
	.maxattr	= IPVS_CMD_MAX
};

/*
 * Policy used for commands that operate on service, destination
 * or daemon entries
 */
static struct nla_policy ip_vs_entries_policy[IPVS_ENTRY_ATTR_MAX + 1]
__read_mostly = {
	[IPVS_ENTRY_ATTR_SERVICE]	= { .type = NLA_NESTED },
	[IPVS_ENTRY_ATTR_SERVICES]	= { .type = NLA_NESTED },
	[IPVS_ENTRY_ATTR_DEST]		= { .type = NLA_NESTED },
	[IPVS_ENTRY_ATTR_DESTS]		= { .type = NLA_NESTED },
	[IPVS_ENTRY_ATTR_DAEMON]	= { .type = NLA_NESTED },
	[IPVS_ENTRY_ATTR_DAEMONS]	= { .type = NLA_NESTED },
};

/* Policy used for IPVS_CMD_SET_TIMEOUT command attributes */
static struct nla_policy ip_vs_timeout_policy[IPVS_TIMEOUT_ATTR_MAX + 1]
__read_mostly = {
	[IPVS_TIMEOUT_ATTR_TCP]		= { .type = NLA_U32 },
	[IPVS_TIMEOUT_ATTR_TCP_FIN]	= { .type = NLA_U32 },
	[IPVS_TIMEOUT_ATTR_UDP]		= { .type = NLA_U32 },
};

/* Policy used for IPVS_CMD_SET_TIMEOUT command attributes */
static struct nla_policy ip_vs_daemon_policy[IPVS_DAEMON_ATTR_MAX + 1]
__read_mostly = {
	[IPVS_DAEMON_ATTR_STATE]	= { .type = NLA_U32 },
	[IPVS_DAEMON_ATTR_MCAST_IFN]	= { .type = NLA_STRING,
					    .len = IP_VS_IFNAME_MAXLEN },
	[IPVS_DAEMON_ATTR_SYNC_ID]	= { .type = NLA_U32 },
};

/* Policy used for attributes in nested attribute IPVS_ENTRY_ATTR_SERVICE */
static struct nla_policy ip_vs_svc_policy[IPVS_SVC_ATTR_MAX + 1]
__read_mostly = {
	[IPVS_SVC_ATTR_AF]		= { .type = NLA_U16 },
	[IPVS_SVC_ATTR_PROTOCOL]	= { .type = NLA_U32 },
	[IPVS_SVC_ATTR_ADDR]		= { .len = sizeof(union nf_inet_addr) },
	[IPVS_SVC_ATTR_PORT]		= { .type = NLA_U16 },
	[IPVS_SVC_ATTR_FWMARK]		= { .type = NLA_U32 },
	[IPVS_SVC_ATTR_SCHED_NAME]	= { .type = NLA_STRING,
					    .len = IP_VS_SCHEDNAME_MAXLEN },
	[IPVS_SVC_ATTR_FLAGS]		= { .type = NLA_U32 },
	[IPVS_SVC_ATTR_TIMEOUT]		= { .type = NLA_U32 },
	[IPVS_SVC_ATTR_NETMASK]		= { .type = NLA_U32 },
	[IPVS_SVC_ATTR_NUM_DESTS]	= { .type = NLA_U32 },
	[IPVS_SVC_ATTR_STATS]		= { .type = NLA_NESTED },
};

/* Policy used for attributes in nested attribute IPVS_ENTRY_ATTR_DEST */
static struct nla_policy ip_vs_dest_policy[IPVS_DEST_ATTR_MAX + 1]
__read_mostly = {
	[IPVS_DEST_ATTR_AF]		= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_ADDR]		= { .len = sizeof(union nf_inet_addr) },
	[IPVS_DEST_ATTR_PORT]		= { .type = NLA_U16 },
	[IPVS_DEST_ATTR_CONN_FLAGS]	= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_WEIGHT]		= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_U_THRESH]	= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_L_THRESH]	= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_ACTIVE_CONNS]	= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_INACT_CONNS]	= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_PERSIST_CONNS]	= { .type = NLA_U32 },
	[IPVS_DEST_ATTR_STATS]		= { .type = NLA_NESTED },
};

static struct genl_ops ip_vs_genl_ops[] __read_mostly = {
	/* SET commands */
	{
		.cmd	= IPVS_CMD_ADD_SERVICE,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_entries_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_DEL_SERVICE,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_entries_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_ADD_DEST,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_entries_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_DEL_DEST,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_entries_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_FLUSH,
		.flags	= GENL_ADMIN_PERM,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_SET_TIMEOUT,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_timeout_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_START_DAEMON,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_daemon_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_STOP_DAEMON,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_daemon_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_ZERO,
		.flags	= GENL_ADMIN_PERM,
		.doit	= NULL /* TODO */
	},

	/* GET commands */
	{
		.cmd	= IPVS_CMD_GET_INFO,
		.flags	= GENL_ADMIN_PERM,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_GET_SERVICES,
		.flags	= GENL_ADMIN_PERM,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_GET_SERVICE,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_entries_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_GET_DESTS,
		.flags	= GENL_ADMIN_PERM,
		.policy	= ip_vs_entries_policy,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_GET_TIMEOUT,
		.flags	= GENL_ADMIN_PERM,
		.doit	= NULL /* TODO */
	},
	{
		.cmd	= IPVS_CMD_GET_DAEMON,
		.flags	= GENL_ADMIN_PERM,
		.doit	= NULL /* TODO */
	},
};

/* End of Generic Netlink definitions */

