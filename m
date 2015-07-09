From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Thu, 9 Jul 2015 09:29:27 +0900
Message-ID: <20150709002925.GA24713@verge.net.au>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
 <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
 <20150706035019.GA9155@verge.net.au>
 <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
 <20150708013355.GE28100@verge.net.au>
 <CALCkm3f0NTwUugb=sWVWQ2bJdecmZR_LFHocznuVR8fKRtRLkQ@mail.gmail.com>
 <1436390272.24939.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436390272.24939.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alex Gartrell <alexgartrell@gmail.com>, Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Wed, Jul 08, 2015 at 11:17:52PM +0200, Eric Dumazet wrote:
> On Wed, 2015-07-08 at 13:56 -0700, Alex Gartrell wrote:
> > On Tue, Jul 7, 2015 at 6:33 PM, Simon Horman <horms@verge.net.au> wrote:
> > 
> > > Is there any possibility you could investigate which stable trees are
> > > effected by this bug?
> > 
> > Well this was certainly a problem in 3.10 (we had our own hacky
> > solution at the time) and every kernel since then would have also had
> > this problem.  I'm pretty sure this isn't a problem in 3.4 or before.
> > 
> 
> early demux was added in 3.6
> 
> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")

Thanks Eric, Thanks Alex,

I think things are as clear as they need to be.
I'll add the above Fixes tag and get things queued up.
