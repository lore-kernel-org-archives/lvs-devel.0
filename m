From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 00/26] IPVS: Add first IPv6 support to IPVS.
Date: Wed, 11 Jun 2008 20:23:45 +0200
Message-ID: <f4845fc0806111123r108348d3s6906bf2b7145bdea@mail.gmail.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
	 <48500A0D.5020304@trash.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1213208656; bh=PaHOt4fE6FJEBn9/dTZxw39SJ5I=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:Cc:
	 In-Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	 Content-Disposition:References; b=SbkgrhO8wfkK/mCbMh9ZylUImO2vjwgW
	rnOXH4PsBlvAvendBxbdxnDncuZFGJ1ESlIE2YjcTbBybHJtdfXpAg==
In-Reply-To: <48500A0D.5020304@trash.net>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org

On Wed, Jun 11, 2008 at 7:23 PM, Patrick McHardy <kaber@trash.net> wrote:
> I briefly looked over the patches I didn't comment on.
> I think there's too much duplication everywhere, a lot of
> them look like they could avoid almost all duplication by
> handling differences at a higher layer or simply sharing
> the code (like hashing).

Yes, the duplication is high unfortunately. I must admit that I didn't
feel secure enough to restructure all the existing code without
breaking it, so I copied lots of functions and modified them for IPv6.
My main goal was to keep all the old v4 stuff working first and then
remove the duplication later (or hope for smarter people).

So I obviously don't expect this to be ready for inclusion, but I will
have a lot of time to work on it (I'm doing it as an intern project)
and learn as long as I get good feedback like yours on what to
improve.

Another question I was unsure about: is the breaking of the
userspace-to-kernel interface even acceptable at all? I think the code
would get ugly (and have even more duplication) if you wanted to keep
the backwards compatibility. And you have to compile ipvsadm for your
kernel version anyways.

Julius

-- 
Google Switzerland GmbH
