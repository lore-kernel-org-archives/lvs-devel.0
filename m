From: Julian Anastasov <ja@ssi.bg>
Subject: =?UTF-8?Q?Re=3A_=5BPATCH_0=2F3=5D_netfilter=3A_ipvs=3A=C2=A0Add_Maglev_consistent_hashing_scheduler?=
Date: Mon, 18 Dec 2017 10:37:48 +0200 (EET)
Message-ID: <alpine.LFD.2.20.1712181029590.2207@ja.home.ssi.bg>
References: <cover.1512888407.git.inju.song@navercorp.com> <alpine.LFD.2.20.1712101547210.4343@ja.home.ssi.bg> <20171217084000.GA9802@centos7.nhncorp.com> <alpine.LFD.2.20.1712171312360.30653@ja.home.ssi.bg> <20171218050934.GA5113@centos7.nhncorp.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20171218050934.GA5113@centos7.nhncorp.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Inju Song <inju.song@navercorp.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Mon, 18 Dec 2017, Inju Song wrote:

> > 	Yep, then we should catch .upd_dest and to use last_weight.
> > In fact, adding last_weight to IPVS core should be separate
> > patch to apply before the MH patch.
> > 
> 
> 	Ok. So should I send patch about adding last_weight to IPVS core
> before appling the MH patch? Then I will.

	Yes, keep both patches in same patchset, patch 1 for
last_weight and patch 2 for MH. You should send them by
changing version until all issues are resolved. As result,
it would be easier for Simon to apply them.

> > 	locks are not needed, configuration is serialzed by
> > using __ip_vs_mutex, the configuration methods run concurrently
> > only with packet processing and we use RCU for the table.
> > 
> 
> 	Ok. then I will use RCU for the mh_setup table. 

	Nothing different from what was used in last MH version and
what is in SH (ip_vs_sh_reassign): changing table entries
with RCU primitives.

Regards

--
Julian Anastasov <ja@ssi.bg>
