From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH V2 1/2] ipvs: IPv6 MTU checking cleanup and bugfix
Date: Tue, 28 Aug 2012 22:08:57 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208282206530.28772@stinky-local.trash.net>
References: <20120828142051.11475.63775.stgit@dragon> <20120828142122.11475.71918.stgit@dragon>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120828142122.11475.71918.stgit@dragon>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Hans Schillstrom <hans@schillstrom.com>, Wensong Zhang <wensong@linux-vs.org>, netfilter-devel@vger.kernel.org

On Tue, 28 Aug 2012, Jesper Dangaard Brouer wrote:

> Cleaning up the IPv6 MTU checking in the IPVS xmit code, by using
> a common helper function __mtu_check_toobig_v6().
>
> The MTU check for tunnel mode can also use this helper as
> ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) is qual to
> skb->len.  And the 'mtu' variable have been adjusted before
> calling helper.
>
> Notice, this also fixes a bug, as the the MTU check in ip_vs_dr_xmit_v6()
> were missing a check for skb_is_gso().
>
> This bug e.g. caused issues for KVM IPVS setups, where different
> Segmentation Offloading techniques are utilized, between guests,
> via the virtio driver.  This resulted in very bad performance,
> due to the ICMPv6 "too big" messages didn't affect the sender.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied to my nf-nat-ipv6 tree.
