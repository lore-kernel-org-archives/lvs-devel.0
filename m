From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 0/5] ipvs: fix backup sync daemon with IPv6, and minor
 updates
Date: Wed, 15 Jun 2016 22:52:22 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1606152209001.1950@ja.home.ssi.bg>
References: <1465914262-30112-1-git-send-email-quentin@armitage.org.uk>  <alpine.LFD.2.11.1606150815500.2828@ja.home.ssi.bg> <1465978975.2737.264.camel@samson1.armitage.org.uk>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1465978975.2737.264.camel@samson1.armitage.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Armitage <quentin@armitage.org.uk>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org


	Hello,

On Wed, 15 Jun 2016, Quentin Armitage wrote:

> I am updating the patches in line with your comments, but I'm not sure about
> a couple of points.
> 
> Patch 4:
> 
> You state that before bind(), such changes should be safe. However, from the
> function make_send_sock(), when the functions set_mcast_if(),
> set_mcast_loop(), set_mcast_ttl() and set_mcast_pmtudisc() are called before
> connect(), they all lock the socket before modifying it. Patch 4 was
> intended to make the setting of REUSE consistent.
> 
> If the locking is not necessary, would it be better to remove the locks from
> the set_mcast_...() functions referred to above.

	This is a slow path, so it does not matter much.
There is no concurrent access to the socket, the only
risk is some call into the stack that checks with lockdep
for the missing lock. Such example but for another lock
we already hold is ASSERT_RTNL in ip_mc_join_group. But for simple
sk vars lock is not needed. You can safely remove locks before
connect/bind if only sk fields are accessed directly.
We can keep it only in join_mcast_group*(), especially
because they are called after bind().

> Re patch 1 setting 'sock->sk->sk_bound_dev_if = ifindex;', I presume the
> locking should be consistent with what is done in the other functions.

	It is a simple var, so it can work without lock.

> Your comments on the above would be really helpful.
> 
> Patch 5:
> 
> You state 'The indentation of existing pr_info in both cases should not be
> changed". I'm not clear exactly what that means. Does it mean that the
> spaces at the beginning of the pr_info() strings which report group, port
> and ttl should be removed?

	No, here is example from your patch:

        pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
-               "syncid = %d, id = %d\n",
-               ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid, tinfo->id);
+                       "syncid = %d, id = %d, maxlen = %d\n",
+                       ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid,
+                       tinfo->id, ipvs->mcfg.sync_maxlen);

	"syncid = " was at the same column as "sync thread started",
you added another tab, may be to align with the args in new pr_info.
The result is:

	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
			"syncid = %d, id = %d, maxlen = %d\n",
			ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid,
			tinfo->id, ipvs->mcfg.sync_maxlen);
	<--- 2 TABs --->

	But it should be:

	pr_info("sync thread started: state = MASTER, mcast_ifn = %s, "
		"syncid = %d, id = %d, maxlen = %d\n",
		ipvs->mcfg.mcast_ifn, ipvs->mcfg.syncid,
		tinfo->id, ipvs->mcfg.sync_maxlen);
	< 1 TAB>

	Also, the new pr_info calls exceed 80 columns.
May be you can reduce the many spaces.

Regards
