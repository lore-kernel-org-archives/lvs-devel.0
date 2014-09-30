From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] ipvs: fix ipv6 hook registration for local replies
Date: Tue, 30 Sep 2014 14:13:27 +0900
Message-ID: <20140930051326.GJ16823@verge.net.au>
References: <1408719221-8042-1-git-send-email-ja@ssi.bg>
 <20140828015534.GE5936@verge.net.au>
 <5422DB4F.5060900@canonical.com>
 <20140925002216.GB20466@verge.net.au>
 <20140925165757.GA13339@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140925165757.GA13339@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Chris J Arges <chris.j.arges@canonical.com>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Thu, Sep 25, 2014 at 06:57:57PM +0200, Pablo Neira Ayuso wrote:
> On Thu, Sep 25, 2014 at 09:22:16AM +0900, Simon Horman wrote:
> > [CC Pablo]
> > 
> > On Wed, Sep 24, 2014 at 09:55:11AM -0500, Chris J Arges wrote:
> > > On 08/27/2014 08:55 PM, Simon Horman wrote:
> > > > On Fri, Aug 22, 2014 at 05:53:41PM +0300, Julian Anastasov wrote:
> > > >> commit fc604767613b6d2036cdc35b660bc39451040a47
> > > >> ("ipvs: changes for local real server") from 2.6.37
> > > >> introduced DNAT support to local real server but the
> > > >> IPv6 LOCAL_OUT handler ip_vs_local_reply6() is
> > > >> registered incorrectly as IPv4 hook causing any outgoing
> > > >> IPv4 traffic to be dropped depending on the IP header values.
> > > >>
> > > >> Chris tracked down the problem to CONFIG_IP_VS_IPV6=y
> > > >> Bug report: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1349768
> > > >>
> > > >> Reported-by: Chris J Arges <chris.j.arges@canonical.com>
> > > >> Tested-by: Chris J Arges <chris.j.arges@canonical.com>
> > > >> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > > 
> > > > Thanks, and sorry for the delay.
> > > > I have queued this up in the ipvs tree as a fix for v3.17.
> > > > I also plan to ask for it to be considered for -stable.
> > > > 
> > > Julian,
> > > Has this been queued up for netdev stable? Or should I send an email?
> > > Thanks,
> > 
> > Pablo I'm not sure that this has been queued up for stable
> > (possibly due to some error on my part). What is the best
> > way forwards?
> 
> Just sent a batch with pending Netfilter/IPVS to -stable. The patch
> authors has been Cc'ed. I didn't Cc'ed the mailing list to not
> generate more load on redudant patches, but I can do it if you prefer
> so.
> 
> Let me know if we don't get any feedback from -stable soon to get this
> patches in. Thanks.

Thanks Pablo.
