Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C4CB3D566B;
	Thu, 20 Aug 2026 21:22:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787260966; cv=none; b=C9CUollFQo/LXg+9g9Yy3/Egaa5FKiXFiU5LZNlsoXUtBOT/NBttVefOdrDZXN5M6eO3EzeuxamD+ldex0ZG/hzuUvO2jihJzrC0W4dZhm+D+F/7FyuYhr+DUYX4YgeKVmpor8luxHJxITaG5MOgE7RoxjMQzrrYkEYesToh8mQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787260966; c=relaxed/simple;
	bh=0En8EkEm19HbeogpuP0BWKqgnktwroJc/EPwLAEdJbg=;
	h=MIME-Version:Date:From:To:Cc:Subject:In-Reply-To:References:
	 Message-ID:Content-Type; b=CZpC/ALoQejrIDiwfk3IfOlaGWmCaPssaiCubTf1Zd6iL+fzqVKp3Flk07WsO3UERsCaqZJP5Y2HD5X1UQb0JPwYc7EtzREYi3/SNZzwWCYoJQWDzhCxc/cyDwr26Fl9e85+Nb3wnqnZK44QLN6oEi0L8BXYGEQ9ivNg63DoKbY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=YBPdifGr; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="YBPdifGr"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:Content-Type:Message-ID:Subject:Cc:To
	:From:Date:MIME-Version:From:Reply-To;
	bh=VVmJbA2qSMFaP8opo9Ndr4fLkuQPcO1ld+9q8zqI4gU=; b=YBPdifGreGdx02v4W+03i1hb8P
	kW1i1NpMNWAZvBa3xGSBVamJJvrLrxcuJJEWscfdKlGsjhU6WczaoYxpVh8lX6/UeYm82kHNbOQQ/
	glTcrzL2PfmSiprrWg8EpipC3LS6L9xzpcxwylH0PLoofGYIJCpR3ubtgK3ODLKf6oH4qAazKHZ9/
	uyFFl1bhgqYsfzIHPcKYF0R3ewT+w3J3TUi4sJWELfnHTTCbNxVzuuI0XA5LFc3YpgJGHHpn0PeM8
	B+2/piTsRzf+T8xDavrRZphMysTDVCOgP3ba1xgFSZj0j6O99zOrgbS3hVt+qVsOk+iUB5PcA91OH
	VygvGNjA==;
Received: from maestria.local.igalia.com ([192.168.10.14] helo=mail.igalia.com)
	by fanzine2.igalia.com with esmtps 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wxADH-006m8d-Ow; Thu, 20 Aug 2026 23:22:15 +0200
Received: from webmail.service.igalia.com ([192.168.21.45])
	by mail.igalia.com with esmtp (Exim)
	id 1wxADF-00GOZQ-Si; Thu, 20 Aug 2026 23:22:15 +0200
Received: from localhost ([127.0.0.1] helo=webmail.igalia.com)
	by webmail.service.igalia.com with esmtp (Exim 4.98.2)
	(envelope-from <mfo@igalia.com>)
	id 1wxADF-00000002RTu-3Rre;
	Thu, 20 Aug 2026 23:22:13 +0200
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 20 Aug 2026 18:22:13 -0300
From: Mauricio Faria de Oliveira <mfo@igalia.com>
To: Joel Granados <joel.granados@kernel.org>
Cc: Kees Cook <kees@kernel.org>, Nathan Chancellor <nathan@kernel.org>,
 Nicolas Schier <nsc@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo
 Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
 kernel-dev@igalia.com, linux-riscv@lists.infradead.org,
 linux-kernel@vger.kernel.org, fsverity@lists.linux.dev,
 keyrings@vger.kernel.org, bpf@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org,
 netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, linux-sctp@vger.kernel.org,
 linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org,
 bridge@lists.linux.dev, mptcp@lists.linux.dev, rds-devel@oss.oracle.com,
 virtualization@lists.linux.dev
Subject: Re: [PATCH RFC v3 00/13] sysctl: add module aliases
In-Reply-To: <bpnqwggtidgiec5akns3fa5edbsvl7xf55dxabtwng2xspy4pn@ue554aii2ngk>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <bpnqwggtidgiec5akns3fa5edbsvl7xf55dxabtwng2xspy4pn@ue554aii2ngk>
Message-ID: <53155340c897560bfc67e61ba9568fd6@igalia.com>
X-Sender: mfo@igalia.com
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Spam-Report: NO, Score=-2.9, Tests=ALL_TRUSTED=-3,BAYES_20=-0.001,KAM_DMARC_NONE=0.125,KAM_DMARC_STATUS=0.005
X-Spam-Score: -28
X-Spam-Bar: --

On 2026-08-20 09:51, Joel Granados wrote:
> On Wed, Aug 19, 2026 at 03:16:13PM -0300, Mauricio Faria de Oliveira wrote:
>> This series adds 'sysctl:' aliases to modules that register sysctl tables; e.g.:
>> 
>>         $ modinfo ./mpls_router.ko  | grep sysctl:
>>         alias:          sysctl:*/net/mpls/conf/*/input
>>         alias:          sysctl:*/net/mpls/default_ttl
>>         alias:          sysctl:*/net/mpls/ip_ttl_propagate
>>         alias:          sysctl:*/net/mpls/platform_labels
>> 
>> It provides a trivial way to map /proc/sys files to modules (not trivial today),
>> and for userspace to handle nonexistent /proc/sys files (e.g., procps's sysctl
>> and systemd-sysctl applying tunables) with "modprobe sysctl:<...>" and a retry.
>> 
>> This is done almost automatically with register_sysctl(), register_net_sysctl()
>> and friends as wrappers of MODULE_SYSCTL_TABLE (similar to MODULE_DEVICE_TABLE),
>> which emits symbols for file2alias/modpost to find and parse the sysctl tables.
>> 
>> The big exception to 'almost' are sysctl tables and paths allocated or defined
>> at runtime (e.g., per-namespace or per-device), as all information is required
>> at build-time. Fortunately, such tables and paths are often based on 'templates'
>> which are static and can be used.
>> 
>> This is done by plumbing the template table/path as optional arguments (macros
>> with default values as default_gfp()), so not to create functions for all cases:
>> 
>>         register_sysctl(path, table [, table_tmpl [, path_tmpl]]);
>>         register_net_sysctl(net, path, table [, table_tmpl[, path_tmpl]]);
>>         register_net_sysctl_sz(net, path, table, size [, table_tmpl[, path_tmpl]]);
> 
> The "what" is described but I'm missing more clarity on the "why". Why
> does this need to be trivial? Where is it that you will know the sysctl
> file path of a module and not the module name or alias?

Thanks for looking at this.

The problem this feature addresses is sysctl settings not applied
because modules aren't yet loaded when systemd-sysctl/procps's sysctl
runs on boot, and the usage of /etc/modules as a workaround.

This can be addressed with a way for sysctl tools to load the module for
a non-existent sysctl file path.
For that, the mapping between a sysctl file path (known) and its module
(unknown) needs to be trivial.

It may not seem serious at first, but I've seen this consume significant
engineering time and impact production systems, in a previous technical
support job.
An example: cloud deployments with non-scalable network routing
performance due to nf_conntrack_max not applied after reboot or an
upgrade because the component which turned out to help with the
/etc/modules workaround had its placement changed from network router
nodes.

> Additionally, sysctls are not module specific; they are a way to
> read/write kernel variables. Putting a module specific aspect in the
> function arguments (that needs to be ignored in non-module cases) seems
> wrong. Why not use the module subsys to add sysctl alias instead of the
> sysctl subsys?

Fair point. The current design has 2 reasons:

1) Use the 'path' argument (raised in [1]), only available in the
register sysctl functions.
2) Use a more implicit/transparent approach, instead of more
explicit/declarative approach. 

I guess that a different design could use MODULE_SYSCTL_TABLE() as
MODULE_DEVICE_TABLE(), declared per table instead of wrapped into
register sysctl functions.
However, it seems to require moving the value of the path argument (or
its template) into the macro and still referencing it in the function
(or its instantiation of the template), which adds obfuscation, to all
callers. 

What do you think?

[snip]

>> P.S.
>> ====
>> 
>> I wrote proof-of-concept patches for procps sysctl and systemd-sysctl some time
>> ago, which worked as expected, i.e., successfully set sysctl tunables which did
>> not exist in /proc/sys, by running 'modprobe sysctl:/proc/sys/...' and retrying.
> 
> Do you have links to this? To the old one, not necessarily a new
> version.

Sure, please see [2] and [3]. I did a quick rebase/refresh, but both
seem to work:

procps sysctl:

    $ strace -e execve -f -s 64 ./src/sysctl --modprobe=1 -w net.test=1
2>&1 | grep modprobe

    [pid 505958] execve("/bin/sh", ["sh", "-c", "--", "modprobe
sysctl:/proc/sys/net/test >/dev/null 2>&1"], 0x7ffc12efff80 /* 63 vars
*/) = 0

systemd-sysctl:

$ cat /etc/sysctl.d/net-test.conf
net.test = 1

    $ sudo strace -e execve -f -s 64 ./build/systemd-sysctl
--modprobe=true /etc/sysctl.d/net-test.conf  2>&1 | grep modprobe

[pid 505777] execve("/usr/sbin/modprobe", ["modprobe",
"sysctl:*/net/test"], 0x7ffd473d1418 /* 20 vars */) = 0

Thanks,

[1]
https://lore.kernel.org/linux-fsdevel/CAK7LNAR=7zgOiqTD9okXfZXroFH1yagMFsRuq0G-z6OfSUPLQg@mail.gmail.com/
[2] https://github.com/mfoliveira/procps/commits/sysctl-module-aliases/
[3] https://github.com/mfoliveira/systemd/commits/sysctl-module-aliases/

> 
> Best
>> 
>> Should this series eventually be merged, the patches will be submitted upstream
>> as well, for userspace to start consuming it.
>> 
>> Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
>> 
>> Changes in v3:
>> - All issues were reported by sashiko-bot@kernel.org.
>> - Tested allmodconfig with option enabled on x86_64.
>> - Patch 2:
>>   - Fix typo ('s/options/option/').
>> - Patch 3:
>>   - Fix usage of __UNIQUE_ID().
>>   - Add __must_be_array() in MODULE_SYSCTL_TABLE().
>> - Patch 4:
>>   - Remove trailing backslash in register_sysctl().
>> - Patch 6:
>>   - Fix missing __register_net_sysctl_sz() in !CONFIG_SYSCTL.
>> - Patch 13:
>>   - Fix potential out-of-bounds read in do_sysctl_entry().
>>   - Add check for entry size of zero.
>> - Link to v2: https://lore.kernel.org/r/20260818-sysctl-module-aliases-v2-0-d5a69dae5798@igalia.com
>> 
>> Changes in v2:
>> - This is based on the series submitted 4 years ago,
>>   with Originally-by: tags added in related patches.
>> - Link to v1: https://lore.kernel.org/linux-fsdevel/20220722022416.137548-1-mfo@canonical.com/
>> 
>> ---
>> Mauricio Faria de Oliveira (13):
>>       keys, pidns, fs/verity, riscv/vector: reorder '#include <linux/sysctl.h>'
>>       proc: add config option SYSCTL_MODULE_ALIASES
>>       sysctl, mod_devicetable: add macro MODULE_SYSCTL_TABLE
>>       sysctl: add register_sysctl() wrapper for MODULE_SYSCTL_TABLE
>>       sysctl, parport: update register_sysctl() callers with template arguments
>>       sysctl, net: add register_net_sysctl{_sz}() wrappers for MODULE_SYSCTL_TABLE
>>       sysctl, net: update register_net_sysctl{_sz}() callers with template arguments
>>       sysctl, net: update register_net_sysctl_sz(ARRAY_SIZE(table_tmpl)) with template arguments
>>       sysctl, ipv6: update register_net_sysctl{_sz}() callers with template arguments
>>       sysctl, net: update register_net_sysctl_sz() edge case
>>       sysctl: unrandomize struct ctl_table.procname
>>       modpost: move addend_*_rel() calls into addend_rel()
>>       modpost: handle MODULE_SYSCTL_TABLE symbols
>> 
>>  arch/riscv/kernel/vector.c              |   1 +
>>  drivers/net/vrf.c                       |   3 +-
>>  drivers/parport/procfs.c                |  26 +++-
>>  fs/proc/Kconfig                         |  13 ++
>>  fs/verity/init.c                        |   1 +
>>  include/linux/key.h                     |   1 -
>>  include/linux/mod_devicetable.h         |   7 +
>>  include/linux/pid_namespace.h           |   1 +
>>  include/linux/sysctl.h                  | 110 ++++++++++++++-
>>  include/net/ipv6.h                      |   6 +-
>>  include/net/net_namespace.h             |  47 ++++++-
>>  net/bridge/br_netfilter_hooks.c         |   3 +-
>>  net/core/neighbour.c                    |  11 +-
>>  net/core/sysctl_net_core.c              |   3 +-
>>  net/ieee802154/6lowpan/reassembly.c     |   2 +-
>>  net/ipv4/devinet.c                      |  12 +-
>>  net/ipv4/ip_fragment.c                  |   3 +-
>>  net/ipv4/route.c                        |   3 +-
>>  net/ipv4/sysctl_net_ipv4.c              |   2 +-
>>  net/ipv4/xfrm4_policy.c                 |   3 +-
>>  net/ipv6/addrconf.c                     |   7 +-
>>  net/ipv6/icmp.c                         |   6 +-
>>  net/ipv6/netfilter/nf_conntrack_reasm.c |   4 +-
>>  net/ipv6/reassembly.c                   |   3 +-
>>  net/ipv6/route.c                        |  10 +-
>>  net/ipv6/sysctl_net_ipv6.c              |  13 +-
>>  net/ipv6/xfrm6_policy.c                 |   3 +-
>>  net/mpls/af_mpls.c                      |   9 +-
>>  net/mptcp/ctrl.c                        |   3 +-
>>  net/netfilter/ipvs/ip_vs_ctl.c          |   4 +-
>>  net/netfilter/ipvs/ip_vs_lblc.c         |   3 +-
>>  net/netfilter/ipvs/ip_vs_lblcr.c        |   3 +-
>>  net/netfilter/nf_conntrack_standalone.c |   5 +-
>>  net/netfilter/nf_log.c                  |   9 +-
>>  net/rds/tcp.c                           |   4 +-
>>  net/sctp/sysctl.c                       |   3 +-
>>  net/smc/smc_sysctl.c                    |   2 +-
>>  net/sysctl_net.c                        |  10 +-
>>  net/unix/sysctl_net_unix.c              |   3 +-
>>  net/vmw_vsock/af_vsock.c                |   4 +-
>>  net/xfrm/xfrm_sysctl.c                  |   2 +-
>>  scripts/mod/devicetable-offsets.c       |   6 +
>>  scripts/mod/file2alias.c                | 237 ++++++++++++++++++++++++++++++++
>>  scripts/mod/modpost.c                   |  46 ++++---
>>  scripts/mod/modpost.h                   |  25 ++++
>>  45 files changed, 575 insertions(+), 107 deletions(-)
>> ---
>> base-commit: 2697ef8943c9985c14708a6429e21812693857b2
>> change-id: 20260818-sysctl-module-aliases-2f5801b1eb71
>> 
>> Best regards,
>> -- 
>> Mauricio Faria de Oliveira <mfo@igalia.com>
>>

-- 
Mauricio
