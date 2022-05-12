From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] net: ipvs: random start for RR scheduler
Date: Fri, 13 May 2022 01:23:52 +0300 (EEST)
Message-ID: <7e7b6a1-8d52-7274-e4b4-9b8ce3ddc4f9@ssi.bg>
References: <20220509122213.19508-1-imagedong@tencent.com> <cb8eaad0-83c5-a150-d830-e078682ba18b@ssi.bg> <CADxym3YH_76+5g29QF4Xp4gXJz5bwdQXD_gXv3esAVTgNGkXyg@mail.gmail.com> <b8bf73ea-2ce9-2726-fde1-bd47d3b7a5d@ssi.bg>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b8bf73ea-2ce9-2726-fde1-bd47d3b7a5d@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Menglong Dong <menglong8.dong@gmail.com>
Cc: Simon Horman <horms@verge.net.au>, Pablo Neira Ayuso <pablo@netfilter.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, Menglong Dong <imagedong@tencent.com>


	Hello,

On Tue, 10 May 2022, Julian Anastasov wrote:

> 	What I see is that the value 128 is good but using
> 32 (MAX_STEP in the test) gives good enough results (3% diff).

	Looks like I forgot to add this example how to
reduce code under lock because add/del dest can run in
parallel with scheduling, something that is a drawback
in this solution:

+static void ip_vs_rr_random_start(struct ip_vs_service *svc)
+{
+	struct list_head *old = READ_ONCE(svc->sched_data), *cur = old;
+	u32 start;
+
+	if (!(svc->flags & IP_VS_SVC_F_SCHED_RR_RANDOM) ||
+		svc->num_dests <= 1)   
+		return;
+
+	start = prandom_u32_max(min(svc->num_dests, 32U));
+	while (start--)
+		cur = cur->next;
+	spin_lock_bh(&svc->sched_lock);
+	cmpxchg(&svc->sched_data, old, cur);
+	spin_unlock_bh(&svc->sched_lock);
+}

Regards

--
Julian Anastasov <ja@ssi.bg>

