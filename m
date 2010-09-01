From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2.6.36-rc2 RFC] ipvs: Netfilter connection tracking
 changes
Date: Wed, 1 Sep 2010 11:12:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.1009011012460.5403@u.domain.uli>
References: <Pine.LNX.4.58.1009010142350.21284@u.domain.uli>
 <20100901043006.GB15123@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20100901043006.GB15123@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, Hannes Eder <heder@google.com>


	Hello,

On Wed, 1 Sep 2010, Simon Horman wrote:

> > 	Simon, this patch is against 2.6.36-rc2, I tested it
> > for IPv4. In fact, it is ready for inclusion in net-next but
> > I'm not sure if it applies properly.
> 
> I can fix that if you prefer.

	Yes, please. Check if it applies and fix any conflicts.
But let's first see what changes to what kernels should go
and what flags will be used, see below.

> > After first comments we can
> > move the discussion to netdev. The snat_reroute part can be
> > separated, if needed at all.
> 
> I'd prefer a separate patch.

	Yes, I'll do it

> > Also, IP_VS_CONN_F_NFCT can be
> > added to ipvsadm as real server option.
> 
> I can handle ipvsadm patches these days.
> I can even make the patch if you'd prefer.

	Yes, please. I worry that flags in struct ip_vs_conn
are u16, we are reaching the limit. In real server it is 4 bytes,
in struct ip_vs_dest conn_flags is atomic_t, I'm not sure how many
bits we can use there. The problem is that struct ip_vs_sync_conn
has 16-bit flags and we can not change it. May be we should
be more careful about flags that are useful for sync. Others
should not be added in cp->flags, may be in cp->local_flags.

	For example, we should decide where to put IP_VS_CONN_F_NFCT.
For now, IP_VS_CONN_F_HASHED can be excluded and this bit
can be used for other flag that needs syncing. But such
change for IP_VS_CONN_F_HASHED is incompatible (the flag
is ignored in backup server), so this flag should be occupied
when all other 15 bits are occupied.

	Even IP_VS_CONN_F_NFCT does not need to be sync-ed
because the backup server can use its own flags. It can use
"conntrack" flag, real server flags, even ip_vs_ftp
enables conntracking for its own connections. So, I think,
IP_VS_CONN_F_NFCT can go to cp->local_flags. Or better,
first 16 bits to be used for sync, other local flags to
be added from 16 above (after changing cp->flags to 4 bytes).
This will not change the way we get flags from user space.

> > The two problems
> > in ip_vs_ftp can be also fixed in next 2.6.36-rc kernels.
> 
> Yes, as they are regressions since 2.6.35 please break those changes out
> into one or two separate patches so they can be submitted for inclusion in
> 2.6.36.

	OK

> > May be Hannes Eder can comment if he can see these problems.
> > But I worry that this full patch is needed for 2.6.36
> > because not all systems use netfilter conntrack and are
> > not tuned for many conntracks. Now 2.6.36 can come as
> > surprise to them because IPVS requires Netfilter connection
> > tracking support.
> 
> Unfortunately I think its too late to get the bulk of this into 2.6.36.
> Are you concerned about a performance problem? Even when
> Hannes's new features aren't used? Is the snat_reroute flag a
> solution/workaround? If so we could try to get that into 2.6.36,
> although I'm not sure how well it would be received.

	snat_reroute is not related to NFCT, it helps only
for performance. It is for 2.6.37.

	Hannes's new features bring connection tracking even
for LVS-DR, not only for FTP. For some setups with large
nf_conntrack_max the difference should be only in performance.
And of course, IPVS is 160 bytes and conntrack is 200 bytes,
the space in memory for connections is decreased more than twice.
Only tests can prove if performance is increased when
conntracks are kept or when destroyed for every connection.
I can not test the performance difference properly in my
test setup. For some systems the increased memory for
conntracks can play role too.

Here is the picture:

Connection tracking for LVS-DR, LVS-TUN:
	2.6.35: No conntracks (destroyed for every packet)
	Hannes 2.6.36-rc: Yes, conntrack enforced for all conns, 
		conntracks stay in SYN_RECV state if
		forward_shared is not used
	My patch: conntrack is optional, depends on sysctl.
		If disabled, conntracks are destroyed for every
		packet.

Connection tracking for LVS-NAT, ip_vs_ftp for example:
	2.6.35: No conntracks (destroyed for every packet)
	Hannes 2.6.36-rc: Yes, conntracks in correct state
	My patch: Yes, conntracks in correct state. If
		sysctl "conntrack" is not set, only ip_vs_ftp
		conns use connection tracking, all other LVS-NAT
		and other methods do not keep conntracks.

	BTW, I didn't tested connection tracking support
combined with NAT rules, I don't know what kind of
NAT some users apply for the IPVS connections. My tests
were only for -m state matching, FTP connections:

- LVS-NAT (Local Process too)
- LVS-DR
- LVS-TUN

Regards

--
Julian Anastasov <ja@ssi.bg>
