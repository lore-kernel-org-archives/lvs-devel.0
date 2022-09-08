From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv2 2/4] ipvs: use kthreads for stats estimation
Date: Fri, 9 Sep 2022 01:46:45 +0300 (EEST)
Message-ID: <89135c6a-eb8c-b3c5-2599-306db1f0fb25@ssi.bg>
References: <20220908222109.147452-1-ja@ssi.bg> <20220908222109.147452-3-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20220908222109.147452-3-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Fri, 9 Sep 2022, Julian Anastasov wrote:

> +add_est:
> +	ktid = kd->id;
> +	/* add_row points after the row we should use */
> +	crow = READ_ONCE(kd->add_row) - 1;
> +	if (crow < 0)
> +		crow = IPVS_EST_NTICKS - 1;
> +	row = crow;
> +	if (crow) {

	OK, not fatal but this should be

	if (crow < IPVS_EST_NTICKS - 1) {

> +		crow++;
> +		row = find_last_bit(kd->avail, crow);
> +	}
> +	if (row >= crow)
> +		row = find_last_bit(kd->avail, IPVS_EST_NTICKS);
> +

Regards

--
Julian Anastasov <ja@ssi.bg>

