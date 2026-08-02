Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C027E3939D0;
	Sun,  2 Aug 2026 11:30:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785670253; cv=none; b=e2OBUkddFRUJctkV9dMsQzQAjM1a5bF9ecTmhIIGBhbKahgtcGhhilZ4aSFu07nlADrTIOrA/rAbI328XG7xCAExEQQKbKe6d8Jt3kNnToZL+di/VcHkxjQXd/deaxKOGiJ1sSTdWSSLyVv1XFbSCpJD54HKH26d9CS9njwxE5E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785670253; c=relaxed/simple;
	bh=SgBU/KkozBWGGjb89Fun/guW5kcjbZnKroGc3We92nY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=XRF1v7Pg1CzqEFkQAW4Z54aZ8BZwFA2M8cwSAn6hrc3L1Rw3PIVQC4V/R9Iz7zuw3UqpXKfstyH5oHPGoE/HQSs0uOBW7ChXEfApDt7p4EnQ92Q7UxeCFfZF0HoFg9CuqIWWB9w74KA+28tAnSkgOaaH41tnw3y/0IebhTCrHVg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=IaemgW8p; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="IaemgW8p"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id DE41B21B56;
	Sun, 02 Aug 2026 14:30:38 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=IQPYlM2qwGICHNbBZA72KJ8VQ4h3Va3c5RUfm2xlr8s=; b=IaemgW8pumvO
	JZrsXTRRR5nd+4/Ii4XFW2JSH0rFht86bFhEsmRRKLu05q6xbyiesS0+OO8eMy4p
	sP5hzcZtZa7fCwXzGa+2qyE9/iIUhcuAuN5SAqHTsx0P/DglFTFK2ZVqR4v1U/6B
	P9Pk2uj+FUKjSDKQIhf3e5EMez8PPi0/1RAehhXdlLVJuQ2vpe5bj/8Rq8TVQdpx
	d6ak/cy3ILIvNK+7LQv0DyXZ8Ivu4lm0sR8qqgT8YTD8EbhffUv6un+c1GYCOM0v
	2oNb9Nw/2wKTgKzYU6nO0c0nN+HXsMu6cxaucHgzh7tjwzA3rlSKD0wUja4pACGR
	44JRnYkW2VblLOx6OVpoxSKKkvAZo3dFBMbED5z1xvBYbh7GVg0ZTYlKs1JBQHp0
	ZTHEcc0pNFXbW1BKhj33sFQp2MSOOxdvO2Z8uHdzBfLzsGq04pAGBmcwsCc86RmH
	IRyRLxB5M8rIXglQ9T7Y6/Fer1mGNRHhOcwnDWAKKhMX1iLrq1KCaaEqqMXiAOBS
	kznqjzWGDj+p/kphaH92sgP1Wca3zI6BL+MqE8ZCd/Vvt1G8LLwDL6cW0bVPjgOh
	ixhWr7P1U6bd3MMW+fy+tN/53YtcrbL9ATXQgSJk0ATG9WFC6K4AGhSxzH6MCgrx
	a/Q13SCNBNGKKN/IZI9K9gaoGs2Tnzg=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 02 Aug 2026 14:30:38 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 175AA6087A;
	Sun,  2 Aug 2026 14:30:39 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 672BULK5020376;
	Sun, 2 Aug 2026 14:30:23 +0300
Date: Sun, 2 Aug 2026 14:30:21 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
cc: David Ahern <dsahern@kernel.org>, Ido Schimmel <idosch@nvidia.com>,
        Simon Horman <horms@verge.net.au>,
        "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>, Phil Sutter <phil@nwl.cc>,
        netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, stable@vger.kernel.org,
        Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
        Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
        Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH nf v4 0/3] ipvs: fix destination overload state updates
In-Reply-To: <20260731142748.56545-1-zhaoyz24@mails.tsinghua.edu.cn>
Message-ID: <78bfa99d-a1fa-93d9-36b6-90c590a093f2@ssi.bg>
References: <20260731142748.56545-1-zhaoyz24@mails.tsinghua.edu.cn>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Fri, 31 Jul 2026, Yizhou Zhao wrote:

> IPVS schedulers read destination overload state while connection accounting
> and destination configuration can update it concurrently.
> 
> The first patch adds a single total connection counter. The second patch
> uses it to identify threshold crossings precisely, and updates OVERLOAD at
> the crossings and on a threshold edit under dst_lock. The third patch moves
> configuration-controlled AVAILABLE to a separate cflags word, so it cannot
> clobber OVERLOAD through an unrelated read-modify-write update.
> 
> Readers can still observe stale destination state. This series does not
> provide a cross-field consistent snapshot.
> 
> Changes in v4:
> - Add the total connection counter and threshold-crossing overload updates.
> - Update OVERLOAD under dst_lock at threshold crossings and destination edits.
> - Keep OVERLOAD in dest->flags; drop the flags2/bitops approach.
> - Move AVAILABLE to the separate cflags word, avoiding RMW interference
>   between availability and overload updates.
> - Link to v3: https://lore.kernel.org/netfilter-devel/cover.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn/
> 
> Julian Anastasov (2):
>   ipvs: add totalconns for dest
>   ipvs: properly update the overload flag on dest edit
> 
> Yizhou Zhao (1):
>   ipvs: separate destination availability state

	The patchset looks good to me, thanks!

	My

Acked-by: Julian Anastasov <ja@ssi.bg>

	is needed only for patch 3

	As for the comments from Sashiko:

https://sashiko.dev/#/patchset/20260731142748.56545-1-zhaoyz24%40mails.tsinghua.edu.cn

Patch 1:

- 8-bit shift and overflow: this is exsiting formula that can be
changed separately

- non-atomic update for dest->flags: we fix the write access in patch 3

Patch 2:

- the update of the OVERLOAD flag is serialized in patch 2
and the non-atomic write access fixed in patch 3

Patch 3:

- placing cflags in different cacheline is not our goal,
only separating the flags because while the flags are
alone in their field we do not need bitops for now

>  include/net/ip_vs.h                   | 27 +++++++--
>  include/uapi/linux/ip_vs.h            |  6 --
>  net/netfilter/ipvs/ip_vs_conn.c       | 45 +++++----------
>  net/netfilter/ipvs/ip_vs_core.c       |  6 +-
>  net/netfilter/ipvs/ip_vs_ctl.c        | 81 ++++++++++++++++++++++-----
>  net/netfilter/ipvs/ip_vs_dh.c         |  4 +-
>  net/netfilter/ipvs/ip_vs_lblc.c       |  2 +-
>  net/netfilter/ipvs/ip_vs_lblcr.c      |  8 +--
>  net/netfilter/ipvs/ip_vs_lc.c         |  4 +-
>  net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 -
>  net/netfilter/ipvs/ip_vs_proto_tcp.c  |  2 -
>  net/netfilter/ipvs/ip_vs_sync.c       |  7 +--
>  net/netfilter/ipvs/ip_vs_xmit.c       |  4 +-
>  13 files changed, 118 insertions(+), 80 deletions(-)
> 
> 
> base-commit: 2195424c3da2ef1829a63b807e3a900a90e57d85
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

