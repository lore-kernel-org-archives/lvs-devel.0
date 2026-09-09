Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C3ED37DABC;
	Wed,  9 Sep 2026 17:44:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788975858; cv=none; b=ReToka+wge1fBGryV7Vd0QjXveYeFKPh9s7xaQf8q3tObDxeoYGnawmyYCCy7w1PguH/dKmcnY1FL6tNxCRMoFIGXn+LT1okiqfHYiqJd5QPWeeB/nNJMGKq3q8IZguIcIJ8KVKJ/nqhSAlPqJ1H7LQqxB1fsvIhTbCegN/FuXE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788975858; c=relaxed/simple;
	bh=MiiLH/OdJXMg0v8zo9wnApI3cu3wqp6cF0tWI27hb6c=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=hMLYtpGMEoz8dtDIkYNiCiaMKIQmNmPsnaaj5MF1nTFarNSdIDwCOO2+44FqS2Wi4ZzG6YTIm2ytBtXjDTsaKn10mEyXhNkSDkGZgfGQi7fy8yIiW5QN5vsET0CUhjKzPHDX5yFeEEtp/oe+W5gYSNIq3KkHGdNSExJrKFxINUE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=qN0UmTLV; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="qN0UmTLV"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id E11B322738;
	Wed, 09 Sep 2026 20:44:08 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=QYKRAQ0r6ZCGOZ9b51KFtxND4eEbYBAPgnmZCP3+T0k=; b=qN0UmTLVizE7
	7yagMMRJJVvxXHbcZWubWe5RpdmoXG09wWwIqi028L4bQ86CCFr5mdAeC0zfKFtw
	qOGqoquLLA8ohHYYXd2orSvQtHqzu1mK8k7D44qo7T+WotuFb1+lcQzixX3YvrQL
	FzjPcp+FRY7GgQ3Q/I4XV8jJ20B1S0nQV80uA042BiBe6GRg58gNNRsgFQ/7B80N
	G6GRCcfxO0zPwyW7N3yco2TgRVdNpIGdbQhliINxsXmPlEcrIp6oWqfFaF/ktfIz
	+QN1NQ35wlHI+tqCiW+CdvV5zE905svV+H/jHKEqiM2cpZ0V/SR5pADsZ00CsfbM
	ey4EmmSBLiip2JRoc1goTXLIQG3K+eeQDXcmh6qqNlq8P4s0K9eCJgSJ8YdkGqL3
	773MnTXR69nbXdj5Hx+2jaoIJ9Vz2wDMjAVOhq4k3bNd9r2EEsPwSkW52GIo8GNd
	i4gHghhD5KuAtYm//TbNUbQaX7AeskYHLAV8xWvlZShl0OIr1bvVyQVMNnh2RvnU
	s2j6HjnB9MNIlCux0o/Euh5lAVWO5XlgUKbVLOcIwJKkfJHLc0bPNENWr8MD52QJ
	MvvWIFY5M9dMk+QJAcPGz2MpztxKua5GQSrRA0kzpguIg57nhBXn/Zt2tN0n7eh5
	dMuwGgLTj+kkUfEIyOlvse1SxLfv5OU=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 09 Sep 2026 20:44:08 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 362AA607BF;
	Wed,  9 Sep 2026 20:44:10 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 689Hi4mN077569;
	Wed, 9 Sep 2026 20:44:06 +0300
Date: Wed, 9 Sep 2026 20:44:04 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
Subject: Re: [PATCH nf] ipvs: fix more races around the overload flag
In-Reply-To: <20260907183453.112559-1-ja@ssi.bg>
Message-ID: <368ee412-ae97-a977-f28b-e94727f79b27@ssi.bg>
References: <20260907183453.112559-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 7 Sep 2026, Julian Anastasov wrote:

> Sashiko warns that we still have races when the dest overload
> thresholds are updated. If we narrow the range between
> thresholds the lockless readers (ip_vs_bind_dest and
> ip_vs_unbind_dest) may use old threshold values and
> as result to skip the required flag change.
> 
> To solve the problem ip_vs_bind_dest() and ip_vs_unbind_dest()
> will have the chance as before to change the overload
> state not only at the exact threshold positions but
> at any conn count below the lower and above the upper thresholds.
> To make it work without entering the locked region for
> every connection, we introduce l_threshold_val. Together with
> u_threshold_val we will switch between two states:
> 
> 1. not overloaded: where l_threshold_val is set to 0
> to close the door for more ip_vs_unbind_dest() calls
> to clear the overload state.
> 
> 2. overloaded: where u_threshold_val is set to INT_MAX
> to close the door for more ip_vs_bind_dest() calls
> to set the overload state.
> 
> If a race occurs, multiple CPUs can repeat the state change
> but this should be for short time window.
> 
> With the introduction of l_threshold_val the
> IP_VS_DEST_F_OVERLOAD flag and the 'flags' field are not
> needed anymore. We will use the ip_vs_dest_is_overloaded()
> helper for all places that read the overload state.
> 
> Do not check IP_VS_DEST_CF_AVAILABLE in ip_vs_dh.c because
> we do not hold reference to dest after it is removed and
> rely on RCU to access the available dests.
> 
> To reduce the cacheline accesses while selecting destination,
> keep the mostly used fields (weight and l_threshold_val)
> at the first read-mostly cacheline together with the hash
> nodes.
> 
> Fixes: 8f843441c4e7 ("ipvs: properly update the overload flag on dest edit")
> Link: https://sashiko.dev/#/patchset/20260810190621.894119-1-pablo%40netfilter.org
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  include/net/ip_vs.h              | 50 ++++++++++++++++++++------------
>  net/netfilter/ipvs/ip_vs_conn.c  |  8 ++---
>  net/netfilter/ipvs/ip_vs_ctl.c   | 38 ++++++++++++------------
>  net/netfilter/ipvs/ip_vs_dh.c    | 16 ++--------
>  net/netfilter/ipvs/ip_vs_fo.c    |  2 +-
>  net/netfilter/ipvs/ip_vs_lblc.c  |  4 +--
>  net/netfilter/ipvs/ip_vs_lblcr.c |  8 ++---
>  net/netfilter/ipvs/ip_vs_lc.c    |  2 +-
>  net/netfilter/ipvs/ip_vs_mh.c    |  2 +-
>  net/netfilter/ipvs/ip_vs_nq.c    |  2 +-
>  net/netfilter/ipvs/ip_vs_ovf.c   |  2 +-
>  net/netfilter/ipvs/ip_vs_rr.c    |  2 +-
>  net/netfilter/ipvs/ip_vs_sed.c   |  4 +--
>  net/netfilter/ipvs/ip_vs_sh.c    |  2 +-
>  net/netfilter/ipvs/ip_vs_twos.c  |  4 +--
>  net/netfilter/ipvs/ip_vs_wlc.c   |  4 +--
>  net/netfilter/ipvs/ip_vs_wrr.c   |  2 +-
>  17 files changed, 76 insertions(+), 76 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 8f9a8e491ad6..5de69404a5e0 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1309,32 +1309,32 @@ void ip_vs_stats_free(struct ip_vs_stats *stats)
>   * - conns reach u_threshold and exceed it: set the flag
>   * - conns go below l_threshold (or 75% of u_threshold): clear the flag
>   */
> -static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, int mode)
> +static void __ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
>  {
>  	int conns;
>  	u32 l, u;
>  
>  	lockdep_assert_held(&dest->dst_lock);
>  	u = READ_ONCE(dest->u_threshold);
> -	if (!u)
> -		goto unset;
> -	l = READ_ONCE(dest->l_threshold_val);
> -	conns = atomic_read(&dest->totalconns);
> -	if (conns >= (mode > 0 ? l : u)) {
> -		dest->flags |= IP_VS_DEST_F_OVERLOAD;
> -		return;
> +	if (u) {
> +		/* Low threshold defaults to 75% of upper threshold */
> +		l = READ_ONCE(dest->l_threshold) ? : (u - (u >> 2));
> +		conns = atomic_read(&dest->totalconns);
> +		if (conns >= (overload ? l : u)) {
> +			WRITE_ONCE(dest->u_threshold_val, INT_MAX);
> +			WRITE_ONCE(dest->l_threshold_val, l);
> +			return;
> +		}
>  	}

	Comments about the Sashiko review here:

https://sashiko.dev/#/patchset/20260907183453.112559-1-ja%40ssi.bg

Sashiko said:

> Can a lockless time-of-check to time-of-use race here permanently brick 
> an IPVS destination?
> It seems there is a race window between reading the connections and 
> updating
> l_threshold_val. Because l_threshold_val acts as a dynamic gate for
> ip_vs_unbind_dest(), concurrent unbinds might fail to synchronize with 
> this thread.
> 
> If we have the following sequence:
> CPU1 in ip_vs_bind_dest():
>   - increments totalconns to u_threshold
>   - evaluates tc >= u_threshold_val and calls 
> ip_vs_dest_update_overload()
>   - acquires dst_lock in __ip_vs_dest_update_overload()
>   - reads conns = atomic_read(&dest->totalconns)
> CPU2 in ip_vs_unbind_dest():
>   - decrements totalconns, returning the old value
>   - evaluates tc <= READ_ONCE(dest->l_threshold_val)
>   - CPU1 hasn't updated l_threshold_val yet, so it is still 0
>   - the condition is false, so CPU2 bypasses the lock and does not
>     clear the overload state
> CPU1 resumes:
>   - evaluates conns >= l (using its stale read)
>   - writes INT_MAX to u_threshold_val and l to l_threshold_val
>   - returns, leaving the destination in an overloaded state
> 
> Because the destination is marked overloaded, it receives no new 
> traffic.
> And because it has no traffic, unbind will never be called to clear the
> overloaded state. Does this leave the destination permanently bricked 
> with 0 active connections?

	The destination is not permanently blocked because for
this connection ip_vs_unbind_dest() should be called after
its timer expires. But it is true that the dest can be blocked
for long time.

	My opinion is that we still should apply this patch because
it improves the handling from the previously applied patch. And we
are still searching for solution that does not hurt the performance.

	The problem is that the CPU that is about to mark the dest
as overloaded can be interrupted while at the same time timers
expired on other CPUs can reduce the total conns down to 1
leaving the only connection attached to a blocked dest
where the schedulers do not select this dest until the
connection expires and clears the overload state.

	May be followup patches should allow the schedulers
to re-evaluate the overload state if not done "recently".
Or some other mechanism that will unblock the dest.

> -	if (conns >= (mode < 0 ? u : l))
> -		return;
>  
> -unset:
> -	dest->flags &= ~IP_VS_DEST_F_OVERLOAD;
> +	WRITE_ONCE(dest->u_threshold_val, u ? : INT_MAX);
> +	WRITE_ONCE(dest->l_threshold_val, 0);
>  }
>  
> -void ip_vs_dest_update_overload(struct ip_vs_dest *dest, int mode)
> +void ip_vs_dest_update_overload(struct ip_vs_dest *dest, bool overload)
>  {
>  	spin_lock_bh(&dest->dst_lock);
> -	__ip_vs_dest_update_overload(dest, mode);
> +	__ip_vs_dest_update_overload(dest, overload);
>  	spin_unlock_bh(&dest->dst_lock);
>  }
>  
> @@ -1406,15 +1406,13 @@ __ip_vs_update_dest(struct ip_vs_service *svc, struct ip_vs_dest *dest,
>  
>  	if (READ_ONCE(dest->u_threshold) != udest->u_threshold ||
>  	    READ_ONCE(dest->l_threshold) != udest->l_threshold) {
> +		bool overload;
> +
>  		spin_lock_bh(&dest->dst_lock);

	As for the uninitialized u_threshold_val, the initialization
will happen later, so it is deferred, which is unintentionally better
from configuration point of view.

>  		WRITE_ONCE(dest->u_threshold, udest->u_threshold);
>  		WRITE_ONCE(dest->l_threshold, udest->l_threshold);
> -		/* Low threshold defaults to 75% of upper threshold */
> -		WRITE_ONCE(dest->l_threshold_val,
> -			   udest->l_threshold ? :
> -			   (udest->u_threshold -
> -			    (udest->u_threshold >> 2)));
> -		__ip_vs_dest_update_overload(dest, 0);
> +		overload = ip_vs_dest_is_overloaded(dest);
> +		__ip_vs_dest_update_overload(dest, overload);
>  		spin_unlock_bh(&dest->dst_lock);
>  	}

Regards

--
Julian Anastasov <ja@ssi.bg>

