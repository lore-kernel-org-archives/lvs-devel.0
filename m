Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F37419CC0F;
	Fri,  4 Sep 2026 17:45:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788543963; cv=none; b=FtfIgNPdCpF9g2wG3w6wnMRD8M3Vrc2CiDpo6W6jK3AsOaGga3CviFJQX7xclctyggjJtFtpfc+A0zgkDStdBFtk+pS0cQGlGeQfpJp+GWX3ikHer+iI/rZ6DUD5C0zSnjd6rTC3yBWhp8J074JRmIRkBoT45eRaFurBRvvavvY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788543963; c=relaxed/simple;
	bh=IpIcXmZ5y3zAPIXH0ITLn7oZOKruZHk0aeMQju5DuzE=;
	h=MIME-Version:Date:From:To:Cc:Subject:In-Reply-To:References:
	 Message-ID:Content-Type; b=liIdabv0fHEGSagt+zcALKdoTP26oHgIOD+yqxoMV7dNVVb3KwbEV6Ywr8evNoX6eIuomRnWopowKTrGrmXBu8RkX1G+M2rWr2yLizCR4SIdjktIBMudrSrLPBRVezbkyLnDV1fkMrUqbPHza16Zf5U9GoxxvFZaCM0BM7RSq/M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=pMU/YCpY; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="pMU/YCpY"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:Content-Type:Message-ID:Subject:Cc:To
	:From:Date:MIME-Version:From:Reply-To;
	bh=3kJ7V4qqJDGktsGa6HvFkInxay1XxXTxaazUjY3g2Hg=; b=pMU/YCpYNVsT4y/cw1wUdM7zig
	6FGELePr69ke+QNUk1G581g+plUqC63/ulntoNIxp4pmbIVxfOia9PckTHSRm7xpUciNq57SZzqVN
	cbsILUiD8lzSdwcwFXmRLM5CfmP+hPRfm6lYmxFlKNBEyu4prtcCynH9vE1ksDe8NHMM4ChUZakqb
	g9JR+994Oc+oJQ4Q0AJSntCNDkHoysIvAdma6HpwZmNS1nvN6HQ7sdhdssRvg1w9t7SZEOTJlyvat
	sUbSdbal24ShKj5UheutEWEXP6HsQ9h5DXMVF9LQie/eE7V27D08mGmnS+RWfYNHD9zmSk/JT0i/e
	OBepHvZQ==;
Received: from maestria.local.igalia.com ([192.168.10.14] helo=mail.igalia.com)
	by fanzine2.igalia.com with esmtps 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1x2Xyg-00Ezrc-2e; Fri, 04 Sep 2026 19:45:26 +0200
Received: from webmail.service.igalia.com ([192.168.21.45])
	by mail.igalia.com with esmtp (Exim)
	id 1x2Xye-001h2m-Ee; Fri, 04 Sep 2026 19:45:25 +0200
Received: from localhost ([127.0.0.1] helo=webmail.igalia.com)
	by webmail.service.igalia.com with esmtp (Exim 4.98.2)
	(envelope-from <mfo@igalia.com>)
	id 1x2Xye-00000006G3f-1esz;
	Fri, 04 Sep 2026 19:45:24 +0200
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Fri, 04 Sep 2026 14:45:23 -0300
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
In-Reply-To: <mokz5pdtwswkyab4byfq7q7m6ac2g6ceoi6jflyxmaszaibzqa@su6m4kamtdpy>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <bpnqwggtidgiec5akns3fa5edbsvl7xf55dxabtwng2xspy4pn@ue554aii2ngk>
 <53155340c897560bfc67e61ba9568fd6@igalia.com>
 <mokz5pdtwswkyab4byfq7q7m6ac2g6ceoi6jflyxmaszaibzqa@su6m4kamtdpy>
Message-ID: <b1a6cec17e7c828fcebe310ca2a0d25b@igalia.com>
X-Sender: mfo@igalia.com
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Spam-Report: NO, Score=-2.1, Tests=ALL_TRUSTED=-3,BAYES_50=0.8,KAM_DMARC_NONE=0.125,KAM_DMARC_STATUS=0.005
X-Spam-Score: -20
X-Spam-Bar: --

On 2026-09-04 10:41, Joel Granados wrote:
> On Thu, Aug 20, 2026 at 06:22:13PM -0300, Mauricio Faria de Oliveira wrote:
>> On 2026-08-20 09:51, Joel Granados wrote:
>> > On Wed, Aug 19, 2026 at 03:16:13PM -0300, Mauricio Faria de Oliveira wrote:
>> >> This series adds 'sysctl:' aliases to modules that register sysctl tables; e.g.:
>> >> 
>> >>         $ modinfo ./mpls_router.ko  | grep sysctl:
>> >>         alias:          sysctl:*/net/mpls/conf/*/input
>> >>         alias:          sysctl:*/net/mpls/default_ttl
>> >>         alias:          sysctl:*/net/mpls/ip_ttl_propagate
>> >>         alias:          sysctl:*/net/mpls/platform_labels
>> >> 
>> >> It provides a trivial way to map /proc/sys files to modules (not trivial today),
>> >> and for userspace to handle nonexistent /proc/sys files (e.g., procps's sysctl
>> >> and systemd-sysctl applying tunables) with "modprobe sysctl:<...>" and a retry.
>> >> 
>> >> This is done almost automatically with register_sysctl(), register_net_sysctl()
>> >> and friends as wrappers of MODULE_SYSCTL_TABLE (similar to MODULE_DEVICE_TABLE),
>> >> which emits symbols for file2alias/modpost to find and parse the sysctl tables.
>> >> 
>> >> The big exception to 'almost' are sysctl tables and paths allocated or defined
>> >> at runtime (e.g., per-namespace or per-device), as all information is required
>> >> at build-time. Fortunately, such tables and paths are often based on 'templates'
>> >> which are static and can be used.
>> >> 
>> >> This is done by plumbing the template table/path as optional arguments (macros
>> >> with default values as default_gfp()), so not to create functions for all cases:
>> >> 
>> >>         register_sysctl(path, table [, table_tmpl [, path_tmpl]]);
>> >>         register_net_sysctl(net, path, table [, table_tmpl[, path_tmpl]]);
>> >>         register_net_sysctl_sz(net, path, table, size [, table_tmpl[, path_tmpl]]);
>> > 
>> > The "what" is described but I'm missing more clarity on the "why". Why
>> > does this need to be trivial? Where is it that you will know the sysctl
>> > file path of a module and not the module name or alias?
>> 
>> Thanks for looking at this.
>> 
>> The problem this feature addresses is sysctl settings not applied
>> because modules aren't yet loaded when systemd-sysctl/procps's sysctl
>> runs on boot, and the usage of /etc/modules as a workaround.
> 
> Sorry for insisting, but is it not possible to set the sysctls after the
> modules have been loaded? Why is the order to first set the sysctl and
> then load the module?

No worries, and thanks for getting back to this.

Yes, the former is possible and usually how that happens, but it is not
guaranteed, thus the latter might happen -- unintentionally.

For example, a sysctl setting can be configured in /etc/sysctl.d/*.conf,
which is manually tested and confirmed to apply it correctly. However,
that might have worked only because its module was inadvertently loaded
earlier (e.g., for something else by the sysadmin, or by something else
in the system). The next time the system boots, the module is not
automatically loaded, thus the sysctl setting fails to be applied when
the (previously working) /etc/sysctl.d/*.conf is parsed.

Also, a sysctl setting may, or may not, be tied to a module; it can be
built-in. This can change with kernel configuration, e.g., distro.

So, another example: a sysadmin learns of a sysctl setting in
documentation tested with another distro, which has it built-in. It
fails to apply on this distro, which has it in a module, because the
module isn't loaded. (Now the sysadmin is left to figure that out, and
then which kernel module provides the sysctl setting.) 

Note that both examples can be combined. (And the poor sysadmin is, in a
reboot happening days/weeks/months later, left to also figure out that
the sysctl setting is not applied, and whatever effect that caused,
because that particular module was not loaded on boot, and should be
added to /etc/modules).

>> This can be addressed with a way for sysctl tools to load the module for
>> a non-existent sysctl file path.
>> For that, the mapping between a sysctl file path (known) and its module
>> (unknown) needs to be trivial.
> This touches on my question. How is the file path known and the module
> not known? The module is the one providing the paths, not the other way
> around. Why choose to just work with sysctl path lists and not include
> the modules that go with them?

The sysctl tools and configuration files only know about the file path,
not the module. The sysctl tools know the file path when parsing the
configuration files, converting a 'dir.file = value' line into opening
/proc/sys/dir/value and writing value into it.

The format of configuration files only include file paths and values,
but not modules, per sysctl.conf(5) and sysctl.d(5). This is reasonable,
as there may, or may not, be a module for the sysctl setting (i.e.,
module vs. built-in).

Maybe I misunderstand the context for your questions; please let me
know.
Also, could you please clarify what you mean by 'include the modules
that go with them' [sysctl path files] ?

>> It may not seem serious at first, but I've seen this consume significant
>> engineering time and impact production systems, in a previous technical
>> support job.
>> An example: cloud deployments with non-scalable network routing
>> performance due to nf_conntrack_max not applied after reboot or an
>> upgrade because the component which turned out to help with the
>> /etc/modules workaround had its placement changed from network router
>> nodes.
> This is more understandable to me. The issue is that you loose the
> relationship between sysctl paths and modules on updates. Are there
> other cases where the module would not be loaded?

In general, there is no guarantee that a module is loaded by the time a
sysctl setting is about to be applied -- during system boot or even
later.

The example for system boot is covered previously. An example for
'later' / after system boot: on network device testing which includes
module unload/reload and sysctl settings for network performance, one
might unload the module, and mistakenly first apply sysctl settings then
reload the module, thus loosing the performance tuning on that one
testing round.

> And doesn't it create another problem where you will load modules that
> you don't expect (on the update)?

Sorry, not sure I understand the meaning of 'update' correctly, but yes,
if there is a hard-coded module load (e.g., /etc/modules or in scripts),
that happens. However, AFAICT, loading unexpected modules is less of a
problem than not loading required modules, or may not be a problem.

With an auto-load mechanism in place, hard-coding/force-load is not
required, and neither problem (loading unexpected modules due to
hard-coding, and not loading required modules due to lack of
hard-coding) would happen, IIUIC.

>> > Additionally, sysctls are not module specific; they are a way to
>> > read/write kernel variables. Putting a module specific aspect in the
>> > function arguments (that needs to be ignored in non-module cases) seems
>> > wrong. Why not use the module subsys to add sysctl alias instead of the
>> > sysctl subsys?
>> 
>> Fair point. The current design has 2 reasons:
>> 
>> 1) Use the 'path' argument (raised in [1]), only available in the
>> register sysctl functions.
>> 2) Use a more implicit/transparent approach, instead of more
>> explicit/declarative approach. 
> 
> I get that the data is there and you would be able to do it, but it
> still seems misplaced. Additionally, are you planning to move all the
> modules to this scheme? If not, does that mean that some modules would
> work and some wouldn't? And how would you make sure that modules would
> use the correct call moving forward?

This scheme currently covers all modules, AFAIK, as it is wrapped in the
functions that register sysctl tables.

On moving forward: usage of such functions in a way that breaks a
requirement of this series (e.g., failing to specify the template
table/path parameter(s), or not having constant initializers) hits a
build error, as the requirements are actually from the compiler.

>> I guess that a different design could use MODULE_SYSCTL_TABLE() as
>> MODULE_DEVICE_TABLE(), declared per table instead of wrapped into
>> register sysctl functions.
>> However, it seems to require moving the value of the path argument (or
>> its template) into the macro and still referencing it in the function
>> (or its instantiation of the template), which adds obfuscation, to all
>> callers. 
>> 
>> What do you think?
> It might be that having it inside the module subsys is more work, but I
> believe that there is the right place to have it. I still don't see that
> adding a module specific arg to the sysctl register is a good thing.

Ok, cool. I can work on a different design.

Please just let me know whether you are OK with the remaining (above),
and I'll be happy to tackle this.

Thanks again,

> 
> 
> Best

-- 
Mauricio
