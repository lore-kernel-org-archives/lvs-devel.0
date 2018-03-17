From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/6] Converting pernet_operations
	(part #8)
Date: Sat, 17 Mar 2018 17:07:57 -0400 (EDT)
Message-ID: <20180317.170757.485564313326587221.davem@davemloft.net>
References: <152110491273.28582.13804059107038714030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <152110491273.28582.13804059107038714030.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
To: ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, wensong-ud5FBsm0p/xg9hUCZPvPmw@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, jchapman-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ja-FgGsKACvmQM@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, amine.kherbouche-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, g.nault-pHk1y4uTXVDytLWWfqlThQ@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org

From: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Date: Thu, 15 Mar 2018 12:10:47 +0300

> this series continues to review and to convert pernet_operations
> to make them possible to be executed in parallel for several
> net namespaces at the same time. There are different operations
> over the tree, mostly are ipvs.

Series applied, thanks Kirill.
