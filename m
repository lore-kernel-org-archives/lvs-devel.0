From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 06/24] netfilter: Remove unnecessary OOM logging
 messages
Date: Tue, 11 Oct 2011 02:15:05 +0200
Message-ID: <20111011001505.GB30117@1984>
References: <cover.1314650069.git.joe@perches.com>
 <13c1c12486cae409dfa5254b1435e660f2b17e05.1314650069.git.joe@perches.com>
 <4E5CDBAA.6040001@trash.net>
 <20110830.135502.179848097213434762.davem@davemloft.net>
 <4E5E092E.80507@trash.net>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E5E092E.80507@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>
Cc: David Miller <davem@davemloft.net>, joe@perches.com, bart.de.schuymer@pandora.be, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, shemminger@linux-foundation.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On Wed, Aug 31, 2011 at 12:13:02PM +0200, Patrick McHardy wrote:
> On 30.08.2011 19:55, David Miller wrote:
> > From: Patrick McHardy <kaber@trash.net>
> > Date: Tue, 30 Aug 2011 14:46:34 +0200
> > 
> >> On 29.08.2011 23:17, Joe Perches wrote:
> >>> Removing unnecessary messages saves code and text.
> >>>
> >>> Site specific OOM messages are duplications of a generic MM
> >>> out of memory message and aren't really useful, so just
> >>> delete them.
> >>
> >> Looks good to me. Do you want me to apply this patch or are you
> >> intending to have the entire series go through Dave?
> > 
> > I'm happy with subsystem folks taking things in if they want, the
> > B.A.T.M.A.N. guys did this earlier today for example.
> 
> OK, thanks.
> 
> Applied after fixing up some minor rejects in nf_nat_snmp_basic.c,
> thanks Joe.

I have rescued this patch and put into this tree:

http://1984.lsi.us.es/git/?p=net-next/.git;a=shortlog;h=refs/heads/nf-next

At that time (kernel.org problems), we had no public tree and Patrick
temporarily stored in his internal tree.
