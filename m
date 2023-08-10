From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Race over table->data in proc_do_sync_threshold()
Date: Thu, 10 Aug 2023 09:20:28 +0300 (EEST)
Message-ID: <b4854287-cb97-27fb-053f-e52179c05e97@ssi.bg>
References: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1691648437; bh=bYsAcXe+msxmctZkaQSDLKwGaykqzb1Fk6NOmEwpcAM=;
        h=Date:From:To:cc:Subject:In-Reply-To:References;
        b=cY8M+DWNgIfcrPfCAot1zf5bu/6LmAGxy9zkrhyKtb5IWnwWIHvK9+0bOQfRb3Hy2
         lJ1KzoLnWuf9Vvv6l2+dHrfJr6AO8Id42qh9BrXfs9hN7zukpuq/MkvlRew1+j7SX4
         6MkKOn2FKyRQEmD+XX24qPx9ZpslKX+0ixcjvENU=
In-Reply-To: <B6988E90-0A1E-4B85-BF26-2DAF6D482433@gmail.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sishuai Gong <sishuai.system@gmail.com>
Cc: horms@verge.net.au, Linux Kernel Network Developers <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org


	Hello,

On Wed, 9 Aug 2023, Sishuai Gong wrote:

> Hi,
> 
> We observed races over (struct ctl_table *) table->data when two threads
> are running proc_do_sync_threshold() in parallel, as shown below:
> 
> Thread-1			Thread-2
> memcpy(val, valp, sizeof(val)); memcpy(valp, val, sizeof(val));
> 
> This race probably would mess up table->data. Is it better to add a lock?

	We can put mutex_lock(&ipvs->sync_mutex) before the first
memcpy and to use two WRITE_ONCE instead of the second memcpy. But
this requires extra2 = ipvs in ip_vs_control_net_init_sysctl():

	tbl[idx].data = &ipvs->sysctl_sync_threshold;
+	tbl[idx].extra2 = ipvs;

	Will you provide patch?

Regards

--
Julian Anastasov <ja@ssi.bg>

