From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: Remove duplicated rcu_read_lock.
Date: Wed, 24 May 2017 15:25:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705241508270.9575@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Taehee Yoo <ap420073@gmail.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, lvs-devel@vger.kernel.org


	Hello,

	The IPVS part from patch looks good but can be extended
to also remove rcu_read_lock and rcu_read_unlock from:

1. all app_conn_bind methods because ip_vs_bind_app() is called
always under RCU lock from ip_vs_try_bind_dest() and ip_vs_conn_new().
I.e. from sctp_app_conn_bind, tcp_app_conn_bind and udp_app_conn_bind.

2. ip_vs_xmit.c, all locks

	IMHO, using comments instead of locks is not needed, it is
enough that the commit message explains why RCU locks are removed

	More details:

In IPVS we have the following contexts:
- packet RX/TX: does not need locks because packets come from hooks
- sync msg RX: backup server uses RCU locks while registering new conns
- ip_vs_ctl.c: configuration get/set, RCU locks needed
- xt_ipvs.c: It is a NF match

As result, rcu_read_lock and rcu_read_unlock can be removed from:
- ip_vs_core.c: all
- ip_vs_ctl.c:
	- from ip_vs_has_real_service
	- all other places need the RCU locking
- ip_vs_ftp.c: all
- ip_vs_proto_sctp.c: all
- ip_vs_proto_tcp.c: all
- ip_vs_proto_udp.c: all
- ip_vs_xmit.c: all (contains only packet processing)

Locks should remain in:
- ip_vs_conn.c
- ip_vs_pe.c
- ip_vs_sync.c

Regards

--
Julian Anastasov <ja@ssi.bg>
