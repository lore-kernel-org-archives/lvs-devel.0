From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 21:05:57 +0200
Message-ID: <f4845fc0806111205j36c912d3vf1b632a3d0777a1c@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <48500A0D.5020304@trash.net>
	 <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>
	 <48501C81.6010800@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213211159; bh=KZc30T8YsS/6kI3C1S+Kyai3pSI=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=eNy/lo0ZaOg83+8YWbKnC4e6RUN03QpY
	EZo/qFe8YOFxHZw5F+oJ09kiOyb+wk/gCRew9FBWxH8KFmlRiIHg5Q==
In-Reply-To: <48501C81.6010800@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 11, 2008 at 8:42 PM, Patrick McHardy <kaber@trash.net> wrote:
> Julius Volz wrote:
>> Another question I was unsure about: is the breaking of the
>> userspace-to-kernel interface even acceptable at all? I think the code
>> would get ugly (and have even more duplication) if you wanted to keep
>> the backwards compatibility. And you have to compile ipvsadm for your
>> kernel version anyways.
>
> Usually its not acceptable. Why do you have compile ipvsadm
> for specific kernel versions?

ipvsadm uses get/set-sockopts on a raw socket to pass commands and
structs (as defined in include/net/ip_vs.h) to the kernel. So the
passed structs have to match exactly between userspace and kernel. The
kernel ip_vs.h also includes a version number that is used to verify
that ipvsadm matches your kernel version.

Julius

-- 
Google Switzerland GmbH
