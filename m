From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2] ipvs: optimize tunnel dumps for icmp errors
Date: Wed, 1 Apr 2020 15:03:20 +0200
Message-ID: <20200401130319.GG29376@vergenet.net>
References: <1584278741-13944-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <alpine.LFD.2.21.2003181333460.4911@ja.home.ssi.bg>
 <20200326140229.emeplg75xszpd7rs@salvia>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20200326140229.emeplg75xszpd7rs@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, Haishuang Yan <yanhaishuang@cmss.chinamobile.com>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Mar 26, 2020 at 03:02:29PM +0100, Pablo Neira Ayuso wrote:
> On Wed, Mar 18, 2020 at 01:36:32PM +0200, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Sun, 15 Mar 2020, Haishuang Yan wrote:
> > 
> > > After strip GRE/UDP tunnel header for icmp errors, it's better to show
> > > "GRE/UDP" instead of "IPIP" in debug message.
> > > 
> > > Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> > 
> > 	Looks good to me, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> > 
> > 	Simon, this is for -next kernels...
> 
> Simon, if no objection, I'm going to include this in the next nf-next
> pull request.
> 

Sorry for being slow, I have no objections.
