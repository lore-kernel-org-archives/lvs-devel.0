From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] ipvs: optimize tunnel dumps for icmp errors
Date: Thu, 26 Mar 2020 15:02:29 +0100
Message-ID: <20200326140229.emeplg75xszpd7rs@salvia>
References: <1584278741-13944-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <alpine.LFD.2.21.2003181333460.4911@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.21.2003181333460.4911@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>, Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Mar 18, 2020 at 01:36:32PM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 15 Mar 2020, Haishuang Yan wrote:
> 
> > After strip GRE/UDP tunnel header for icmp errors, it's better to show
> > "GRE/UDP" instead of "IPIP" in debug message.
> > 
> > Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> 	Looks good to me, thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Simon, this is for -next kernels...

Simon, if no objection, I'm going to include this in the next nf-next
pull request.

Thanks.
