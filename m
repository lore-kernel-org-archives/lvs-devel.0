From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Wed, 8 Jul 2015 10:33:55 +0900
Message-ID: <20150708013355.GE28100@verge.net.au>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
 <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
 <20150706035019.GA9155@verge.net.au>
 <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <alexgartrell@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Sun, Jul 05, 2015 at 09:14:38PM -0700, Alex Gartrell wrote:
> On Sun, Jul 5, 2015 at 8:50 PM, Simon Horman <horms@verge.net.au> wrote:
> > Is it possible to get a 'Fixes:' tag?
> 
> I suppose it'd be appropriate to say
> 
> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
> 
> As that is what introduces tcp early_demux, but that's just a guess as
> I haven't bisected it (not even sure my test would run on that code
> base).

Thanks. The reason that I am asking about this is to ease getting
this fix, or a derivative of it, into the appropriate stable trees.

Is there any possibility you could investigate which stable trees are
effected by this bug?
