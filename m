Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD84A3AD524;
	Sat, 22 Aug 2026 16:57:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787417877; cv=none; b=PWZICcON09mlh5yYX/YH6fC62fZRhJtCWPtdvTy44GHSe1jyAaEBJg1ci3BLCBE9fdahUicl7fXZMCuFoto6zifmgPZDEX38vqKFRaOCqhHiqUU92trMf3l93bcCoHOObgOgBpNKmDG613M70t99z/L0chXIoAaeeaD1SLlBeas=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787417877; c=relaxed/simple;
	bh=ZyUMEwGyn3c46u0NkjvE6TPVTBK/Rka0z+HlcRnaztA=;
	h=MIME-Version:Date:From:To:Cc:Subject:In-Reply-To:References:
	 Message-ID:Content-Type; b=qLYInuKIw+SQfQQdUEA6QJ5BE9lNUnohz34zWlmlq6GoA+Ss2Ip8jEdG+6MV+qa4FuG6nZ/t5rSgIsVxGFCr7v8zekAjK6GxXLVbL32Ftv72AZp8uf+YK6K/dKQ3RqGrH/ut64Nho4GM7YWorUyfW7ZZU4yLtlIXAyo4N+SXkgE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=ZbJz80fF; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="ZbJz80fF"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:Content-Type:Message-ID:Subject:Cc:To
	:From:Date:MIME-Version:From:Reply-To;
	bh=yYKcqboW2hgBCm128jlsW+fEFCrg/+/6fC0pPe2118M=; b=ZbJz80fFfEN7nkrQcV8gZZ+oUE
	hK4b5lCtnutJj1yjrMLG1BeMt0eRSLfkdrmKM4eHnKGLezlJuWTp5PE4Yk5I8WwkhFUD/NLwoWW4n
	Kgoi6umxhGYQrdvfuOl1eQJfSB2LqC2y7kE7ojq4xPJnthVMSJ1B/QHaWoEf/g77lioyDCXJrLvb/
	oQl5Mf6I5KIUU5NF4+0OK4F/1HCTyG3AyKjVGEAWQTKkqOyLofBPXDv5TiWlXFVXOhetvM/QCUWOj
	m7wOT9QmpBgbf2IXG+RYeBlApw4DIxLHSB8HUlP5n8fh+hpB0Atv0lItGBl1gr+NsfEKmAfTF0dcm
	tc6UfpYw==;
Received: from maestria.local.igalia.com ([192.168.10.14] helo=mail.igalia.com)
	by fanzine2.igalia.com with esmtps 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1wxp25-007Utx-Ae; Sat, 22 Aug 2026 18:57:25 +0200
Received: from webmail.service.igalia.com ([192.168.21.45])
	by mail.igalia.com with esmtp (Exim)
	id 1wxp24-0013TF-9m; Sat, 22 Aug 2026 18:57:25 +0200
Received: from localhost ([127.0.0.1] helo=webmail.igalia.com)
	by webmail.service.igalia.com with esmtp (Exim 4.98.2)
	(envelope-from <mfo@igalia.com>)
	id 1wxp24-00000002uHU-0yE7;
	Sat, 22 Aug 2026 18:57:24 +0200
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Sat, 22 Aug 2026 13:57:24 -0300
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
In-Reply-To: <aomlfGJM61qZKxx2@monoceros>
References: <20260819-sysctl-module-aliases-v3-0-aab90569365d@igalia.com>
 <20260819-sysctl-module-aliases-v3-3-aab90569365d@igalia.com>
 <aomlfGJM61qZKxx2@monoceros>
Message-ID: <4e3eaf1d3419e808be046035f114bf6c@igalia.com>
X-Sender: mfo@igalia.com
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Spam-Report: NO, Score=-2.1, Tests=ALL_TRUSTED=-3,BAYES_50=0.8,KAM_DMARC_NONE=0.125,KAM_DMARC_STATUS=0.005
X-Spam-Score: -20
X-Spam-Bar: --

On 2026-08-22 10:41, Uwe Kleine-König wrote:
> Hello,

Hey,

> 
> On Wed, Aug 19, 2026 at 03:16:16PM -0300, Mauricio Faria de Oliveira wrote:
>> The MODULE_SYSCTL_TABLE macro emits a struct module_sysctl_table variable
>> with pointers to a sysctl table's path and entries, and table/entry sizes.
> 
> That new struct doesn't seem to contain any pointer?

The struct module_sysctl_table fields .path and .table are pointers,
although with kernel_ulong_t type so that the same 32/64-bit size is
used in file2alias.c based on KERNEL_ELFCLASS (and not on the host,
which might differ with CROSS_COMPILE).

> 
>> That symbol will be handled by file2alias.c (modpost) with the changes in
>> mod_devicetable.h and devicetable-offsets.c.
>> 
>> The option macros MODULE_SYSCTL_TABLE_{DISABLE,UNIQUE_ID} can be used on
>> a per-file basis to disable the macro and change the symbol name pattern.
>> 
>> Signed-off-by: Mauricio Faria de Oliveira <mfo@igalia.com>
>> ---
>>  include/linux/mod_devicetable.h   |  7 +++++++
>>  include/linux/sysctl.h            | 42 +++++++++++++++++++++++++++++++++++++++
>>  scripts/mod/devicetable-offsets.c |  6 ++++++
>>  3 files changed, 55 insertions(+)
> 
> Please put the new struct in a separate header. Apart from not being
> about a device table, I'm currently work on removing
> <linux/mod_devicetable.h>. See commit
> ad428f5811bd7fb3d91fa002174de533f9da94d7 for more details.

Sure; I looked at that earlier (thanks for the instructive commit
message, by the way) and found the new struct to be similar to "struct
cpu_feature isn't really a device_id struct" (not moved), but apparently
missed the trailing "fow now", which is clearer now. Fixed for v4.

Thank you,

> 
> Best regards
> Uwe

-- 
Mauricio
