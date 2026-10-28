Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793191780;
	b=Z3/PHq85rirxCVEQpaXGTpGvvwb0KKF1BlG9fIh+D8tFiPC8Zi6QGFAmBkp0AKnxH1tJ
	 XT9MahrE9s07Zgp9thd/QysoeTN/Nn9lLEwXukG9jArNyzP7By30iJEAJv3sySsPIu/nU
	 jtFdAgEk09DLPZs1J5EuH2TXPrmBm+6fPaP3WyCd6ObeOQIf15y5QJgorvADsx8w8zdtt
	 b8Afj+hs5T9KDbjQP/zB9BlXxAG7GvWdyLRrKvOICzKhsbzHoztE+mMxjagB7iS3EVSIY
	 jH9bqHh/q3Xh80xWDHXrRRriXsBl7wlbRts4ahXuaFjuhZ6Cg+FX2AH+Q9aUBNG273Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793191780;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=vFL6cRdxdM/GvutOrTal3gLSXRDYBsRFQAjUnosz4qU=;
	b=BM+zc6/Xl2KjFXsHFAxXvVbQlFoFjxSXgEM4AdImpvKJuuTtdvjD7v43JveRPFN+VsgL
	 VrR0bQ3Hpt333gDSb8GBffrVPpYofDARiblox7t4jVmCEJosVY4GYkkrn5xXBDnpqGG5+
	 N2JxlKjxs8hPg0Ym2Gxd5YEJfiCC3A/tOWX9eazJH+RUDTlaK6mjiVssK7pds3zANnrvT
	 W4mbqxB4VvhWFWnjg3vT4pxKSgESQn/Qa8oWMIDaWZ0vdQ9oHqqpkzg+GKE2fmPO+NzSn
	 ArPZWQe0OaHGJsA9fQUjpZMAyfXY+aqiOuItPomeku5/gmiuhBcimTnoPgeticOAhNg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iXyejjpd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF35C606A327;
	Wed, 28 Oct 2026 12:49:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iXyejjpd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 52DD21F01828;
	Wed, 28 Oct 2026 12:49:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793191779;
	bh=vFL6cRdxdM/GvutOrTal3gLSXRDYBsRFQAjUnosz4qU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=iXyejjpdwmtKdyZQ4wNmhns8jXDZFgDROrNkHd+b42jEhmnvoJKsPi1NZJZyRWTMv
	 KRRh67fHj2DXO85bKfe/HtSkJQ0a9713nl9xzTaX4nhwejrtxVFiUldfDQ/JrajZkR
	 9YNAGKin9nAOwzI2j3hX7vKG8qbog2rcHyH4t0c8V3cbrm4UaEdnLNt7irOhr1UORq
	 KzOrWHiukj/wPz147KINOUEWy1UD3rN5ojmVAwA6LBnvKdpGQCeDLVZ4RoOSl45O25
	 Dj6dB1nw/m7/iwSQmx4Jespu/zdw0apdoopwnpapXjr85ZIjFori9yJ2ods2cDMAii
	 nCxrM06XZlnww==
Date: Wed, 28 Oct 2026 12:49:35 +0000
From: Simon Horman <horms@kernel.org>
To: Linkui Xiao <xiaolinkui@126.com>
Cc: ja@ssi.bg, dsahern@kernel.org, idosch@nvidia.com, davem@davemloft.net,
	edumazet@kernel.org, kuba@kernel.org, pabeni@redhat.com,
	netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Linkui Xiao <xiaolinkui@kylinos.cn>
Subject: Re: [PATCH net-next] ipvs: annotate the lockless read of
 sysctl_sync_threshold[0]
Message-ID: <20261028124935.GS257209@horms.kernel.org>
References: <20261026083708.617278-1-xiaolinkui@126.com>
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Post: <mailto:lvs-devel@vger.kernel.org>
List-Help: <mailto:lvs-devel+help@vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
List-Owner: <mailto:lvs-devel+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261026083708.617278-1-xiaolinkui@126.com>

On Mon, Oct 26, 2026 at 04:37:08PM +0800, Linkui Xiao wrote:
> From: Linkui Xiao <xiaolinkui@kylinos.cn>
> 
> sysctl_sync_threshold() reads ipvs->sysctl_sync_threshold[0] from the
> packet path without any synchronization: ip_vs_sync_conn_needed(),
> ip_vs_sync_conn_v0() and ip_vs_sync_conn() run in softirq context on
> behalf of ip_vs_in_hook(), ip_vs_conn_expire() is a timer callback and
> ip_vs_proc_conn() runs in the backup sync kthread. The only writer,
> proc_do_sync_threshold(), updates the array with a plain memcpy() while
> holding ipvs->sync_mutex, a mutex none of the readers ever take.
> 
> Commit 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> already recognized this race, but only for the second element of the
> array: "As the sysctl_sync_period now can be 0 use ACCESS_ONCE to avoid
> division by zero". sysctl_sync_threshold() was left with a plain access
> even though both elements live in the same array and are written by the
> same memcpy().
> 
> A stale value is not dangerous here: the element is only compared
> against a packet counter and stored into cp->in_pkts, and an aligned int
> cannot tear on any supported architecture. What the missing annotation
> does allow is for the compiler to reload the element, so the two
> comparisons in ip_vs_sync_conn_needed() can observe different values
> for one and the same packet, and KCSAN reports the unsynchronized
> access.
> 
> Read the element once with READ_ONCE(), exactly like the adjacent
> sysctl_sync_period() has done since 749c42b620a9.
> 
> Fixes: 749c42b620a9 ("ipvs: reduce sync rate with time thresholds")
> Signed-off-by: Linkui Xiao <xiaolinkui@kylinos.cn>

Hi,

I agree that adding a READ_ONCE annotation is appropriate in
sysctl_sync_threshold().

But I wonder if it would also be appropriate to call sysctl_sync_threshold()
only once (per-packet) in ip_vs_sync_conn_needed(). Stashing the value in
a local variable if appropriate.

> ---
>  include/net/ip_vs.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 9a83bff32569..5aa6a94ed104 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -1353,7 +1353,7 @@ static inline int sysctl_conn_max(struct netns_ipvs *ipvs)
>  
>  static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
>  {
> -	return ipvs->sysctl_sync_threshold[0];
> +	return READ_ONCE(ipvs->sysctl_sync_threshold[0]);
>  }
>  
>  static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
> -- 
> 2.25.1
> 
