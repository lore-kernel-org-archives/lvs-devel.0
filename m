Received: from mx.ssi.bg (mx.ssi.bg [193.238.174.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 521E320102C;
	Tue,  9 Sep 2025 15:15:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=193.238.174.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757430927; cv=none; b=nEdHLqW3foYtKgUHMrT0Wg56L/lizFM6EENAO/2dKmO5280SRpdJG8p0nIm9+8zxsIeMoT2GQS1xFiTAJcPurMjvC73quu5CziPxI1z78zLf+517L9CpMMJ1Svu/IyHDwVXaDQr1PKx2G7ondMa/qh/aRUlCReKpbZ1Pv1O3+VI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757430927; c=relaxed/simple;
	bh=2anOpUEB8ZrluT6ZWpZLfBR8vUKUSxK7hCmigQanedM=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=jJdvIhbW9mgMroohiYvBYWz0rm87GQLMc6WsJudtDDMiACZK2t6Rg1BnPdFXZhDanjXDAQtesOJlks8U8t82f4QZP+JHRsx8roOL6lcBrLM1vBBVpzyslCohW6R7qRZoGDt0qW9PWSFWqUdMHFrXlbOjpTF9Hjpx5jJDsCcINSU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg; spf=pass smtp.mailfrom=ssi.bg; dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b=lSFK0nHr; arc=none smtp.client-ip=193.238.174.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=ssi.bg
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ssi.bg
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (4096-bit key) header.d=ssi.bg header.i=@ssi.bg header.b="lSFK0nHr"
Received: from mx.ssi.bg (localhost [127.0.0.1])
	by mx.ssi.bg (Potsfix) with ESMTP id 27CC920545;
	Tue,  9 Sep 2025 18:15:14 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ssi.bg; h=cc:cc
	:content-type:content-type:date:from:from:in-reply-to:message-id
	:mime-version:references:reply-to:subject:subject:to:to; s=ssi;
	 bh=DuUlhG3uOqtSZMpp6pl4y3fP1ka9SPbGB7gebbWP824=; b=lSFK0nHrsuCA
	ejR2F/HmmWM2++InmsQweYuQfmsC5IZHceyuUfHbFklT7GOsSN9uQvrocJPjNaqz
	v/4G3vVdTXuTwJSUJDYJX3w4wmZ1z3usgn2D7/ZkXz2IfD/ErHlwNSPbc80Fx1MT
	7IWfqlQwTN5Ng5dZT7SmgbCl/5fILkmp6OHTtD/3oOTmg63INA4Bkq8RZKhNtBfj
	dcvvUtswQPXpDJy4xWcGZM56gbh3RvtYL/jyDiz41bQEtxSZSPHps4mjEn0EMP4q
	+gya1ZyEJUpi4omZb8pjW8Ig8DNftsRGtqT2uWsdb8bOkeOvlZIsA2vdVxvjEQtq
	THDQsTK8C5Ycj65nkMjed6NQYHISPBsl0srCH0MfEw9t46ts4tV9g5fABRHmgcqH
	GjwbgomrUTw8cENwL5t8DO/6vjtChSZzfT4nl3ziTnzOhygcj6S+7Tx0X4p5/8es
	qP+fMihwKvPMYbud3kVmIMUV4bYNAeRKnG4NK2mYMZURpDkO/pco4Xe+7v8AjAa3
	0rtDGvkVJWfGLhQxfZ1d9yMsRwvzxflKqzHeZ/xmpqupAk3J61Ie/INIiVmLWAbM
	Rx1hZd6KlXsSWaAFl5g5mBQvWMTKMPlaxEyUVHIABrEsvV5WRHs/SyIVEhgDCWdj
	cDit2fXowT4PeVJbQH6gPIuXWwme13U=
Received: from box.ssi.bg (box.ssi.bg [193.238.174.46])
	by mx.ssi.bg (Potsfix) with ESMTPS;
	Tue,  9 Sep 2025 18:15:12 +0300 (EEST)
Received: from ja.ssi.bg (unknown [213.16.62.126])
	by box.ssi.bg (Potsfix) with ESMTPSA id 184A464D0A;
	Tue,  9 Sep 2025 18:15:09 +0300 (EEST)
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.18.1/8.18.1) with ESMTP id 589FF4bN041717;
	Tue, 9 Sep 2025 18:15:04 +0300
Date: Tue, 9 Sep 2025 18:15:04 +0300 (EEST)
From: Julian Anastasov <ja@ssi.bg>
To: Slavin Liu <slavin452@gmail.com>
cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/1] IPVS: Fix use-after-free issue in
 ip_vs_unbind_app()
In-Reply-To: <20250908065458.536-1-slavin452@gmail.com>
Message-ID: <b5d51ae8-df71-713f-3f08-14cf6272f52a@ssi.bg>
References: <20250908065458.536-1-slavin452@gmail.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII


	Hello,

On Mon, 8 Sep 2025, Slavin Liu wrote:

> When exiting a network namespace, in cleanup_net()->ops_undo_list(),
> ip_vs_ftp_ops->exit() is called before ip_vs_core_ops->exit_batch().
> The ip_vs_app ip_vs_ftp and its incarnations will be freed by unregister_ip_vs_app().
> However, there could still be connections bound to ip_vs_ftp's incarnation.
> cp->app points to the free'd incarnation, which will be accessed later by
> __ip_vs_cleanup_batch()->ip_vs_conn_net_cleanup()->ip_vs_conn_flush()->ip_vs_conn_del()->
> ip_vs_conn_expire()->ip_vs_unbind_app(), causing a uaf. This vulnarability can
> lead to a local privilege escalation.
> 
> Reproduction steps:
> 1. create a ipvs service on (127.0.0.1:21)
> 2. create a ipvs destination on the service, to (127.0.0.1:<any>)
> 3. send a tcp packet to (127.0.0.1:21)
> 4. exit the network namespace
> 
> I think the fix should flush all connection to ftp before unregistration.
> The simpler fix is to delete ip_vs_ftp_ops->exit, and defer the unregistration
> of ip_vs_ftp to ip_vs_app_net_cleanup(), which will unregister all ip_vs_app.
> It's after ip_vs_conn_net_cleanup() so there is no uaf issue. This patch
> seems to solve the issue but has't been fully tested yet, and is also not graceful.
> 
> Signed-off-by: Slavin Liu <slavin452@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ftp.c | 13 -------------
>  1 file changed, 13 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index d8a284999544..68def1106681 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -598,22 +598,9 @@ static int __net_init __ip_vs_ftp_init(struct net *net)
>  	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
>  	return ret;
>  }
> -/*
> - *	netns exit
> - */
> -static void __ip_vs_ftp_exit(struct net *net)
> -{
> -	struct netns_ipvs *ipvs = net_ipvs(net);
> -
> -	if (!ipvs)

	What if we change this 'if' check to:

	if (!ipvs || !ipvs->enable)

	If netns exits, the cleanup order is:

1. exit handlers for pernet device (&ipvs_core_dev_ops) where
	ipvs->enable is set to 0

2. exit handlers for ip_vs_ftp_ops (as last pernet subsys)
	By checking for ipvs->enable, we should not call
	unregister_ip_vs_app() in __ip_vs_ftp_exit() because
	there can be existing conns with valid cp->app

3. exit handlers for pernet subsys (&ipvs_core_ops) where
	ip_vs_app_net_cleanup() unregisters all apps for netns.
	Here the apps will be freed after all conns are gone

	Why we should keep the ftp pernet subsys: because when
there are no conns using the app, the module can be removed and
it must unregister its app from all netns where ipvs->enable will
be 1.

	But note that we have a pending patch that changes
the access to ipvs->enable to use READ_ONCE/WRITE_ONCE:

https://archive.linuxvirtualserver.org/html/lvs-devel/2025-09/msg00000.html

> -		return;
> -
> -	unregister_ip_vs_app(ipvs, &ip_vs_ftp);
> -}
>  
>  static struct pernet_operations ip_vs_ftp_ops = {
>  	.init = __ip_vs_ftp_init,
> -	.exit = __ip_vs_ftp_exit,
>  };
>  
>  static int __init ip_vs_ftp_init(void)
> -- 
> 2.34.1

Regards

--
Julian Anastasov <ja@ssi.bg>

