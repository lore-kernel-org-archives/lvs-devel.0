From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Remove possibly unused net variable from ip_vs_out
Date: Wed, 7 Oct 2015 10:14:36 +0900
Message-ID: <20151007011435.GA22578@verge.net.au>
References: <1444119324-5653-1-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.11.1510062122310.1745@ja.home.ssi.bg>
 <CAHA+R7MezkwDg0mTMrR2HZ3sc7OMG2J-ED9F3g4XL7_16QBYyw@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7MezkwDg0mTMrR2HZ3sc7OMG2J-ED9F3g4XL7_16QBYyw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Cong Wang <cwang@twopensource.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, "Eric W. Biederman" <ebiederm@xmission.com>

On Tue, Oct 06, 2015 at 04:27:35PM -0700, Cong Wang wrote:
> On Tue, Oct 6, 2015 at 11:24 AM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         Hello,
> >
> > On Tue, 6 Oct 2015, Simon Horman wrote:
> >
> >> Since 6f2bcea9917d ("ipvs: Pass ipvs into ip_vs_in_icmp and
> >> ip_vs_in_icmp_v6") the net variable in ip_vs_out() appears to be unused
> >> unless CONFIG_IP_VS_IPV6 is set. To resolve this remove the net variable
> >> and dereference net asneeded.
> >>
> >> Signed-off-by: Simon Horman <horms@verge.net.au>
> >
> >         Both patches look good to me
> >
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> >
> 
> David sent a same patch earlier:
> 
> http://www.spinics.net/lists/netdev/msg345887.html

Thanks, I have queued up his version in ipvs-next.
