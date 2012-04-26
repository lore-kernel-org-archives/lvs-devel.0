From: Simon Horman <horms@verge.net.au>
Subject: Re: kernel oops - do_ip_vs_get_ctl
Date: Thu, 26 Apr 2012 15:31:07 +0900
Message-ID: <20120426063105.GH13141@verge.net.au>
References: <856i5i0.baad648bc0bbda1d9e290168a4213443@obelix.schillstrom.com>
 <20120423133243.GC13990@verge.net.au>
 <alpine.LFD.2.00.1204232245150.1890@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1204232245150.1890@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Hans Schillstrom <hans@schillstrom.com>, Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

On Mon, Apr 23, 2012 at 10:55:30PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 23 Apr 2012, Simon Horman wrote:
> 
> > Hi,
> > 
> > sorry for not being a little more attentive to patches.
> > 
> > I have now picked up all the patches that seem to have consensus.
> > Those that seem critical I have pushed into ipvs with a CC: stable@
> > and sent a pull request to Pablo to consider them for 3.4.
> > 
> > There are two such patches and the head of the ipvs tree now looks like
> > this:
> > 
> > 0cc4789 ipvs: fix crash in ip_vs_control_net_cleanup on unload
> > bd7dc1c netfilter: ipvs: Verify that IP_VS protocol has been registered
> > 
> > Those that seemed less critical where the GFP_ATOMIC changes, one
> > from Sasha and 6 from Julian. The head of the ipvs-next tree now looks like
> > this:
> > 
> > 663f4b2 netfilter: ipvs: use GFP_KERNEL allocation where possible
> > b5cfd04 ipvs: SH scheduler does not need GFP_ATOMIC allocation
> > 5b3b290 ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
> > c087c6f ipvs: WRR scheduler does not need GFP_ATOMIC allocation
> > 8cfaf8d ipvs: DH scheduler does not need GFP_ATOMIC allocation
> > e7c6390 ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
> > 8f78609 ipvs: timeout tables do not need GFP_ATOMIC allocation
> > 
> > Please let me know if there are any other patches you would like
> > merged at this time.
> 
> 	These two patches are also fixes but may be the 2nd
> patch is too long for fix:
> 
> ipvs: reset ipvs pointer in netns
> ipvs: fix app registration in netns

Thanks, I have these now.

> 	If it looks too long for fix we can push some
> simple check for net->ipvs in __ip_vs_ftp_init, so that
> we do not oops when IPVS core is compiled in kernel.
> Even if smaller version is sent to stable kernels,
> I prefer "ipvs: fix app registration in netns" to be
> applied at least for net-next. May be I should split
> this 2nd patch as two-line fix + additional change
> for net-next?
> 
> 	Hans should provide similar two-line fixes for
> LBLC and LBLCR. And one for latest crash report.

And I am awaiting consensus on the following fixes from Hans.

ipvs: null check of net->ipvs in lblc(r) shedulers
ipvs: take care of return value from protocol init_netns
ipvs: kernel oops - do_ip_vs_get_ctl
