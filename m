From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv6 3/7] ipvs: use u64_stats_t for the per-cpu
 counters
Date: Mon, 14 Nov 2022 13:46:06 +0200 (EET)
Message-ID: <96408766-f9d1-f16d-f186-73811b7ce499@ssi.bg>
References: <20221031145647.156930-1-ja@ssi.bg> <20221031145647.156930-4-ja@ssi.bg> <20221112090001.GH3484@incl> <20221112090910.GI3484@incl> <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <a7bf3435-aa8f-31a5-b93b-f0ad58fdc3a4@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Sat, 12 Nov 2022, Julian Anastasov wrote:

> +			for (;;) {
> +				start += u64_stats_fetch_begin(&c->syncp);

	Hm, this should be assignment and not addition...
Not a problem for 64-bit tests.

> +				kconns += u64_stats_read(&c->cnt.conns);
> +				kinpkts += u64_stats_read(&c->cnt.inpkts);
> +				koutpkts += u64_stats_read(&c->cnt.outpkts);
> +				kinbytes += u64_stats_read(&c->cnt.inbytes);
> +				koutbytes += u64_stats_read(&c->cnt.outbytes);
> +				if (!u64_stats_fetch_retry(&c->syncp, start))
> +					break;
> +#if BITS_PER_LONG == 32
> +				kconns = conns;
> +				kinpkts = inpkts;
> +				koutpkts = outpkts;
> +				kinbytes = inbytes;
> +				koutbytes = outbytes;
> +#endif

Regards

--
Julian Anastasov <ja@ssi.bg>

