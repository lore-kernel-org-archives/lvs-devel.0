Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCA0F30FF36;
	Wed, 19 Aug 2026 02:29:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787106553; cv=none; b=sMansnVIMn/2XmdBZmhiHfZf9uNjIu0Lmkn489vfmsVoz+RMe2rohW7Q3AY1fIVVRpQGWFps4YlLK8SU7yRTaLQeP82lEArogO7COcBX40+UA63S8ktKr/jyUMNk9HjSeR/+S1eRGZ52jh/VKNUlRND4c3Fkb73xC+d/J9LqNDg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787106553; c=relaxed/simple;
	bh=mh8uWXpHtuuDNAJEE5LrYpyt9j2jNqsPNEHFPOeBwRE=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=udyGPaeFP/hzxtFIZ+LZR/yG7GJ2xG72oy4t5s1IbCHeOGZKFO+u31jvy0qkwteGLF0tDKUXrh4vJmkJy5/kr3UdrXLUarXUweinXx+TmyxMWInCd7JVH11UD1EWhu1JfmDLLYagFd6l+AG73OUEiNpFqoXNyYxwaFa0ya2wl9c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=VmL/Vvvk; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="VmL/Vvvk"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Cc:To:Content-Transfer-Encoding:Content-Type:MIME-Version:
	Message-Id:Date:Subject:From:From:Reply-To;
	bh=0uxb5B58V4uu+YHVHXzlnL/DphYt8R3WYo3q9IR9+kI=; b=VmL/Vvvk0SwRXoSjXlOWhM6m7R
	R3I/hoDl0vmfKoq/YOSt5FiHt8c8y5xf3vK9aSYrntlytg23FSj6BtTv5/nbWpGqUES+Qv8ewiaU1
	L8eH1LMkEJD36COGRAnBN/WpJbEDX8VjrROJgqp+JZnJq2RMlYQoeBq6HRl0pVcF7mIy3Hw2iMuyZ
	6OqHaWI6nOxfZvrD3id0QoNAhP6nVxXWcqXke9t7OjC3ylr8cBSlabT8toWiR0N6IwheQSCoSp7IW
	MI+e31l4QESwB5VqfEA+/XRCJH8LhiTjO7b+QEheUrZzxJ+EGXpkDoVfymnlX5wXCGOMBQZ9DNG0/
	PYSXkuBA==;
Received: from 186-249-144-28.shared.desktop.com.br ([186.249.144.28] helo=[127.0.1.1])
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_X25519__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wwW31-005tfG-UA; Wed, 19 Aug 2026 04:29:00 +0200
From: Mauricio Faria de Oliveira <mfo@igalia.com>
Subject: [PATCH RFC v2 00/13] sysctl: add module aliases
Date: Tue, 18 Aug 2026 23:27:59 -0300
Message-Id: <20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAK8UhWoC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyjHQUlJIzE
 vPSU3UzU4B8JSMDIzMDC0ML3eLK4uSSHN3c/JTSnFTdxJzMxOLUYl2jNFMLA8Mkw9Qkc0MloN6
 CotS0zAqwudFKQW7OSrG1tQBVTqdSbAAAAA==
X-Change-ID: 20260818-sysctl-module-aliases-2f5801b1eb71
To: Kees Cook <kees@kernel.org>, Joel Granados <joel.granados@kernel.org>, 
 Nathan Chancellor <nathan@kernel.org>, Nicolas Schier <nsc@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>
Cc: kernel-dev@igalia.com, linux-riscv@lists.infradead.org, 
 linux-kernel@vger.kernel.org, fsverity@lists.linux.dev, 
 keyrings@vger.kernel.org, bpf@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org, 
 netdev@vger.kernel.org, linux-wpan@vger.kernel.org, 
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, 
 coreteam@netfilter.org, linux-sctp@vger.kernel.org, 
 linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, 
 bridge@lists.linux.dev, mptcp@lists.linux.dev, rds-devel@oss.oracle.com, 
 virtualization@lists.linux.dev, Mauricio Faria de Oliveira <mfo@igalia.com>
X-Mailer: b4 0.14.2

This series adds 'sysctl:' aliases to modules that register sysctl tables; e.g.:

        $ modinfo ./mpls_router.ko  | grep sysctl:
        alias:          sysctl:*/net/mpls/conf/*/input
        alias:          sysctl:*/net/mpls/default_ttl
        alias:          sysctl:*/net/mpls/ip_ttl_propagate
        alias:          sysctl:*/net/mpls/platform_labels

It provides a trivial way to map /proc/sys files to modules (not trivial today),
and for userspace to handle nonexistent /proc/sys files (e.g., procps's sysctl
and systemd-sysctl applying tunables) with "modprobe sysctl:<...>" and a retry.

This is done almost automatically with register_sysctl(), register_net_sysctl()
and friends as wrappers of MODULE_SYSCTL_TABLE (similar to MODULE_DEVICE_TABLE),
which emits symbols for file2alias/modpost to find and parse the sysctl tables.

The big exception to 'almost' are sysctl tables and paths allocated or defined
at runtime (e.g., per-namespace or per-device), as all information is required
at build-time. Fortunately, such tables and paths are often based on 'templates'
which are static and can be used.

This is done by plumbing the template table/path as optional arguments (macros
with default values as default_gfp()), so not to create functions for all cases:

        register_sysctl(path, table [, table_tmpl [, path_tmpl]]);
        register_net_sysctl(net, path, table [, table_tmpl[, path_tmpl]]);
        register_net_sysctl_sz(net, path, table, size [, table_tmpl[, path_tmpl]]);

In this series:
- Patch 1 prevents a build error later.
- Patch 2 adds CONFIG_SYSCTL_MODULE_ALIASES.
- Patch 3 adds MODULE_SYSCTL_TABLE().
- Patches 4-5 add register_sysctl() wrapper and update some callers.
- Patches 6-10 add register_net_sysctl[_sz]() wrappers and update some callers.
- Patches 11-13 add file2alias support.

Not all maintainers/reviewers (specially for the many changes in net/) are
in To/Cc in respect of their time, as this RFC probably needs more general
and earlier feedback before settling on specific changes for their review.
All lists are included for visibility, though.

Example
=======

To put it all together, 'mpls_router.ko' (used above) from 'net/mpls/af_mpls.c':
        
- Tables:

        static const struct ctl_table mpls_table[] = {
                {
                        .procname       = "platform_labels",
                ...
                        .procname       = "ip_ttl_propagate",
                ...
                        .procname       = "default_ttl",
                },
        };
        
        static const struct ctl_table mpls_dev_table[] = {
                {
                        .procname       = "input",
                ...
                },
        };

- Registration:

        net->mpls.ctl = register_net_sysctl_sz(net, "net/mpls", table,
                                               table_size, mpls_table);

        #define path_template "net/mpls/conf/%s"
        ...
        mdev->sysctl = register_net_sysctl_sz(net, path, table, table_size,
                                              mpls_dev_table, path_template);

- Symbols:

        $ objdump -t net/mpls/mpls_router.ko \
          | grep '__mod_device_table__.*__sysctl__'
        0000000000000900 l     O .data  0000000000000018
                __mod_device_table__kmod_mpls_router__sysctl__mpls_table.177
        0000000000000940 l     O .data  0000000000000018
                __mod_device_table__kmod_mpls_router__sysctl__mpls_dev_table.174

- file2alias:

        $ grep '^MODULE_ALIAS("sysctl:' net/mpls/mpls_router.mod.c
        MODULE_ALIAS("sysctl:*/net/mpls/platform_labels");
        MODULE_ALIAS("sysctl:*/net/mpls/ip_ttl_propagate");
        MODULE_ALIAS("sysctl:*/net/mpls/default_ttl");
        MODULE_ALIAS("sysctl:*/net/mpls/conf/*/input");

- modinfo:

        $ modinfo ./mpls_router.ko  | grep sysctl:
        alias:          sysctl:*/net/mpls/conf/*/input
        alias:          sysctl:*/net/mpls/default_ttl
        alias:          sysctl:*/net/mpls/ip_ttl_propagate
        alias:          sysctl:*/net/mpls/platform_labels

Testing
=======

Configurations:
- allmodconfig with the option enabled (check for 'MODULE_ALIAS("sysctl:' lines)
- allmodconfig with the option disabled (check for code errors)
- allyesconfig with the option enabled (check for include errors)

Architectures (test different bitness, endianness, and ELF handling)
- x86_64, i386
- arm, arm64
- arc
- alpha
- loongarch
- m68k
- mips(64)(el)
- parisc(64)
- powerpc(64(le))
- riscv
- sparc64
- s390

The resulting '.mod.c' files of allmodconfig with the option enabled was checked
for consistency across all architectures, and that the new aliases lines are the
difference to allmodconfig with the option disabled.

Disabling
=========

- Per-call:

  Use 'register_sysctl_sz()' or '__register_net_sysctl_sz()' directly.

- Per-file:

  Use '#define SYSCTL_MODULE_ALIASES_DISABLE'.

- System-wide:

  Maybe something along these lines:

        # cat /etc/modprobe.d/no-sysctl.conf
        alias sysctl:* no-sysctl
        install no-sysctl /bin/false

        # modinfo -F name sysctl:/proc/net/mpls/default_ttl
        mpls_router

        # modprobe sysctl:/proc/net/mpls/default_ttl
        modprobe: ERROR: Error running install command '/bin/false' for module no_sysctl: retcode 1
        modprobe: ERROR: could not insert 'no_sysctl': Invalid argument

P.S.
====

I wrote proof-of-concept patches for procps sysctl and systemd-sysctl some time
ago, which worked as expected, i.e., successfully set sysctl tunables which did
not exist in /proc/sys, by running 'modprobe sysctl:/proc/sys/...' and retrying.

Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>

Changes in v2:
- This is based on the series submitted 4 years ago,
  with Originally-by: tags added in related patches.
- Link to v1: https://lore.kernel.org/linux-fsdevel/20220722022416.137548-1-mfo@canonical.com/

---
Mauricio Faria de Oliveira (13):
      keys, pidns, fs/verity, riscv/vector: reorder '#include <linux/sysctl.h>'
      proc: add config option SYSCTL_MODULE_ALIASES
      sysctl, mod_devicetable: add macro MODULE_SYSCTL_TABLE
      sysctl: add register_sysctl() wrapper for MODULE_SYSCTL_TABLE
      sysctl, parport: update register_sysctl() callers with template arguments
      sysctl, net: add register_net_sysctl{_sz}() wrappers for MODULE_SYSCTL_TABLE
      sysctl, net: update register_net_sysctl{_sz}() callers with template arguments
      sysctl, net: update register_net_sysctl_sz(ARRAY_SIZE(table_tmpl)) with template arguments
      sysctl, ipv6: update register_net_sysctl{_sz}() callers with template arguments
      sysctl, net: update register_net_sysctl_sz() edge case
      sysctl: unrandomize struct ctl_table.procname
      modpost: move addend_*_rel() calls into addend_rel()
      modpost: handle MODULE_SYSCTL_TABLE symbols

 arch/riscv/kernel/vector.c              |   1 +
 drivers/net/vrf.c                       |   3 +-
 drivers/parport/procfs.c                |  26 +++-
 fs/proc/Kconfig                         |  13 ++
 fs/verity/init.c                        |   1 +
 include/linux/key.h                     |   1 -
 include/linux/mod_devicetable.h         |   7 +
 include/linux/pid_namespace.h           |   1 +
 include/linux/sysctl.h                  | 110 ++++++++++++++-
 include/net/ipv6.h                      |   6 +-
 include/net/net_namespace.h             |  45 ++++++-
 net/bridge/br_netfilter_hooks.c         |   3 +-
 net/core/neighbour.c                    |  11 +-
 net/core/sysctl_net_core.c              |   3 +-
 net/ieee802154/6lowpan/reassembly.c     |   2 +-
 net/ipv4/devinet.c                      |  12 +-
 net/ipv4/ip_fragment.c                  |   3 +-
 net/ipv4/route.c                        |   3 +-
 net/ipv4/sysctl_net_ipv4.c              |   2 +-
 net/ipv4/xfrm4_policy.c                 |   3 +-
 net/ipv6/addrconf.c                     |   7 +-
 net/ipv6/icmp.c                         |   6 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |   4 +-
 net/ipv6/reassembly.c                   |   3 +-
 net/ipv6/route.c                        |  10 +-
 net/ipv6/sysctl_net_ipv6.c              |  13 +-
 net/ipv6/xfrm6_policy.c                 |   3 +-
 net/mpls/af_mpls.c                      |   9 +-
 net/mptcp/ctrl.c                        |   3 +-
 net/netfilter/ipvs/ip_vs_ctl.c          |   4 +-
 net/netfilter/ipvs/ip_vs_lblc.c         |   3 +-
 net/netfilter/ipvs/ip_vs_lblcr.c        |   3 +-
 net/netfilter/nf_conntrack_standalone.c |   5 +-
 net/netfilter/nf_log.c                  |   9 +-
 net/rds/tcp.c                           |   4 +-
 net/sctp/sysctl.c                       |   3 +-
 net/smc/smc_sysctl.c                    |   2 +-
 net/sysctl_net.c                        |  10 +-
 net/unix/sysctl_net_unix.c              |   3 +-
 net/vmw_vsock/af_vsock.c                |   4 +-
 net/xfrm/xfrm_sysctl.c                  |   2 +-
 scripts/mod/devicetable-offsets.c       |   6 +
 scripts/mod/file2alias.c                | 230 ++++++++++++++++++++++++++++++++
 scripts/mod/modpost.c                   |  46 ++++---
 scripts/mod/modpost.h                   |  25 ++++
 45 files changed, 567 insertions(+), 106 deletions(-)
---
base-commit: 2697ef8943c9985c14708a6429e21812693857b2
change-id: 20260818-sysctl-module-aliases-2f5801b1eb71

Best regards,
-- 
Mauricio Faria de Oliveira <mfo@igalia.com>

