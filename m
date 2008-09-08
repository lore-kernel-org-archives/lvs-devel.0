From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Embed user stats structure into kernel stats
	structure
Date: Tue, 9 Sep 2008 09:53:39 +1000
Message-ID: <20080908235337.GI13048@verge.net.au>
References: <alpine.LNX.2.00.0809081338130.18192@titan.stealer.net> <f4845fc0809080707i3751e5a4o45da7b7b16f50c4e@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f4845fc0809080707i3751e5a4o45da7b7b16f50c4e@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: Sven Wegener <sven.wegener@stealer.net>, Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>

On Mon, Sep 08, 2008 at 04:07:10PM +0200, Julius Volz wrote:
> On Mon, Sep 8, 2008 at 1:39 PM, Sven Wegener wrote:
> > Instead of duplicating the fields, integrate a user stats structure into
> > the kernel stats structure. This is more robust when the members are
> > changed, because they are now automatically kept in sync.
> >
> > Signed-off-by: Sven Wegener <sven.wegener@stealer.net>

Thanks Sven. Applied.
