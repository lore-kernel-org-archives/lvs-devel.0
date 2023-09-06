From: Alexey Gladkov <legion@kernel.org>
Subject: Re: [GIT PULL] sysctl changes for v6.6-rc1
Date: Wed, 6 Sep 2023 13:58:49 +0200
Message-ID: <ZPhpedWW6RwTd9Hf@example.org>
References: <ZO5Yx5JFogGi/cBo@bombadil.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <linux-fsdevel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1694001544;
        bh=pijwMKIDO52W6cZE/0X85aqIGtbSV5WMCx6RXvgt2uc=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=kVNItZoeKSiQoekiXSj64CWEiqBGBeTm/5SBItzk3R3omHMc0182AoTkoVPw6cU+x
         /huJGeQ0ah7F+xr63aAQpEOdJyOGpX6/uU8BslKlUEKvLeDDCKj7AgNE4NRDc8bFU6
         Dk1cD8lAom+I07mwNGN6d2To3rHLyj8L/Xsx1byoPTJB0IWcq5Y9RK8PISj3WDALHY
         J5LzxHNovhDSFhHzPPyyjw+PUS7yI3nvJKP2m5NKG/DgG1wRv5tH6VJFmRKKv+31Fn
         8TiVCv4rj0v9Eh9NdG7nvVv0MGCNvnFDG21k0yMMYX8i38DSikl7l1o22qWjbq73LR
         kyX8yV+ZRMKcA==
Content-Disposition: inline
In-Reply-To: <ZO5Yx5JFogGi/cBo@bombadil.infradead.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="iso-8859-1"
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joel Granados <joel.granados@gmail.com>, linux-fsdevel@vger.kernel.org, rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>, Florian Westphal <fw@strlen.de>, willy@infradead.org, Jan Karcher <jaka@linux.ibm.com>, Wen Gu <guwen@linux.alibaba.com>, Simon Horman <horms@verge.net.au>, Tony Lu <tonylu@linux.alibaba.com>, linux-wpan@vger.kernel.org, Matthieu Baerts <matthieu.baerts@tessares.net>, Christian Borntraeger <borntraeger@linux.ibm.com>, mptcp@lists.linux.dev, Heiko Carstens <hca@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Will Deacon <will@kernel.org>, Julian Anastasov <ja@ssi.bg>, netfilter-devel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>, linux-kernel@vger.kernel.org, A

On Tue, Aug 29, 2023 at 01:44:55PM -0700, Luis Chamberlain wrote:
> The following changes since commit 06c2afb862f9da8dc5efa4b6076a0e48c3fbaa=
a5:
>=20
>   Linux 6.5-rc1 (2023-07-09 13:53:13 -0700)
>=20
> are available in the Git repository at:
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/mcgrof/linux.git/ tags/sy=
sctl-6.6-rc1
>=20
> for you to fetch changes up to 53f3811dfd5e39507ee3aaea1be09aabce8f9c98:
>=20
>   sysctl: Use ctl_table_size as stopping criteria for list macro (2023-08=
-15 15:26:18 -0700)
>=20
> ----------------------------------------------------------------
> sysctl-6.6-rc1
>=20
> Long ago we set out to remove the kitchen sink on kernel/sysctl.c arrays =
and
> placings sysctls to their own sybsystem or file to help avoid merge confl=
icts.
> Matthew Wilcox pointed out though that if we're going to do that we might=
 as
> well also *save* space while at it and try to remove the extra last sysctl
> entry added at the end of each array, a sentintel, instead of bloating the
> kernel by adding a new sentinel with each array moved.
>=20
> Doing that was not so trivial, and has required slowing down the moves of
> kernel/sysctl.c arrays and measuring the impact on size by each new move.
>=20
> The complex part of the effort to help reduce the size of each sysctl is =
being
> done by the patient work of el se=F1or Don Joel Granados. A lot of this i=
s truly
> painful code refactoring and testing and then trying to measure the savin=
gs of
> each move and removing the sentinels. Although Joel already has code whic=
h does
> most of this work, experience with sysctl moves in the past shows is we n=
eed to
> be careful due to the slew of odd build failures that are possible due to=
 the
> amount of random Kconfig options sysctls use.
>=20
> To that end Joel's work is split by first addressing the major housekeepi=
ng
> needed to remove the sentinels, which is part of this merge request. The =
rest
> of the work to actually remove the sentinels will be done later in future
> kernel releases.

This is very interesting for me. I'm also refactoring sysctl based on
discussion with Linus a while ago.

Could you please add me to the Cc in the next patches?

> At first I was only going to send his first 7 patches of his patch series,
> posted 1 month ago, but in retrospect due to the testing the changes have
> received in linux-next and the minor changes they make this goes with the
> entire set of patches Joel had planned: just sysctl house keeping. There =
are
> networking changes but these are part of the house keeping too.
>=20
> The preliminary math is showing this will all help reduce the overall bui=
ld
> time size of the kernel and run time memory consumed by the kernel by abo=
ut
> ~64 bytes per array where we are able to remove each sentinel in the futu=
re.
> That also means there is no more bloating the kernel with the extra ~64 b=
ytes
> per array moved as no new sentinels are created.
>=20
> Most of this has been in linux-next for about a month, the last 7 patches=
 took
> a minor refresh 2 week ago based on feedback.
>=20
> ----------------------------------------------------------------
> Joel Granados (14):
>       sysctl: Prefer ctl_table_header in proc_sysctl
>       sysctl: Use ctl_table_header in list_for_each_table_entry
>       sysctl: Add ctl_table_size to ctl_table_header
>       sysctl: Add size argument to init_header
>       sysctl: Add a size arg to __register_sysctl_table
>       sysctl: Add size to register_sysctl
>       sysctl: Add size arg to __register_sysctl_init
>       sysctl: Add size to register_net_sysctl function
>       ax.25: Update to register_net_sysctl_sz
>       netfilter: Update to register_net_sysctl_sz
>       networking: Update to register_net_sysctl_sz
>       vrf: Update to register_net_sysctl_sz
>       sysctl: SIZE_MAX->ARRAY_SIZE in register_net_sysctl
>       sysctl: Use ctl_table_size as stopping criteria for list macro
>=20
>  arch/arm64/kernel/armv8_deprecated.c    |  2 +-
>  arch/s390/appldata/appldata_base.c      |  2 +-
>  drivers/net/vrf.c                       |  3 +-
>  fs/proc/proc_sysctl.c                   | 90 +++++++++++++++++----------=
------
>  include/linux/sysctl.h                  | 31 +++++++++---
>  include/net/ipv6.h                      |  2 +
>  include/net/net_namespace.h             | 10 ++--
>  ipc/ipc_sysctl.c                        |  4 +-
>  ipc/mq_sysctl.c                         |  4 +-
>  kernel/ucount.c                         |  5 +-
>  net/ax25/sysctl_net_ax25.c              |  3 +-
>  net/bridge/br_netfilter_hooks.c         |  3 +-
>  net/core/neighbour.c                    |  8 ++-
>  net/core/sysctl_net_core.c              |  3 +-
>  net/ieee802154/6lowpan/reassembly.c     |  8 ++-
>  net/ipv4/devinet.c                      |  3 +-
>  net/ipv4/ip_fragment.c                  |  3 +-
>  net/ipv4/route.c                        |  8 ++-
>  net/ipv4/sysctl_net_ipv4.c              |  3 +-
>  net/ipv4/xfrm4_policy.c                 |  3 +-
>  net/ipv6/addrconf.c                     |  3 +-
>  net/ipv6/icmp.c                         |  5 ++
>  net/ipv6/netfilter/nf_conntrack_reasm.c |  3 +-
>  net/ipv6/reassembly.c                   |  3 +-
>  net/ipv6/route.c                        |  9 ++++
>  net/ipv6/sysctl_net_ipv6.c              | 16 ++++--
>  net/ipv6/xfrm6_policy.c                 |  3 +-
>  net/mpls/af_mpls.c                      |  6 ++-
>  net/mptcp/ctrl.c                        |  3 +-
>  net/netfilter/ipvs/ip_vs_ctl.c          |  8 ++-
>  net/netfilter/ipvs/ip_vs_lblc.c         | 10 ++--
>  net/netfilter/ipvs/ip_vs_lblcr.c        | 10 ++--
>  net/netfilter/nf_conntrack_standalone.c |  4 +-
>  net/netfilter/nf_log.c                  |  7 +--
>  net/rds/tcp.c                           |  3 +-
>  net/sctp/sysctl.c                       |  4 +-
>  net/smc/smc_sysctl.c                    |  3 +-
>  net/sysctl_net.c                        | 26 +++++++---
>  net/unix/sysctl_net_unix.c              |  3 +-
>  net/xfrm/xfrm_sysctl.c                  |  8 ++-
>  40 files changed, 222 insertions(+), 113 deletions(-)

--=20
Rgrds, legion

