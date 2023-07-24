From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v2 net-next] ipvs: make ip_vs_svc_table and ip_vs_svc_fwm_table
 per netns
Date: Mon, 24 Jul 2023 06:46:22 +0300 (EEST)
Message-ID: <3decf8be-ee64-b3c3-2e6d-4f3f392f6faf@ssi.bg>
References: <20230723154426.81242-1-dust.li@linux.alibaba.com> <ff4612e3-bb5a-7acc-1607-5761e5d052c4@ssi.bg> <20230724013101.GI6751@linux.alibaba.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1690170387; bh=9wDE65OlhnCUzRgqjw2Uyz//+EJm/dZ/6yNBMKhGs7c=;
        h=Date:From:To:cc:Subject:In-Reply-To:References;
        b=jZbF6lDEEGLK8dDaKiIjrEHyeSVKDWp0FjPwuug8PY2u0ahlIGq1qgH3f1FdN83Sg
         UdClFXYbzxTKTv/HapNN3Wd0XNN5KIv7eHIJgscm/UZa0jazrcujDL3sV3ZwCXECD1
         EEjtsN/Op9XdAjbz5de2deCqlPg5F47twdiRDJ4Y=
In-Reply-To: <20230724013101.GI6751@linux.alibaba.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dust Li <dust.li@linux.alibaba.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, Jiejian Wu <jiejian@linux.alibaba.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org


	Hello,

On Mon, 24 Jul 2023, Dust Li wrote:

> On Sun, Jul 23, 2023 at 08:19:54PM +0300, Julian Anastasov wrote:
> >
> >	Changes look good to me, thanks! But checkpatch is reporting
> >for some cosmetic changes that you have to do in v3:
> >
> >scripts/checkpatch.pl --strict /tmp/file.patch
> 
> Oh, sorry for that! I ignored the CHECKs checkpatch reported, my checkpatch
> shows:
> 
> 
>    $./scripts/checkpatch.pl --strict 0001-ipvs-make-ip_vs_svc_table-and-ip_vs_svc_fwm_table-pe.patch
>    CHECK: Prefer using the BIT macro
>    #69: FILE: include/net/ip_vs.h:40:
>    +#define IP_VS_SVC_TAB_SIZE (1 << IP_VS_SVC_TAB_BITS)
> 
> We just moved this line from ip_vs_ctl.c to ip_vs.h, so we ignored the
> BIT macro. Do you think we should change it using BIT macro ?

	Yes, lets fix all these complains.

>    CHECK: struct mutex definition without comment
>    #79: FILE: include/net/ip_vs.h:1051:
>    +       struct mutex service_mutex;
> 
> I think we can add comment for it.
> But rethinking a bit on the service_mutex in ip_vs_est.c, I'm a
> wondering why we are using the service_mutex in estimation ? Is est_mutex
> enough for the protecting in ip_vs_est.c ?

	Yes, the estimation kthreads are synchronized only
with reconfiguration: ip_vs_start_estimator() and ip_vs_stop_estimator()
are called under service_mutex. And the estimation data is already 
per-net, there is no global data.

>    CHECK: Logical continuations should be on the previous line
>    #161: FILE: net/netfilter/ipvs/ip_vs_ctl.c:410:
>                        && (svc->port == vport)
>    +                   && (svc->protocol == protocol)) {
> 
> This is just the removal of '(svc->ipvs == ipvs)' and kept it as it is.
> So haven't change according to checkpatch. If you prefer, I can modify
> it to make checkpatch happy.

	Yes, lets move all '&&' in this 'if' block and also remove the 
parens:

	if (svc->af == af && ip_vs_addr_equal(af, &svc->addr, vaddr) &&
	    svc->port == vport && svc->protocol == protocol) {

Regards

--
Julian Anastasov <ja@ssi.bg>

