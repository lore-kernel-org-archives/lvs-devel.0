From: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: [PATCH net-next 0/6] Converting pernet_operations (part
	#8)
Date: Thu, 15 Mar 2018 12:10:47 +0300
Message-ID: <152110491273.28582.13804059107038714030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=virtuozzo.com;
	s=selector1; h=From:Date:Subject:Message-ID:Content-Type:MIME-Version; 
	bh=JT9g+F8Z4znNrNDZ/s8cXvaDZUqwRVk3vfbcJiy80X8=;
	b=P+HNxoquJoU8WIgjef/vNuIQl6345gLGzLMhaQLnLfyRkOwKmFjsePk4rf0tj6aZ1+sy6xeOXFyAzbdtNfU+2JkxuXK3xZ7wY03tUk38df/pdR6CQDpa09qWahFtTrvvhZeDgz1xp/HmPzRuSSHBCeKN2bF4osUpslJMkFZPlOU=
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
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wensong-ud5FBsm0p/xg9hUCZPvPmw@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org, ja-FgGsKACvmQM@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, pshelar-LZ6Gd1LRuIk@public.gmane.org, g.nault-pHk1y4uTXVDytLWWfqlThQ@public.gmane.org, jchapman-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org, lorenzo.bianconi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, amine.kherbouche-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org

Hi,

this series continues to review and to convert pernet_operations
to make them possible to be executed in parallel for several
net namespaces at the same time. There are different operations
over the tree, mostly are ipvs.


Thanks,
Kirill
---

Kirill Tkhai (6):
      net: Convert l2tp_net_ops
      net: Convert mpls_net_ops
      net: Convert ovs_net_ops
      net: Convert ipvs_core_ops
      net: Convert ipvs_core_dev_ops
      net: Convert ip_vs_ftp_ops


 net/l2tp/l2tp_core.c            |    1 +
 net/mpls/af_mpls.c              |    1 +
 net/netfilter/ipvs/ip_vs_core.c |    2 ++
 net/netfilter/ipvs/ip_vs_ftp.c  |    1 +
 net/openvswitch/datapath.c      |    1 +
 5 files changed, 6 insertions(+)

--
Signed-off-by: Kirill Tkhai <ktkhai-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
