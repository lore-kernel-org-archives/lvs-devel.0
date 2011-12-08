From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] IPVS: Modify the SH scheduler to use weights
Date: Thu, 8 Dec 2011 01:49:00 +0100
Message-ID: <20111208004900.GA22241@1984>
References: <1323245223-13646-1-git-send-email-horms@verge.net.au>
 <1323245223-13646-2-git-send-email-horms@verge.net.au>
 <20111207113038.GA18166@1984>
 <CAOgH2dsHepr7Dyx7pNOutFNRh5SoO-oC9mx1MLm6Ncai8Ma3rQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOgH2dsHepr7Dyx7pNOutFNRh5SoO-oC9mx1MLm6Ncai8Ma3rQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Maxim <mike@okcupid.com>
Cc: Simon Horman <horms@verge.net.au>, Patrick McHardy <kaber@trash.net>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>

On Wed, Dec 07, 2011 at 10:24:09AM -0500, Mike Maxim wrote:
> The reason I put that in is because the size of that table becomes
> more relevant/important if you decide to use the weights in the manner
> the patch lets you. It would be conceivable that someone might need to
> increase the size of that table to accommodate their configuration, so
> I thought it would be handy to be able to do that through the regular
> configuration system instead of editing the source.

That explains that chunk.

Would you mind resubmitting the patch including this description in the
patch and removing the unnecessary line deletion / addition?

Thanks!
