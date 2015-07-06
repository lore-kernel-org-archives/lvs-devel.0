From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Mon, 6 Jul 2015 12:50:19 +0900
Message-ID: <20150706035019.GA9155@verge.net.au>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
 <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <alexgartrell@gmail.com>
Cc: Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Sun, Jul 05, 2015 at 03:19:27PM -0700, Alex Gartrell wrote:
> On Sun, Jul 5, 2015 at 3:13 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >         May be the patch fixes crashes? If yes, Simon
> > should apply it for ipvs/net tree, otherwise after
> > the merge window...
> 
> Yeah this is definitely a crash-fix and it's existed since at least 3.10.

Is it possible to get a 'Fixes:' tag?
