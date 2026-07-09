Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc [91.216.245.30])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F5AF18C008;
	Thu,  9 Jul 2026 11:46:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.216.245.30
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783597599; cv=none; b=g21eSbd40AJwLihlDYuriau2LkbngWvWnrSw8RVQg8q3XZQQtUUXkyKmBMTQaaOX7bkMD2Dys9gfwr2DpWq4Ej485SxlMowuJUGyC39ZFXf8Xaw1DGzghI72IjkvwdLgdBl2+IRCIt1ZVNS4fyn/tiBjQnXg+GF1sGOL2zpciUU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783597599; c=relaxed/simple;
	bh=twmEzHea4QAYe+6lVhj7Zqe+nc0w7Ixcq9xJL1Mm1WI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=bE4l8EVOhtds8cZLkMfbU3g3dOAwYK8P72wVLhR0/XH+OEv1nEYl47Zo+mNtLU8RxWP2l3o6I++0WZvH0tFLDqD+PEnyFT+JMkZAjy0yy0tQfwEclD0//EJJ9JQQf0Vlj8J2KP7UrRwBOI8/1R3eXNU6oVacLOdJwLKbpz1Eszo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de; spf=pass smtp.mailfrom=strlen.de; arc=none smtp.client-ip=91.216.245.30
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=strlen.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=strlen.de
Received: by Chamillionaire.breakpoint.cc (Postfix, from userid 1003)
	id 0F4F260293; Thu, 09 Jul 2026 13:46:27 +0200 (CEST)
Date: Thu, 9 Jul 2026 13:46:26 +0200
From: Florian Westphal <fw@strlen.de>
To: Julian Anastasov <ja@ssi.bg>
Cc: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>,
	Simon Horman <horms@verge.net.au>, David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>, Phil Sutter <phil@nwl.cc>,
	Alexander Frolkin <avf@eldamar.org.uk>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	stable@vger.kernel.org,
	Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
	Ao Wang <wangao@seu.edu.cn>, Xuewei Feng <fengxw06@126.com>,
	Qi Li <qli01@tsinghua.edu.cn>, Ke Xu <xuke@tsinghua.edu.cn>
Subject: Re: [PATCH nf] ipvs: make destination flags atomic
Message-ID: <ak-KErd1a0NHGN-D@strlen.de>
References: <20260707085706.96322-1-zhaoyz24@mails.tsinghua.edu.cn>
 <41c3d792-af7d-5582-5057-ac3df5f7bfd6@ssi.bg>
 <91509A0C-9E4A-4F0E-A45C-ABD29396067E@mails.tsinghua.edu.cn>
 <afcdb34c-ec10-de8e-083c-624bcedca90e@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <afcdb34c-ec10-de8e-083c-624bcedca90e@ssi.bg>

Julian Anastasov <ja@ssi.bg> wrote:
> 	After looking again at the code, I think we can
> do it in different way:
> 
> - IP_VS_DEST_F_AVAILABLE and IP_VS_DEST_F_OVERLOAD are defined
> in include/uapi/linux/ip_vs.h but we never export them to user
> space. So, we are free to change them. We can move them to 
> include/net/ip_vs.h, see below...
> 
> - IP_VS_DEST_F_AVAILABLE is changed only under service_mutex,
> so we can keep its usage
> 
> - IP_VS_DEST_F_OVERLOAD needs different access methods.
> We can add 'unsigned long flags2;', may be after l_threshold.
> And to switch to such usage (F_OVERLOAD -> FL_OVERLOAD):
> 
> 	- test_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
> 	- set_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
> 
> 		Sometimes if (test_bit()) clear_bit() can avoid
> 		full memory barrier in ip_vs_dest_update_overload()
> 
> 	- clear_bit(IP_VS_DEST_FL_OVERLOAD, &dest->flags2)
> 		test_bit() guard can help here too
> 
> 	As there are other races involved, something like
> this can be a starting point for such change. It tries harder
> to update the overload flag on dest edit/add but it does not
> include the proposed bitops:
>
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 49297fec448a..b34631270e24 100644

Who is supposed to do what?

I.e., are you going to submit this officially as replacement
for the v2 of this patch or do you expect the sumbitters of
this patch to rework their v2 along these lines?
