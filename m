Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3CDB38E8A7;
	Mon, 24 Aug 2026 21:04:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787605474; cv=none; b=KMisXyDPE8iQzJgKO4IoXM/RU4TcrkRtJe/1ibppRWAUh3lGF+GVJGFJAQbOIIkJs85X1ZgZ1pL1nkyWzy8QcpPmpiuG9QX2Xn5eb5JOPHbUdNiN3ivkhuEM3ycqQXF3FS4CHvY3O007CYHZ0Q+FN5tWaehWbVY/HmZNF0VHl/4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787605474; c=relaxed/simple;
	bh=lxWgaRS9cMBj7nzIKwYlcYTMb1BOWwOR02+GTkayrjs=;
	h=MIME-Version:Date:From:To:Cc:Subject:In-Reply-To:References:
	 Message-ID:Content-Type; b=tOJcsLmxSt32AlM8oGbzxW3CAcfdRTAb+tn11139PffJiCr5hehlx8+2AVFXu30urmDTAvjcAotF+sKrJBLl0x4CiDhdqiuJOBB85wCO54imV5b9COHMGuTK43tM6l2tksifIbWRaBa2PB9gzdd1VLOBn9S1qql6YVhPMuhEsO4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=iN4IZpg9; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="iN4IZpg9"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:Content-Type:Message-ID:Subject:Cc:To
	:From:Date:MIME-Version:From:Reply-To;
	bh=8Sz3WqkTSXrjfECQs9syX3OabIkTQfaoXng/2r3y3YI=; b=iN4IZpg94uQW7Qq71fa8RM3vEW
	kYkZAE7Go3UMAHPCbMam59vi5F2G4bm4hWXaQvDe+IlXyYEvE3ysOyCUtZqscnptJn7q2InbNaFyu
	soOubYTTGaNo34QYmi9ty2VVZJpRy9sTLLWPw/LK3yUGKpUbS/U50cLhVIERjuM4Ft+aoWfPy9dJE
	gK9eUfYGXhRTBPX+kELcjgSnMYflg6ghgE0MkoYvLv42MzvqNcu61ANFS228b1Ien6EVqp3z8FXTb
	NuEjADHZt8gwoX1gXWGgh+2+Dm/yjJ9PlQHQ27wXDkIEUhwmsrSPlTWDbQQk59YiDr1KX9MY2E47t
	G2P9q0Eg==;
Received: from maestria.local.igalia.com ([192.168.10.14] helo=mail.igalia.com)
	by fanzine2.igalia.com with esmtps 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wybpt-008hfh-DY; Mon, 24 Aug 2026 23:04:05 +0200
Received: from webmail.service.igalia.com ([192.168.21.45])
	by mail.igalia.com with esmtp (Exim)
	id 1wybps-003b3A-2i; Mon, 24 Aug 2026 23:04:05 +0200
Received: from localhost ([127.0.0.1] helo=webmail.igalia.com)
	by webmail.service.igalia.com with esmtp (Exim 4.98.2)
	(envelope-from <mfo@igalia.com>)
	id 1wybps-00000003RKa-04eN;
	Mon, 24 Aug 2026 23:04:03 +0200
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Mon, 24 Aug 2026 18:04:03 -0300
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
In-Reply-To: <aotteDcc588iwC6g@monoceros>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
 <aomlfGJM61qZKxx2@monoceros> <4e3eaf1d3419e808be046035f114bf6c@igalia.com>
 <aotteDcc588iwC6g@monoceros>
Message-ID: <4aa22e41e8ff4bab6638cf0baaa9d07b@igalia.com>
X-Sender: mfo@igalia.com
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Spam-Report: NO, Score=-2.1, Tests=ALL_TRUSTED=-3,BAYES_50=0.8,KAM_DMARC_NONE=0.125,KAM_DMARC_STATUS=0.005,KAM_SHORT=0.001
X-Spam-Score: -20
X-Spam-Bar: --

On 2026-08-23 19:12, Uwe Kleine-König wrote:
> Hello Mauricio,
> 
> On Sat, Aug 22, 2026 at 01:57:24PM -0300, Mauricio Faria de Oliveira wrote:
>> On 2026-08-22 10:41, Uwe Kleine-König wrote:
>> > On Wed, Aug 19, 2026 at 03:16:16PM -0300, Mauricio Faria de Oliveira wrote:
>> >> The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table variable
>> >> with pointers to a sysctl table's path and entries, and table/entry sizes.
>> > 
>> > That new struct doesn't seem to contain any pointer?
>> 
>> The struct module_sysctl_table fields .path and .table are pointers,
>> although with kernel_ulong_t type so that the same 32/64-bit size is
>> used in file2alias.c based on KERNEL_ELFCLASS (and not on the host,
>> which might differ with CROSS_COMPILE).
> 
> Cross compilation isn't an issue for the already existing device id
> structures; many of them also contain pointers.
> (While modpost doesn't use the pointers, the size of the structures must
> be known to correctly interpret the arrays.)

Indeed. I missed some device_id structures with pointers, and that
devicetable-offsets.c is cross-compiled to generate
devicetable-offsets.h for file2alias.c to use offsets and sizes of the
target architecture.

I'll change .path and .table to pointers in the next version.

> Also sizeof(long) differs between architectures and I can compile for
> arm(32) just fine on amd64.
> 
> Additionally there is hardware out there that has sizeof(void *) = 16
> but sizeof(long) = 8. Up until recently I worked on mainlining that (and
> it has business reasons only I stopped, so I guess and hope I will
> continue at some point in the future). See
> https://lwn.net/Articles/1037974/ for some details if you're interested.

Cool.

> 
> I would be great if your series didn't introduce a new obstacle for
> that.

Absolutely. I'll be happy to adjust the series and testing for that.

Could you please confirm one should just follow [1], which uses [2] to
build the LLVM toolchain, and use it to build the kernel [3]?

[1] https://github.com/cheri-linux#building-and-running
[2] https://github.com/cheri-linux/buildroot
[3] https://github.com/CHERI-Alliance/linux/tree/codasip-cheri-riscv-7.1

>> >> That symbol will be handled by file2alias.c (modpost) with the changes in
>> >> mod_devicetable.h and devicetable-offsets.c.
>> >> 
>> >> The option macros MODULE_SYSCTL_TABLE_{DISABLE,UNIQUE_ID} can be used on
>> >> a per-file basis to disable the macro and change the symbol name pattern.
>> >> 
>> >> Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
>> >> ---
>> >>  include/linux/mod_devicetable.h   |  7 +++++++
>> >>  include/linux/sysctl.h            | 42 +++++++++++++++++++++++++++++++++++++++
>> >>  scripts/mod/devicetable-offsets.c |  6 ++++++
>> >>  3 files changed, 55 insertions(+)
>> > 
>> > Please put the new struct in a separate header. Apart from not being
>> > about a device table, I'm currently work on removing
>> > <linux/mod_devicetable.h>. See commit
>> > ad428f5811bd7fb3d91fa002174de533f9da94d7 for more details.
>> 
>> Sure; I looked at that earlier (thanks for the instructive commit
>> message, by the way) and found the new struct to be similar to "struct
>> cpu_feature isn't really a device_id struct" (not moved), but apparently
>> missed the trailing "fow now", which is clearer now. Fixed for v4.
> 
> Yeah, I didn't move that because it was an outlier in the header as it's
> not a device id. IMHO it should go to something like
> include/linux/cpu_feature.h.

Ack.

cheers,

> 
> Best regards
> Uwe

-- 
Mauricio
