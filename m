From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] netfilter: ipvs: Verify that IP_VS protocol has been
 registered
Date: Fri, 13 Apr 2012 11:35:55 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204131134500.1778@ja.ssi.bg>
References: <1333668273-8873-1-git-send-email-levinsasha928@gmail.com> <20120411232243.GB7038@1984> <20120411234628.GA7253@1984> <CA+1xoqcxggYxb_ha4VdQtCUW-iYeVbaB38mC_pwAzdCf=rS7mQ@mail.gmail.com> <20120413041150.GA26149@verge.net.au>
 <20120413062250.GA6163@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20120413062250.GA6163@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Sasha Levin <levinsasha928@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, wensong@linux-vs.org, kaber@trash.net, davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org


	Hello,

On Fri, 13 Apr 2012, Simon Horman wrote:

> On Fri, Apr 13, 2012 at 01:11:50PM +0900, Simon Horman wrote:
> > On Fri, Apr 13, 2012 at 02:54:13AM +0200, Sasha Levin wrote:
> > > On Thu, Apr 12, 2012 at 1:46 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> > > >> If you return here, I think you'll leave things in inconsistent state,
> > > >> ie. the tcp protocol is registered. You have to unregister it before
> > > >> leaving.
> > > 
> > > I thought that the cleanup callback is getting called for failed init
> > > calls, if that's not the case then we can probably call it ourselves
> > > if any of these failed.
> > 
> > Good point. In any case, I think that I have found a new problem.
> 
> [sni@]
> 
> I have confirmed that the cleanup code is called on error, so I think that
> your existing patch is fine.
> 
> Acked-by: Simon Horman <horms@verge.net.au>
> 
> Pablo, please consider taking this change. The other problem I raised,
> though related, can be handled separately as it won't occur if the
> ftp helper isn't initialised.

	Simon, I'm sending 2 patches for this ftp problem
in separate thread. Please, test if the problem is solved.

Regards

--
Julian Anastasov <ja@ssi.bg>
