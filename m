Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8638C577E4D;
	Wed,  9 Sep 2026 14:34:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788964455; cv=none; b=sWDL/Me/vask921DYxR1r2FYJfCEF3qFAp7Cpe4MDOI4zFZRRvkL0DS6adRAOR+Tbb8UhU1tsSSQSqsD66GtUeNx7URwQWC2AC+1CpLjXiN81cVNXcI8AlinIrhROO/CUWjJrGqkb8e4SWNZUdwG0mBxKbHhz9lVD1jWH2RsAH8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788964455; c=relaxed/simple;
	bh=7rrpwKzPieakJrE8QBJSYZFReVYKClO4DO96dB6u+zY=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=mdotUgx8NUSdnXH4bI0PvfXqvyMHN7IFW4aW330jSFgCPhJbGNCCXBau5s1aE+Iu/ybyBp272+jkH9EtfGmnqJfrMnxZo3Al3CehyirYE2qcFx2YxP/qKP+ZmuQPmH0K4ssjvKp6XDYbGZmWPiiB3LjZhGW69IhkCPShJ4IV2/Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=qulj3xKY; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="qulj3xKY"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 2F25222737;
	Wed, 09 Sep 2026 17:34:05 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=rDRxLCngMbGWQPPHSi2N8R8DkDv9h+RMYdFkX0NtrKk=; b=qulj3xKYLHQ6
	1DYmQvBT47nTychT+Mdw18XEb5ICPrTr+tMnRebyp5kX+Z0n5rO9Ge6T2h234mD3
	kF6iRYk4zLgWXS9hO3yzX8JmSZCWKgwJXtl0LUNRa9yO17fcFswdjFBT+0FMPMIQ
	QsR7xAjY1/uh4UMTvcMTtQVKzdM0Ue466dKgbpQ5iPmU0/rHZ/UeURlBDv4vAhl6
	E0rRGb8OC7CF8viwJZ+vflXns7DCDCclsgEmFrnxw3brhLM1P1ZGdMpJzDE2/ZEo
	R1LkQk76ypL9ZSHyjXs4MRQphxhvV+Tsh+UQJz4wLvpo7+65QgPP7oa3QYcCBxmi
	wrl1byJxEJJObPYiqRlwmxVxvLl6GzcWQ7EhjalT3jtIhxAC8r9BHPpB3ObWP16L
	th1ol1DViSPlgCWsxzgUKKWzdX63mcd5tcWCHNULvYVtPEuDrfICF6xVwXmgPBga
	NVKc54alVCOhk/CXqZtmmC3PAOHzTDIRfSry1ZwFkRjXa1iITl5U+z0sAFVHDDu+
	S7WBJtaXNXgJJ1sLclI7gI6AklosxmYGoH15XdgBigvqQmDUOrmqGw3Q9LAGKzgN
	0BlwflsKvvFKAT1D3ofZQL11xyQe5ixp9Tp2oLaHCkozwFpt4Vte/vAu2erhbsef
	1PxWGR1cnjw6OwB8BiQg/p+c244TKFA=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Wed, 09 Sep 2026 17:34:05 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 96AE860888;
	Wed,  9 Sep 2026 17:34:06 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.2/8.18.2) with ESMTP id 689EY5BZ060541;
	Wed, 9 Sep 2026 17:34:05 +0300
Date: Wed, 9 Sep 2026 17:34:05 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>,
        lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org
Subject: Re: [PATCH nf] ipvs: read the seq_mask only once on sync
In-Reply-To: <20260909111338.44357-1-ja@ssi.bg>
Message-ID: <6bee4191-accb-4e07-c20e-ac80c30b2d4b@ssi.bg>
References: <20260909111338.44357-1-ja@ssi.bg>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Wed, 9 Sep 2026, Julian Anastasov wrote:

> Sashiko reports for possible heap buffer overflow when
> generating sync message for the v0 and v1 message formats.
> We should read the seq_mask from cp->flags only once because
> another CPU can concurrently set the mask between the two
> reads. Note that IPVS does not set the seq_mask anymore
> for the ip_vs_ftp.c helper starting from commit 7f1c40757951
> ("IPVS: make FTP work with full NAT support") (2.6.36+).
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Link: https://sashiko.dev/#/patchset/20260903004149.1037028-1-pablo%40netfilter.org
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

	Ignore this, will send different patch with more checks...

https://sashiko.dev/#/patchset/20260909111338.44357-1-ja%40ssi.bg
        
pw-bot: changes-requested

> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index 5383aeafb0ae..07303d74e39f 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -543,8 +543,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	struct ip_vs_sync_conn_v0 *s;
>  	struct ip_vs_sync_buff *buff;
>  	struct ipvs_master_sync_state *ms;
> +	unsigned int seq_mask, len;
>  	int id;
> -	unsigned int len;
>  
>  	if (unlikely(cp->af != AF_INET))
>  		return;
> @@ -564,8 +564,8 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	id = select_master_thread_id(ipvs, cp);
>  	ms = &ipvs->ms[id];
>  	buff = ms->sync_buff;
> -	len = (cp->flags & IP_VS_CONN_F_SEQ_MASK) ? FULL_CONN_SIZE :
> -		SIMPLE_CONN_SIZE;
> +	seq_mask = READ_ONCE(cp->flags) & IP_VS_CONN_F_SEQ_MASK;
> +	len = seq_mask ? FULL_CONN_SIZE : SIMPLE_CONN_SIZE;
>  	if (buff) {
>  		m = (struct ip_vs_sync_mesg_v0 *) buff->mesg;
>  		/* Send buffer if it is for v1 */
> @@ -599,7 +599,7 @@ static void ip_vs_sync_conn_v0(struct netns_ipvs *ipvs, struct ip_vs_conn *cp,
>  	s->daddr = cp->daddr.ip;
>  	s->flags = htons(cp->flags & ~IP_VS_CONN_F_HASHED);
>  	s->state = htons(cp->state);
> -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> +	if (seq_mask) {
>  		struct ip_vs_sync_conn_options *opt =
>  			(struct ip_vs_sync_conn_options *)&s[1];
>  		memcpy(opt, &cp->sync_conn_opt, sizeof(*opt));
> @@ -635,6 +635,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  	int id;
>  	__u8 *p;
>  	unsigned int len, pe_name_len, pad;
> +	unsigned int seq_mask;
>  
>  	/* Handle old version of the protocol */
>  	if (sysctl_sync_ver(ipvs) == 0) {
> @@ -674,7 +675,8 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  #endif
>  		len = sizeof(struct ip_vs_sync_v4);
>  
> -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK)
> +	seq_mask = READ_ONCE(cp->flags) & IP_VS_CONN_F_SEQ_MASK;
> +	if (seq_mask)
>  		len += sizeof(struct ip_vs_sync_conn_options) + 2;
>  
>  	if (cp->pe_data_len)
> @@ -744,7 +746,7 @@ void ip_vs_sync_conn(struct netns_ipvs *ipvs, struct ip_vs_conn *cp, int pkts)
>  		s->v4.vaddr = cp->vaddr.ip;
>  		s->v4.daddr = cp->daddr.ip;
>  	}
> -	if (cp->flags & IP_VS_CONN_F_SEQ_MASK) {
> +	if (seq_mask) {
>  		*(p++) = IPVS_OPT_SEQ_DATA;
>  		*(p++) = sizeof(struct ip_vs_sync_conn_options);
>  		hton_seq(&cp->in_seq, (struct ip_vs_seq *)p);
> -- 
> 2.55.0

Regards

--
Julian Anastasov <ja@ssi.bg>

