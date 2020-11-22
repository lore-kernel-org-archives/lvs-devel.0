From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: replace atomic_add_return()
Date: Sun, 22 Nov 2020 13:46:28 +0100
Message-ID: <20201122124628.GA28719@salvia>
References: <1605513707-7579-1-git-send-email-yejune.deng@gmail.com>
 <9cd77e1e-1c52-d647-9443-485510b4a9b1@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9cd77e1e-1c52-d647-9443-485510b4a9b1@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Yejune Deng <yejune.deng@gmail.com>, wensong@linux-vs.org, horms@verge.net.au, kadlec@netfilter.org, fw@strlen.de, davem@davemloft.net, kuba@kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 17, 2020 at 10:57:52PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 16 Nov 2020, Yejune Deng wrote:
> 
> > atomic_inc_return() looks better
> > 
> > Signed-off-by: Yejune Deng <yejune.deng@gmail.com>
> 
> 	Looks good to me for -next, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
