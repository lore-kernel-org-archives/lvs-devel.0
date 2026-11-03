Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=193.238.174.39
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793717795;
	b=enjFEsiTBlFlxRydhyxpMYCzwbXqYCRDD6PPxRt1zYVvvUsb61ossHL3pgdKcfy05Enw
	 ab0IOS0UMT2SK7PPCs9G62SEHQTwXyF66ywdNTjqC4P4IrP23Qa7vfQOd1wvM+krGEYic
	 7m1kt3o5nSAPIuTaX1AAig6WesYHFIynENxzvbhrYFg9yi8eXxP7tdqGCMSX7wD4l7xgX
	 tZseZdQRF2IWuCBj7jXISe4lpUOGTEAzYJ7mzm9L8qodoEtnlyH1pkhi/1hHnA8xbHf8b
	 ngC0aabjJLeBfo4jct4fsHvktzUakeWkPgSL1kJfx+QDFNFzN/Koi5wDpqbPUJzaumQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793717795;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:Received:Date:
	 From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:
	 Content-Type;
	bh=VT+LkrT4vnrGeFH9EakLdifSJoARIpmJw19Srjceb+I=;
	b=4AEatWTV/p5XQQqBiOx5sFQ4dIm7T2t/2m+VnNub5JepTyrDxqbZ7grE1VuajioVni8x
	 fLlRV8JaoiRlaOsaZbbwxGfuUtj4lhw6HrvK5CJ6uWObGm2jKHLJyGGYM44EJO2JLuK4i
	 VbdIloZSD+85f814ybnnW8z3mny8XRf274NhcMnOL3OoMmnWQ5pFSLr/JxLuOWwE0vTTF
	 +NaW534D2Xv4Skzoj8rCxMdPfc7GtKlM8iNWD4RdodatdhLBY7j8YLyzJiPzh67XU5wcT
	 O6DcjATlZlPkubbTlE/ADrz0FL/blOSqRFBWWuXxkggeuXqUVXUSogJ8hv2/LvhlXTA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ssi.bg;
	spf=pass smtp.mailfrom=ssi.bg;
	dkim=pass header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=32zSswWr;
	arc=none smtp.remote-ip=193.238.174.39
Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86B51606B240;
	Tue,  3 Nov 2026 14:56:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 86B51606B240
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key, unprotected) header.d=ssi.bg header.i=@ssi.bg header.a=rsa-sha256 header.s=ssi header.b=32zSswWr
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 0285121F8C;
	Tue, 03 Nov 2026 16:56:31 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=VT+LkrT4vnrGeFH9EakLdifSJoARIpmJw19Srjceb+I=; b=32zSswWrbKz/
	qJ+OwRaomT/QS1p86Qu/Ha9uFFg5ZyBVqek0Qg0jvdZaYjlEbzVzkjTD4CDi8rzs
	nbIj2j7f+JkOslIqDQkVzoxAMAw4/vesEkzAzRAAzxrO0udMgOf9IbZ4dnhAzODE
	Z4Dui4KyHVaqFwAFtDhX5Ik1iLNfaJIcLz+8jb6nZwOiXCgJDbvmToyFK7xkCxrC
	pcr4UW3n7inrofYZ5wlIizGjumtPCO6FvXqVHgIok99vHApoStrSpeqggpNHpIqk
	n8szucR3/13L0eYBtMm5UqxJoj/g8g5c35gNCrhjOfmfAUhz4CxfGxxA8AgUPjNt
	xsBbQ7WCEiRT2BK/sOYUv4u5bCAsorqbDyPAFzZ1I6Cne0ze8QVYg2H1yO9+TDum
	B2jlFaj22QbwZfBLsjzyQzFsHuFYYAlJTR7GwRGtYZG8bHOmkcsT1srwaPv18sn5
	8B/Mx0L7EptaZdpY444w9lEnAwN6pqp5Srs5w+WLDoqOJcAmrV8ArRkxlgBdWVLK
	/sRurPtVhJdk6ENeoGNZ75483eDDRD0aH8fGjelhvxmio37Qj63nkjb0oZTm38gm
	6osrzi/mEJe2d2+/f9FOwlcWep2EB62KHVaVpNWuFNSu0EfCnivm/9a2P8OrA4u5
	hFNURFP7kAkKzT+1J1espdqOyJofd8I=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue, 03 Nov 2026 16:56:30 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 8A9FC61DE8;
	Tue,  3 Nov 2026 16:56:30 +0200 (EET)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 6A3EuRWc056153;
	Tue, 3 Nov 2026 16:56:28 +0200
Date: Tue, 3 Nov 2026 16:56:27 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Ren Wei <weir@nebusec.ai>
cc: lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        dsahern@kernel.org, idosch@nvidia.com,
        Simon Horman <horms@verge.net.au>,
        "David S. Miller" <davem@davemloft.net>, edumazet@google.com,
        kuba@kernel.org, pabeni@redhat.com, pablo@netfilter.org, fw@strlen.de,
        phil@nwl.cc, vega@nebusec.ai, zzyy19904204639@163.com,
        jiayuan.chen@linux.dev
Subject: Re: [PATCH nf v2 1/1] ipvs: wait grace period while reusing dest
 from trash
In-Reply-To: <5bac9b2d5e34fcfb326761b948afdf64a3b1d7b9.1790244000.git.zzyy19904204639@163.com>
Message-ID: <6b4a3829-41cb-81b0-547b-5ae4c3839a96@ssi.bg>
References: <cover.1789473164.git.zzyy19904204639@163.com> <5bac9b2d5e34fcfb326761b948afdf64a3b1d7b9.1790244000.git.zzyy19904204639@163.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Sat, 26 Sep 2026, Ren Wei wrote:

> From: Darong Lu <zzyy19904204639@163.com>
> 
> Darong Lu and the VEGA team report a problem with the TWOS scheduler
> that manifests as a loop while traversing the list of destinations. The
> problem occurs if destinations are removed and re-added through the
> destination trash before an RCU grace period has elapsed. As destinations
> are re-added to a new service, CPUs traversing the old destination list
> may never reach the old list head and fail to terminate.
> 
> As the problem is not specific to the TWOS scheduler, use a general
> solution. Jiayuan Chen provided an initial solution based on
> get_state_synchronize_rcu() and cond_synchronize_rcu(), where the grace
> period cookie is saved after a destination is unlinked and moved into the
> destination trash. cond_synchronize_rcu() then ensures the grace period
> before the destination is reused.
> 
> Use a temporary list for destinations removed together from a service or
> during a flush. A single get_state_synchronize_rcu() call records the
> cookie for all destinations before the temporary list is spliced into the
> public destination trash. This also limits destination-trash locking to
> one acquisition for bulk removal.
> 
> Destination edits that remove and re-add an entry to the real-server hash
> table use the same grace-period mechanism. Destinations returned to the
> trash after an estimator failure are put back without recording a new
> cookie.
> 
> Reported-by: Vega <vega@nebusec.ai>
> Reported-by: Darong Lu <zzyy19904204639@163.com>
> Fixes: ceec4c381681 ("ipvs: convert services to rcu")
> Cc: stable@vger.kernel.org
> Co-developed-by: Jiayuan Chen <jiayuan.chen@linux.dev>
> Signed-off-by: Jiayuan Chen <jiayuan.chen@linux.dev>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Darong Lu <zzyy19904204639@163.com>
> Signed-off-by: Ren Wei <weir@nebusec.ai>
> 
> ---
> Changes since v1:
> 
>   - Replace the TWOS-only destination-walk bounds with a general fix for
>     destination list-node reuse through dest_trash, as requested by Julian.
>   - Use Jiayuan's get_state_synchronize_rcu()/cond_synchronize_rcu()
>     scheme so bulk service replacement waits at most once.
>   - Batch removed destinations on a temporary list and splice them into
>     dest_trash under one lock acquisition.
>   - Handle destination rehashes with a saved grace-period cookie and avoid
>     assigning need_gp after ip_vs_rs_unhash() clears in_rs_table.
>   - Drop the duplicate list_add() in the estimator-error return path.
>   - Leave the reported TWOS total_weight and signed weight/overhead
>     multiplication overflows unchanged. They are pre-existing correctness
>     issues, unrelated to this RCU iterator invalidation, and outside this
>     patch's scope. In addition, get_random_u32_below() takes a u32, so the
>     report's description of a negative random bound is not applicable.
>   - The report's characterization of RR as having the same unbounded walk
>     does not apply to the current code: RR limits its traversal to two
>     passes, so no RR-specific change is needed.
> 
> v1 Link: https://lore.kernel.org/all/cover.1789117690.git.zzyy19904204639@163.com/
> ---
>  include/net/ip_vs.h            |   4 +-
>  net/netfilter/ipvs/ip_vs_ctl.c | 109 ++++++++++++++++++++++++++++++++---------
>  2 files changed, 90 insertions(+), 23 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 4c1c739446b7..74cf6d075abf 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c

> @@ -1568,11 +1617,18 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
>  
>  		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
>  		/* On error put back dest into the trash */
> -		if (ret < 0)
> -			ip_vs_trash_put_dest(svc->ipvs, dest, dest->idle_start,
> -					     false);
> -		else
> +		if (ret < 0) {
> +			ip_vs_trash_put_back(svc->ipvs, dest);
> +		} else {
> +			/* Readers may still follow the n_list/d_list of the
> +			 * unlinked dest, wait before linking it again.
> +			 */
> +			cond_synchronize_rcu(dest->rcu_state);
> +			/* need_gp matters only on dest edit, reinit it */
> +			dest->need_gp = 0;
> +
>  			__ip_vs_update_dest(svc, dest, udest, 1);
> +		}

	According to Sashiko we have a problem with the 
ip_vs_start_estimator reusing est->list before a grace period:

https://sashiko.dev/#/patchset/20261102005654.532438-1-pablo%40netfilter.org

	I'm not sure yet if we should post v3 or just a followup fix
would be needed. And the fix against v2 can be to move 
cond_synchronize_rcu() before ip_vs_start_estimator():

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4f7ccf50d8c0..2f903e753c20 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1613,20 +1613,22 @@ ip_vs_add_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest)
 			      IP_VS_DBG_ADDR(svc->af, &dest->vaddr),
 			      ntohs(dest->vport));
 
+		/* Readers may still follow the n_list/d_list of the
+		 * unlinked dest, wait before linking it again.
+		 */
+		cond_synchronize_rcu(dest->rcu_state);
+		/* need_gp matters only on dest edit, reinit it */
+		dest->need_gp = 0;
+
 		ret = ip_vs_start_estimator(svc->ipvs, &dest->stats);
-		/* On error put back dest into the trash */
-		if (ret < 0) {
+		/* On error put back dest into the trash but without
+		 * updating the rcu_state because est->list was not
+		 * unlinked now.
+		 */
+		if (ret < 0)
 			ip_vs_trash_put_back(svc->ipvs, dest);
-		} else {
-			/* Readers may still follow the n_list/d_list of the
-			 * unlinked dest, wait before linking it again.
-			 */
-			cond_synchronize_rcu(dest->rcu_state);
-			/* need_gp matters only on dest edit, reinit it */
-			dest->need_gp = 0;
-
+		else
 			__ip_vs_update_dest(svc, dest, udest, 1);
-		}
 	} else {
 		/*
 		 * Allocate and initialize the dest structure

Regards

--
Julian Anastasov <ja@ssi.bg>

