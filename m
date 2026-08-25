Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8533A3B6BFE;
	Tue, 25 Aug 2026 19:10:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787685054; cv=none; b=MBPFQ3JgaDmKBiwp2KDEEb4ecL+mLtph2ZDH5dUDq281tYFeEFrYTLqmj0fBsymWglvCHWxzIyTDZH9MReokSD6fJm8HvhUVSdj64YaC6gFEul3gP+c1AhtP9aAPtjK4OhXlImrdGrh8yAEgF7mDS3GGgLhWgOKsl1c6AF3TeI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787685054; c=relaxed/simple;
	bh=OtchHb6GBRRv68k/gioU/7xbxZ19B8WsvvWJaYWNtpk=;
	h=MIME-Version:Date:From:To:Cc:Subject:In-Reply-To:References:
	 Message-ID:Content-Type; b=ipvLNwRYVe5qMCdwNi3DiLYUr8wa3BDCTTRR0oDbzguPyZv8t4cUzxHe9TeftT02dHk+LbW69SxsAwO7zSBhor2O9024k3t1P3Jqc+SNVIrIC9YItyp7L0nInMqvVzRwIKyPuzRPy4Mm4VQ7gBGxSu1mtANzzbw4nfK7j1dIW1A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=RHvx1Ado; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="RHvx1Ado"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:Content-Type:Message-ID:Subject:Cc:To
	:From:Date:MIME-Version:From:Reply-To;
	bh=elAJm2a/yvCuwNZQN8cT8iWBlOljI1OpyGvFLYC11uo=; b=RHvx1Ado+WH9EzbHIOX+ZddNR4
	p497xG/usjgdtyDE/kA/xbjOpyLIBJuOI92EZRwc1yOZOItUmNe5+oSRd4oxCZHOSJIg77xqmE+Tc
	K5PFV0rWFpwnhQ6m9KAj6Aq1yxVDoopN2BKsaUVqLC48h9H3wG5IGBXSnMlrjvxadR17ZpA62zFv6
	qnk+hsPSnk1nJmmcLcs7OjTT5cXXOefE42zyl0b94RK82DSvgwElUXWEAW9MTO2l5NBp9Zejkwn6T
	YNgx8l8tDqfY2WGCtiFY0jVvYc0jEiv34rN7tch6qSf2TkOPn3XRxDKM1uTJZIDi4f2h9zACbsB7B
	9kW+H63w==;
Received: from maestria.local.igalia.com ([192.168.10.14] helo=mail.igalia.com)
	by fanzine2.igalia.com with esmtps 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wywXL-009BHb-A7; Tue, 25 Aug 2026 21:10:19 +0200
Received: from webmail.service.igalia.com ([192.168.21.45])
	by mail.igalia.com with esmtp (Exim)
	id 1wywXJ-00530G-Og; Tue, 25 Aug 2026 21:10:19 +0200
Received: from localhost ([127.0.0.1] helo=webmail.igalia.com)
	by webmail.service.igalia.com with esmtp (Exim 4.98.2)
	(envelope-from <mfo@igalia.com>)
	id 1wywXJ-00000003he5-2ugE;
	Tue, 25 Aug 2026 21:10:17 +0200
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 25 Aug 2026 16:10:17 -0300
From: Mauricio Faria de Oliveira <mfo@igalia.com>
To: =?UTF-8?Q?Uwe_Kleine-K=C3=B6nig?= <u.kleine-koenig@baylibre.com>
Cc: Kees Cook <kees@kernel.org>, Joel Granados <joel.granados@kernel.org>,
 Nathan Chancellor <nathan@kernel.org>, Nicolas Schier <nsc@kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon
 Horman <horms@kernel.org>, kernel-dev@igalia.com,
 linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org,
 fsverity@lists.linux.dev, keyrings@vger.kernel.org, bpf@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kbuild@vger.kernel.org,
 netdev@vger.kernel.org, linux-wpan@vger.kernel.org,
 lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
 coreteam@netfilter.org, linux-sctp@vger.kernel.org,
 linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org,
 bridge@lists.linux.dev, mptcp@lists.linux.dev, rds-devel@oss.oracle.com,
 virtualization@lists.linux.dev
Subject: Re: [PATCH RFC v3 03/13] sysctl, mod_devicetable: add macro
 MODULE_SYSCTL_TABLE
In-Reply-To: <ao1P_mEJdyRExG3v@monoceros>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
 <aomlfGJM61qZKxx2@monoceros> <4e3eaf1d3419e808be046035f114bf6c@igalia.com>
 <aotteDcc588iwC6g@monoceros> <4aa22e41e8ff4bab6638cf0baaa9d07b@igalia.com>
 <ao1P_mEJdyRExG3v@monoceros>
Message-ID: <4a7925a800f0c9b36078a70bf35e960d@igalia.com>
X-Sender: mfo@igalia.com
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Spam-Report: NO, Score=-2.1, Tests=ALL_TRUSTED=-3,BAYES_50=0.8,KAM_DMARC_NONE=0.125,KAM_DMARC_STATUS=0.005
X-Spam-Score: -20
X-Spam-Bar: --

On 2026-08-25 05:24, Uwe Kleine-König wrote:
> Hello,
> 
> On Mon, Aug 24, 2026 at 06:04:03PM -0300, Mauricio Faria de Oliveira wrote:
>> On 2026-08-23 19:12, Uwe Kleine-König wrote:
>> > On Sat, Aug 22, 2026 at 01:57:24PM -0300, Mauricio Faria de Oliveira wrote:
>> >> On 2026-08-22 10:41, Uwe Kleine-König wrote:
>> >> > On Wed, Aug 19, 2026 at 03:16:16PM -0300, Mauricio Faria de Oliveira wrote:
>> >> >> The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table variable
>> >> >> with pointers to a sysctl table's path and entries, and table/entry sizes.
>> >> >
>> >> > That new struct doesn't seem to contain any pointer?
>> >>
>> >> The struct module_sysctl_table fields .path and .table are pointers,
>> >> although with kernel_ulong_t type so that the same 32/64-bit size is
>> >> used in file2alias.c based on KERNEL_ELFCLASS (and not on the host,
>> >> which might differ with CROSS_COMPILE).
>> >
>> > Cross compilation isn't an issue for the already existing device id
>> > structures; many of them also contain pointers.
>> > (While modpost doesn't use the pointers, the size of the structures must
>> > be known to correctly interpret the arrays.)
>> 
>> Indeed. I missed some device_id structures with pointers, and that
>> devicetable-offsets.c is cross-compiled to generate
>> devicetable-offsets.h for file2alias.c to use offsets and sizes of the
>> target architecture.
>> 
>> I'll change .path and .table to pointers in the next version.
> 
> I *think* the existing device-id structs use char[] for strings that are
> relevant for modpost. I look forward to you finding out if there is
> still a justification for that :-D

AFAICT, an array is simpler to read in file2alias as it is stored
directly in the symbol:

For example:

@ include/linux/device-id/of.h 

	struct of_device_id {
	...
		char compatible[128];
	...

@ drivers/net/ethernet/korina.c

	static const struct of_device_id korina_match[] = {
		{
		        .compatible = "idt,3243x-emac",
	...
	MODULE_DEVICE_TABLE(of, korina_match);

which builds

	$ objdump -t drivers/net/ethernet/korina.o | grep __mod_device_table
	0000000000001020 l     O .rodata	0000000000000190
__mod_device_table__kmod_korina__of__korina_match

	$ objdump -s -j .rodata --start-address=0x1020
--stop-address=$((0x1020+0x190)) drivers/net/ethernet/korina.o
	...
	 1020 00000000 00000000 00000000 00000000  ................
	 1030 00000000 00000000 00000000 00000000  ................
	 1040 00000000 00000000 00000000 00000000  ................
	 1050 00000000 00000000 00000000 00000000  ................
	 1060 6964742c 33323433 782d656d 61630000  idt,3243x-emac..
	 1070 00000000 00000000 00000000 00000000  ................
	...

@ scripts/mod/file2lias.c

	#define DEF_FIELD_ADDR(m, devid, f) \
		typeof(((struct devid *)0)->f) *f = ((m) + OFF_##devid##_##f)

	static void do_of_entry(struct module *mod, void *symval)
	{
	...
		DEF_FIELD_ADDR(symval, of_device_id, compatible);
	...
	
void handle_moddevtable(struct module *mod, struct elf_info *info,
                        Elf_Sym *sym, const char *symname)
{
        void *symval;
...
                symval = sym_get_data(info, sym);

On the other hand, a pointer is stored indirectly through a relocation
in the symbol, which is not as simple to read (i.e., 1. find the
relocation section for the symbol's section; 2. find the relocation in
that section by matching relocation offsets with an offset in the symbol
+ symbol address; 3. finally read the relocation's target).

>> > I would be great if your series didn't introduce a new obstacle for
>> > [CHERI].
>> 
>> Absolutely. I'll be happy to adjust the series and testing for that.
>> 
>> Could you please confirm one should just follow [1], which uses [2] to
>> build the LLVM toolchain, and use it to build the kernel [3]?
>> 
>> [1] https://github.com/cheri-linux#building-and-running
>> [2] https://github.com/cheri-linux/buildroot
>> [3] https://github.com/CHERI-Alliance/linux/tree/codasip-cheri-riscv-7.1
> 
> I used
> https://github.com/CHERI-Alliance/meta-cheri/tree/codasip-scarthgap and
> didn't care about toolchain and rootfs. It also has qemu integrated, so
> you can actually test it.

I'll take a look; thanks!

cheers,

> 
> Best regards
> Uwe

-- 
Mauricio
