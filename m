From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH nf-next v3 0/4] ipvs: Cleanups for v6.4
Date: Sat, 22 Apr 2023 13:14:13 +0300 (EEST)
Message-ID: <deeef4d5-208b-2d48-4714-5be1b9bc4393@ssi.bg>
References: <20230409-ipvs-cleanup-v3-0-5149ea34b0b9@kernel.org> <a873ffc-bcdf-934f-127a-80188e8b33e6@ssi.bg> <ZEMYjOlXKd+6zsgw@calendula>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <ZEMYjOlXKd+6zsgw@calendula>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Simon Horman <horms@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, netfilter-devel@vger.kernel.org, Horatiu Vultur <horatiu.vultur@microchip.com>


	Hello,

On Sat, 22 Apr 2023, Pablo Neira Ayuso wrote:

> On Mon, Apr 17, 2023 at 07:59:35PM +0300, Julian Anastasov wrote:
> > 
> > On Mon, 17 Apr 2023, Simon Horman wrote:
> > 
> > > this series aims to clean up IPVS in several ways without
> > > implementing any functional changes, aside from removing
> > > some debugging output.
> > > 
> > > Patch 1/4: Update width of source for ip_vs_sync_conn_options
> > >            The operation is safe, use an annotation to describe it properly.
> > > 
> > > Patch 2/4: Consistently use array_size() in ip_vs_conn_init()
> > >            It seems better to use helpers consistently.
> > > 
> > > Patch 3/4: Remove {Enter,Leave}Function
> > >            These seem to be well past their use-by date.
> > > 
> > > Patch 4/4: Correct spelling in comments
> > > 	   I can't spell. But codespell helps me these days.
> > > 
> > > All changes: compile tested only!
> > > 
> > > ---
> > > Changes in v3:
> > > - Patch 2/4: Correct division by 1024.
> > >              It was applied to the wrong variable in v2.
> > > - Add Horatiu's Reviewed-by tag.
> > > 
> > > Changes in v2:
> > > - Patch 1/4: Correct spelling of 'conn' in subject.
> > > - Patch 2/4: Restore division by 1024. It was lost on v1.
> > > 
> > > ---
> > > Simon Horman (4):
> > >       ipvs: Update width of source for ip_vs_sync_conn_options
> > >       ipvs: Consistently use array_size() in ip_vs_conn_init()
> > >       ipvs: Remove {Enter,Leave}Function
> > >       ipvs: Correct spelling in comments
> > 
> > 	The patchset looks good to me, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> Applied, sorry Julian, I missed your Acked-by: tag.

	No problem :)

Regards

--
Julian Anastasov <ja@ssi.bg>

