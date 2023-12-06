Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="ky+r5FZJ"
Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A4F94112;
	Wed,  6 Dec 2023 04:33:55 -0800 (PST)
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id 058A017AAD;
	Wed,  6 Dec 2023 14:33:51 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id DF4DB17AA4;
	Wed,  6 Dec 2023 14:33:50 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 5E83A3C0439;
	Wed,  6 Dec 2023 14:33:50 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1701866030; bh=Qx6bGY5zwKCukI64izDOo4jSKiZokAgYKMjEju4y7Xc=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=ky+r5FZJhNsSI8aZdpYuGwZY/NnJVOx5ruooFjSqB14C457Iyrt6DUGDlCrW+BCAp
	 Mf+m37WmEQt53Loth6p9nKxJf+NChZw+ADCVN+Klt03gjyQd7P67ilA45NS0Vh4hks
	 w/WtISkByQk/WLNeRCuKFdUcuzQcqlwxw0H3jwJ0=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 3B6CXlw6051933;
	Wed, 6 Dec 2023 14:33:48 +0200
Date: Wed, 6 Dec 2023 14:33:47 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Lev Pantiukhin <kndrvt@yandex-team.ru>
cc: mitradir@yandex-team.ru, Simon Horman <horms@verge.net.au>,
        linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
Subject: Re: [PATCH] ipvs: add a stateless type of service and a stateless
 Maglev hashing scheduler
In-Reply-To: <20231204152020.472247-1-kndrvt@yandex-team.ru>
Message-ID: <58b14269-4d81-8939-020e-c33ed70df483@ssi.bg>
References: <20231204152020.472247-1-kndrvt@yandex-team.ru>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 4 Dec 2023, Lev Pantiukhin wrote:

> +#define IP_VS_SVC_F_STATELESS	0x0040		/* stateless scheduling */

	I have another idea for the traffic that does not
need per-client state. We need some per-dest cp to forward the packet.
If we replace the cp->caddr usage with iph->saddr/daddr usage we can try 
it. cp->caddr is used at the following places:

- tcp_snat_handler (iph->daddr), tcp_dnat_handler (iph->saddr): iph is 
already provided. tcp_snat_handler requires IP_VS_SVC_F_STATELESS
to be set for serivce with present vaddr, i.e. non-fwmark based.
So, NAT+svc->fwmark is another restriction for IP_VS_SVC_F_STATELESS
because we do not know what VIP to use as saddr for outgoing traffic.

- ip_vs_nfct_expect_related
	- we should investigate for any problems when IP_VS_CONN_F_NFCT
	is set, probably, we can not work with NFCT?

- ip_vs_conn_drop_conntrack

- FTP:
	- sets IP_VS_CONN_F_NFCT, uses cp->app

	May be IP_VS_CONN_F_NFCT should be restriction for 
IP_VS_SVC_F_STATELESS mode? cp->app for sure because we keep TCP
seq/ack state for the app in cp->in_seq/out_seq.

	We can keep some dest->cp_route or another name that will
hold our cp for such connections. The idea is to not allocate cp for
every packet but to reuse this saved cp. It has all needed info to
forward skb to real server. The first packet will create it, save
it with some locking into dest and next packets will reuse it.

	Probably, it should be ONE_PACKET entry (not hashed in table) but 
can be with running timer, if needed. One refcnt for attaching to dest, 
new temp refcnt for every packet. But in this mode __ip_vs_conn_put_timer 
uses 0-second timer, we have to handle it somehow. It should be released
when dest is removed and on edit_dest if needed.

	There are other problems to solve, such as set_tcp_state()
changing dest->activeconns and dest->inactconns. They are used also
in ip_vs_bind_dest(), ip_vs_unbind_dest(). As we do not keep previous
connection state and as conn can start in established state, we should
avoid touching these counters. For UDP ONE_PACKET has no such problem
with states but for TCP/SCTP we should take care.

Regards

--
Julian Anastasov <ja@ssi.bg>

