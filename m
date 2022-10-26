From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCHv5 3/6] ipvs: use kthreads for stats estimation
Date: Wed, 26 Oct 2022 18:29:39 +0300 (EEST)
Message-ID: <bc1d5e15-9c1f-4f4a-152f-2e49e472963@ssi.bg>
References: <20221009153710.125919-1-ja@ssi.bg> <20221009153710.125919-4-ja@ssi.bg> <20221015092158.GA3484@incl> <64d2975-357d-75f7-1d34-c43a1b3fc72a@ssi.bg> <20221022181513.GB3484@incl> <b279182b-58ee-1c76-e194-31539d95982@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <b279182b-58ee-1c76-e194-31539d95982@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Wiesner <jwiesner@suse.de>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com


	Hello,

On Mon, 24 Oct 2022, Julian Anastasov wrote:

> 	While finishing this posting, I'm investigating
> the idea to use structures without chains (no relinking),
> without chain_len, tick_len, etc. But let me first see
> if such idea can work...

	Hm, I tried some ideas but result is not good at all.
chain_max looks like a good implicit way to apply cond_resched
rate and to return to some safe position on return. Other methods
with arrays will (1) allocate more memory or (2) slowdown searching
for free slot while adding or (3) slowdown while walking during
estimation. Now we benefit from long chains (33/38 as in your
setup) to (1) use less memory to store ests in chains and (2) to
reduce the cost from for_each_set_bit() operation.

	So, for now I don't have any better idea to change
the data structures.

	After your feedback I can prepare next version by adding
wait_event_idle_timeout() calls as pause between tests.

Regards

--
Julian Anastasov <ja@ssi.bg>

