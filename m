Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39BB0274670;
	Sun, 20 Sep 2026 13:19:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789910373; cv=none; b=qqrm/Eqd0RgtioL660BzD2gk+OLGIvLe6GdF4O7Wq5HXRP5fKX63Di1AA/Kgt6fOcXGm//bejVAD9pv2PZKplTM3a5Zgos3OBHtJKlbbEGhJcYYFD9MZGqtFjc9lcDGQzQrA9EB6Jj2KoGFbti0KnLUcqDPwUdvJOs7Ws8v0jFc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789910373; c=relaxed/simple;
	bh=XnmuP5NwxSD4EV8ytM1irJ5RrI5hO63ek7DRXkyZhgM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=qpTleAKIZxzTkJzV24jBDqcdnA8/VTcCu2ZJIlwUP3MiRjJsM38wQgTs2ChHeyx7QeE7Ipxgk7O9db+6Kf6PNr6mIaiiBZywNOkOmAKdDKwoOjwNB0+4DG3Dqvj6faXzUt5TztlK7YRM6E8d23nY3DqzND2L5PCaDtF6ThjmU7o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=7ezHBD3E; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="7ezHBD3E"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 3501C213A9;
	Sun, 20 Sep 2026 16:19:14 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=8M+WMkHH0D0agE9kPv6SEoGFC9AoIWoXuSkVop/jGYo=; b=7ezHBD3EGqHX
	fWdNoEU/utyyB+rYuVDe3wFoB6h7CLndAUXwCOvlN04DT45ybOSKal156zqwnp1B
	IHjLyL97GhrgWqk7qsDpn8KLVDpl5rNNNDvVHFYd2xccNOLNnC9jE2H/QEJu8kjx
	YaGNT/iLiNTK6bEhbFFWSYX9/kxgFexZe1xvDWT89SbDsOB8728bDfW7rx+f2nvg
	VRkphV+Jbs3R/0zuxFhoF/xeJwu1dpu8vxWEE1x5pe1zsnR9iRsh9lCgK8fcvzD/
	uLstDCenJIfp81A2AGb+9//oTfp3KLVByaXBr9FJ8gtz7A4uBfzgFDde/Nn5uy3f
	uRz9UgnCk+2RYnu0BaRhCS93ktW9jldTjm48DVW/MKm75OeBXpHfUjSXF1VQtlzN
	NhXLtlLNfXog7soskjPJfUiAxHjwQNWdbx3u+eNO+C8SLmj8qZyQ9srm31WFB97f
	jd8grcs98TRY9NgV0aitA6Rp8O9uLJ0N/hyYfd7931nITTCkkM41InY9ei9kbVus
	bY7HGOtksowYDrCV4RZ5xECLAG7dOHT5vtnASJ2qI2s+LHJQOrZ5x1IDrd/uwcN0
	YkfMfvosxnzbmT6U9sPnE+fTfy+JLAUtsunrkAROye/PZ8CLMRwfGk0zQb+ye5EP
	tAo57C1SQMTfrBShP5iWQcztwcLRPFo=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Sun, 20 Sep 2026 16:19:14 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 487AE60762;
	Sun, 20 Sep 2026 16:19:16 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 68KDJ4F8034001;
	Sun, 20 Sep 2026 16:19:05 +0300
Date: Sun, 20 Sep 2026 16:19:04 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Yuan Tan <yuant@nebusec.ai>
cc: Jiayuan Chen <jiayuan.chen@linux.dev>, lvs-devel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>,
        pablo@netfilter.org, fw@strlen.de, phil@nwl.cc, darby.payne@gmail.com,
        zzyy19904204639@163.com, Ren Wei <weir@nebusec.ai>
Subject: Re: [PATCH net 0/1] ipvs: bound twos scheduler destination walks
In-Reply-To: <f04216a2-263a-4e2d-9641-5be0fe4c766f@nebusec.ai>
Message-ID: <d000dd3a-0e8e-5b04-4642-fc1be0ffedaf@ssi.bg>
References: <cover.1789117690.git.zzyy19904204639@163.com> <861399d8-c71f-6589-d4cd-3549d9c5bc00@ssi.bg> <d8aab597-62b5-444a-a6cf-efd2642d9a81@linux.dev> <bfdbe9ba-f213-64e9-668d-e951aa0c2863@ssi.bg> <f04216a2-263a-4e2d-9641-5be0fe4c766f@nebusec.ai>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="-1463811672-461728660-1789910349=:32229"

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-461728660-1789910349=:32229
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 19 Sep 2026, Yuan Tan wrote:

> On 9/17/26 13:06, Julian Anastasov wrote:
> >
> > On Thu, 17 Sep 2026, Jiayuan Chen wrote:
> >
> >> On 9/15/26 2:01 AM, Julian Anastasov wrote:
> >>> 	I assume the problem is caused by the dest_trash.
> >>> It seems, we need a general solution to this problem.
> >>> One option is to penalize with synchronize_rcu() if we detect
> >>> dest that is reused too soon. But even that looks complex to
> >>> implement.
> >>
> >> I think we can use pair(get_state_synchronize_rcu, cond_synchronize_rcu)
> >> instead.
> >> For 'ipvsadm -C && ipvsadm -R', synchronize_rcu is only called once.
> >>
> >>
> >> From ccbb304ab17e00849ea0bf31582d384e6b2768ba Mon Sep 10 00:00:00 2001
> >> From: Jiayuan Chen <jiayuan.chen@linux.dev>
> >> Date: Thu, 10 Sep 2026 19:36:57 +0800
> >> Subject: [PATCH] ipvs: wait for readers before reusing dest from trash
> >>
> >> __ip_vs_unlink_dest() and ip_vs_rs_unhash() remove the dest with
> >> list_del_rcu()/hlist_del_rcu(), so readers can still be on it. If
> >> ip_vs_add_dest() picks the same dest from trash right away,
> >> __ip_vs_update_dest() links it into another service and rs_table,
> >> and those readers follow the new next pointers into a different
> >> list.
> >>
> >> A synchronize_rcu() on the delete side costs one grace period per
> >> dest, which makes 'ipvsadm -C' with many real servers very slow.
> >> Doing it on the reuse side has the same problem with 'ipvsadm -R'.
> >> So record a grace period cookie when the dest goes to trash and use
> >> cond_synchronize_rcu() on reuse. The first wait covers every dest
> >> trashed before it, so a full restore waits at most once.
> >>
> >> Fixes: bcbde4c0a755 ("ipvs: make the service replacement more robust")
> >> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
> >> ---
> >>  include/net/ip_vs.h            | 1 +
> >>  net/netfilter/ipvs/ip_vs_ctl.c | 6 ++++++
> >>  2 files changed, 7 insertions(+)
> >>
> >> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> >> index 32fde731bceb..81b7600ac959 100644
> >> --- a/include/net/ip_vs.h
> >> +++ b/include/net/ip_vs.h
> >> @@ -1013,6 +1013,7 @@ struct ip_vs_dest {
> >>
> >>      struct rcu_head        rcu_head;
> >>      struct list_head    t_list;        /* in dest_trash */
> >> +    unsigned long        rcu_state;    /* GP cookie when trashed */
> >>      unsigned int        in_rs_table:1;    /* we are in rs_table */
> >>  };
> >>
> >> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> >> index 4c1c739446b7..99da7b74500f 100644
> >> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> >> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> >> @@ -1159,6 +1159,7 @@ static void ip_vs_trash_put_dest(struct netns_ipvs
> >> *ipvs,
> >>      /* dest lives in trash with reference */
> >>      list_add(&dest->t_list, &ipvs->dest_trash);
> >>      dest->idle_start = istart;
> >> +    dest->rcu_state = get_state_synchronize_rcu();
> >>      spin_unlock_bh(&ipvs->dest_trash_lock);
> >>  }
> >>
> >> @@ -1566,6 +1567,11 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct
> >> ip_vs_dest_user_kern *udest)
> >>                    IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
> >>                    ntohs(dest->vport));
> >>
> >> +        /* Readers may still follow n_list/d_list of the unlinked
> >> +         * dest, wait before linking it again.
> >> +         */
> >> +        cond_synchronize_rcu(dest->rcu_state);
> >> +
> >>          ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
> >>          /* On error put back dest into the trash */
> >>          if (ret < 0)
> >> --
> >> 2.43.0
> > 	Very good solution, indeed. But it needed some tuning
> > and some other problems need to be solved:
> >
> > - if dest is edited and the dest tunnel parameters changed
> > this leads to rehashing and a forced synchronize_rcu(). If
> > many dests are changed in this way - we got a coffee time...
> >
> > - dest can be put back into dest_trash, so we do not need to
> > update the rcu_state for this case
> >
> > - use single temp list dest_trash to speedup the deleting of
> > service (with many dests) and the service flush (many services with
> > many dests) by using single get_state_synchronize_rcu (which has
> > full memory barrier) and by splicing the temp list with all
> > deleted dests into the public dest_trash list by using single
> > spin lock (ip_vs_trash_put_dests call).
> >
> > 	This is only compile-tested and I hope it can survive
> > the flood tests that break the "two" scheduler lookups...
> 
> 
> Hi Julian and Jiayuan,
> 
> Vega team here. I am wondering what would be the best way to move this
> fix forward?

	We have 2 options:

1. Jiayuan to modify his patch at least to cover the problem
with returned dest back in trash:

- get_state_synchronize_rcu() can not be in ip_vs_trash_put_dest()
but only after the 2nd call

- cond_synchronize_rcu() should be moved before __ip_vs_update_dest()
as in my patch

- then my v2 patch will be on top of his patch

	We should present them for AI reviews together,
in same patchset, I guess.

2. I can post my change after adding a proper commit
message (Co-developed-by, etc), then it can be attached as
1/1 to your modified 0/1 problem report

	I'll wait Jiayuan's decision.

> Would you prefer Darong to test Julian's version and send a v2,

	Yes, I rely on your very good test tools :) You can test
the already posted version or the next one we are discussing to
submit.

> crediting both of you with Suggested-by or Co-developed-by tags?
> 
> Alternatively, if either of you would prefer to submit the patch, please
> include:
> 
> Reported-by: Vega vega@nebusec.ai <mailto:vega@nebusec.ai>
> Reported-by: Darong Lu zzyy19904204639@163.com
> <mailto:zzyy19904204639@163.com>

	Sure

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-461728660-1789910349=:32229--

