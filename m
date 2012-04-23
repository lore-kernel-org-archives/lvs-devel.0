From: Simon Horman <horms@verge.net.au>
Subject: Re: kernel oops - do_ip_vs_get_ctl
Date: Mon, 23 Apr 2012 22:32:43 +0900
Message-ID: <20120423133243.GC13990@verge.net.au>
References: <856i5i0.baad648bc0bbda1d9e290168a4213443@obelix.schillstrom.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <856i5i0.baad648bc0bbda1d9e290168a4213443@obelix.schillstrom.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Julian Anastasov <ja@ssi.bg>, Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

On Sat, Apr 21, 2012 at 12:11:49PM +0200, Hans Schillstrom wrote:
> Hello 
> >Subject: Re[2]: kernel oops - do_ip_vs_get_ctl
> >
> >Hello,
> >
> >On Fri, 20 Apr 2012, Hans Schillstrom wrote:
> >
> >> >On Fri, 20 Apr 2012, Ryan O'Hara wrote:
> >> >
> >> >> 
> >> >> I frequently get a kernel oops in do_ip_vs_get_ctl when starting keepalived on
> >> >> a 3.3.0 kernel. I'm attaching the trace from /var/log/messages. Has anyone
> >> >> encountered this problem and if so is there a patch available? Much
> >> >> appreciated.
> >> >
> [snip]
> 
> >> Do you prepare a patch or should I do it  ?
> >
> >	I'm stopping doing more patches until Simon takes
> >the previous changes, so that we can use some fresh tree.
> >You can try fixing this problem if you think you have
> >recent changes.
> >
> OK I'll take care of this and double check with Simon that we have the
> same view of patches

Hi,

sorry for not being a little more attentive to patches.

I have now picked up all the patches that seem to have consensus.
Those that seem critical I have pushed into ipvs with a CC: stable@
and sent a pull request to Pablo to consider them for 3.4.

There are two such patches and the head of the ipvs tree now looks like
this:

0cc4789 ipvs: fix crash in ip_vs_control_net_cleanup on unload
bd7dc1c netfilter: ipvs: Verify that IP_VS protocol has been registered

Those that seemed less critical where the GFP_ATOMIC changes, one
from Sasha and 6 from Julian. The head of the ipvs-next tree now looks like
this:

663f4b2 netfilter: ipvs: use GFP_KERNEL allocation where possible
b5cfd04 ipvs: SH scheduler does not need GFP_ATOMIC allocation
5b3b290 ipvs: LBLCR scheduler does not need GFP_ATOMIC allocation on init
c087c6f ipvs: WRR scheduler does not need GFP_ATOMIC allocation
8cfaf8d ipvs: DH scheduler does not need GFP_ATOMIC allocation
e7c6390 ipvs: LBLC scheduler does not need GFP_ATOMIC allocation on init
8f78609 ipvs: timeout tables do not need GFP_ATOMIC allocation

Please let me know if there are any other patches you would like
merged at this time.
