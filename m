Received: from mg.ssi.bg (mg.ssi.bg [193.238.174.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE0A67F492;
	Wed,  7 Feb 2024 16:50:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707324617; cv=none; b=ngXbdTwUOr5qQQrD5AN8J1WNaH1aoUKuOxBH3i9TqtbDMG0tSOlmGjVFPkzsjnveeHvVgdTh1BwizYHWRvWRsGLnFAQggw7YQOc/JqQHMyKladJraOWpqF3ViGXjgqVmU0EiGexEpFqNl8442RY4pCRXndVwEpf2GNcOJst7gsI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707324617; c=relaxed/simple;
	bh=OFVP8pF7G0eP/zz4gskd3eFJyGQRgHMQFKJwru0hMPU=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=iF1VykzXunaIQPP4I6o74W54NtFLBtiaT7hnlRUE/fTpKgzPq+wJ/+haMguz+H4crqfXCLQFtDNAasLoDGMlVVz2pA/zfncWIdLQCpcLTqdIE2UOM7x6RDCNBwKFls5fKIkeNkmNepKZR7qF0WPtQlCp5dRyuaTeXQaUYntJs04=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=BUrYHaXJ; arc=none smtp.client-ip=193.238.174.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="BUrYHaXJ"
Received: from mg.bb.i.ssi.bg (localhost [127.0.0.1])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTP id C4AE121BB1;
	Wed,  7 Feb 2024 18:45:00 +0200 (EET)
Received: from ink.ssi.bg (ink.ssi.bg [193.238.174.40])
	by mg.bb.i.ssi.bg (Proxmox) with ESMTPS id AD02221BAD;
	Wed,  7 Feb 2024 18:45:00 +0200 (EET)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by ink.ssi.bg (Postfix) with ESMTPSA id 1BA623C07CD;
	Wed,  7 Feb 2024 18:44:58 +0200 (EET)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
	t=1707324298; bh=OFVP8pF7G0eP/zz4gskd3eFJyGQRgHMQFKJwru0hMPU=;
	h=Date:From:To:cc:Subject:In-Reply-To:References;
	b=BUrYHaXJmhZVsWK0e/03CQXzsjtpiNxhpJnNNUJLgrdDreTIx3s0c8a16cda2lXqY
	 nUKdQHU+dZVOkfcFBpYHM50xdJx06MMgionraCx2tct0Cv/i8lDgK0igYo4gaWTDLh
	 +HcrsuyYaMssDWIk0oA52E5OL0tMzCYoJe2jwR7o=
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.17.1/8.17.1) with ESMTP id 417Gimco077712;
	Wed, 7 Feb 2024 18:44:49 +0200
Date: Wed, 7 Feb 2024 18:44:48 +0200 (EET)
From: Julian Anastasov <ja@ssi.bg>
To: Terin Stock <terin@cloudflare.com>
cc: horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org,
        fw@strlen.de, netfilter-devel@vger.kernel.org,
        lvs-devel@vger.kernel.org, kernel-team@cloudflare.com
Subject: Re: [PATCH] ipvs: generic netlink multicast event group
In-Reply-To: <20240205192828.187494-1-terin@cloudflare.com>
Message-ID: <51c680c7-660a-329f-8c55-31b91c8357fd@ssi.bg>
References: <20240205192828.187494-1-terin@cloudflare.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 5 Feb 2024, Terin Stock wrote:

> The IPVS subsystem allows for configuration from userspace programs
> using the generic netlink interface. However, the program is currently
> unable to react to changes in the configuration of services or
> destinations made on the system without polling over all configuration
> in IPVS.
> 
> Adds an "events" multicast group for the IPVS generic netlink family,
> allowing for userspace programs to monitor changes made by any other
> netlink client (or legacy tools using the IPVS socket options). As
> service and destination statistics are separate from configuration,
> those netlink attributes are excluded in events.
> 
> Signed-off-by: Terin Stock <terin@cloudflare.com>
> ---
>  include/uapi/linux/ip_vs.h     |   2 +
>  net/netfilter/ipvs/ip_vs_ctl.c | 107 +++++++++++++++++++++++++++++----
>  2 files changed, 96 insertions(+), 13 deletions(-)
> 
> diff --git a/include/uapi/linux/ip_vs.h b/include/uapi/linux/ip_vs.h
> index 1ed234e7f251..0aa119ebaf85 100644
> --- a/include/uapi/linux/ip_vs.h
> +++ b/include/uapi/linux/ip_vs.h
> @@ -299,6 +299,8 @@ struct ip_vs_daemon_user {
>  #define IPVS_GENL_NAME		"IPVS"
>  #define IPVS_GENL_VERSION	0x1
>  
> +#define IPVS_GENL_MCAST_EVENT_NAME "events"
> +
>  struct ip_vs_flags {
>  	__u32 flags;
>  	__u32 mask;
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 143a341bbc0a..ced232361d02 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -64,6 +64,11 @@ int ip_vs_get_debug_level(void)
>  
>  
>  /*  Protos */
> +static struct genl_family ip_vs_genl_family;
> +static int ip_vs_genl_fill_service(struct sk_buff *skb,
> +				   struct ip_vs_service *svc, bool stats);
> +static int ip_vs_genl_fill_dest(struct sk_buff *skb, struct ip_vs_dest *dest,
> +				bool stats);
>  static void __ip_vs_del_service(struct ip_vs_service *svc, bool cleanup);
>  
>  
> @@ -960,6 +965,62 @@ void ip_vs_stats_free(struct ip_vs_stats *stats)
>  	}
>  }
>  
> +static int ip_vs_genl_service_event(u8 event, struct ip_vs_service *svc)
> +{
> +	struct sk_buff *msg;
> +	void *hdr;
> +
> +	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
> +	if (!msg)
> +		return -ENOMEM;
> +
> +	hdr = genlmsg_put(msg, 0, 0, &ip_vs_genl_family, 0, event);
> +	if (!hdr)
> +		goto free_msg;
> +
> +	if (ip_vs_genl_fill_service(msg, svc, false))
> +		goto free_msg;
> +
> +	genlmsg_end(msg, hdr);
> +	genlmsg_multicast(&ip_vs_genl_family, msg, 0, 0, GFP_ATOMIC);

	May be genlmsg_multicast_netns because the rules are per netns?
As result, may be on net cleanup such events should not be generated,
see 'bool cleanup'.

	And to use GFP_KERNEL because all configuration happens in process
context? On module removal, ip_vs_unregister_nl_ioctl() is called before 
the rules are flushed, not sure if we should add some check or it is not
fatal to post events for unregistered genl family?

	Also, IP_VS_SO_SET_FLUSH can flush rules and now it will not be 
reported.

	I also worry that such events slowdown the configuration
process for setups with many rules which do not use listeners.
Should we enable it with some sysctl var? Currently, many CPU cycles are 
spent before we notice that there are no listeners.

Regards

--
Julian Anastasov <ja@ssi.bg>

