From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH next 00/84] ipvs: Stop guessing the network namespace
 (take 2)
Date: Tue, 22 Sep 2015 10:22:13 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509221019170.3008@ja.home.ssi.bg>
References: <87mvwn18my.fsf@x220.int.ebiederm.org> <87pp1fpy1b.fsf@x220.int.ebiederm.org> <87fv2bo7br.fsf_-_@x220.int.ebiederm.org> <87h9mplifu.fsf_-_@x220.int.ebiederm.org> <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8737y7irc8.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, David Miller <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>, lvs-devel@vger.kernel.org


	Hello,

On Mon, 21 Sep 2015, Eric W. Biederman wrote:

> I am gradually working my way through the netfilter stack passing struct
> down into the netfilter hooks and from the netfilter hooks and from
> there down into the functions that actually care.  This removes the need
> for netfilter functions to guess how to figure out how to compute which
> network namespace they are in and instead provides a simple and reliable
> method to do so.
> 
> The cleanups stand on their own but this is part of a larger effort to
> have routes with an output device that is not in the current network
> namespace.
> 
> The IPVS code has been a bit more of a challenge than most.  Just
> passing struct net through to where it is needed did not feel clean to
> me.  The practical issue is that the ipvs code in most places actually
> wants struct netns_ipvs and not struct net.
> 
> So as part of this process I have turned the relationship between struct
> net and the structs netns_ipvs, ip_vs_conn_param, ip_vs_conn, and
> ip_vs_service inside out.  I have modified the ipvs functions to take a
> struct netns_ipvs not a struct net.  The net is code with fewer
> conversions from one type of structure to another.  I did wind up adding
> a struct netns_ipvs parameter to quite a few functions that did not have
> it before so I could pass the structure down from the netfilter hooks to
> where it is actually needed to avoid guessing.
> 
> I have broken up the work in a bunch of small patches so there is at
> least a chance and reviewing that each step I took is correct.  The
> series compiles at each step so bisecting it should not be a problem
> if something weird comes up.
> 
> The first two changes in this series are actually bug fixes.  The first
> is a compile fix for a bug in sctp that came in, in the last round of
> ipvs changes merged into nf-next.  The second fixes an older bug where
> in pathological circumstances the wrong network namespace could be used
> when a proc file is written to.
> 
> The rest of the patchset is a bunch of boring changes getting pushing
> struct netns_ipvs (and by extension ipvs->net) where it needs to be.
> Either by replacing struct net pointers or adding new struct netns_ipvs
> pointers.  With a handful of other minor cleanups (like removing
> skb_net).
> 
> I have incorporated Julian Anastasov's feedback, which critically
> involves fixing a wrong piece of code.
> 
> The changes are also available against nf-next at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master
> 
> My entire pending set of changes for those who want to look ahead is at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git for-testing
> 
> Eric

	v2 looks good to me,

Acked-by: Julian Anastasov <ja@ssi.bg>

Regards

--
Julian Anastasov <ja@ssi.bg>
