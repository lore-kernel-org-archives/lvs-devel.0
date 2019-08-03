From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net v3] ipvs: Improve robustness to the ipvs sysctl
Date: Sat, 3 Aug 2019 18:40:15 +0200
Message-ID: <20190803164015.eiy4hanb27qyrjzz@salvia>
References: <1997375e-815d-137f-20c9-0829a8587ee9@huawei.com>
 <4a0476d3-57a4-50e0-cae8-9dffc4f4d556@huawei.com>
 <5fd55d18-f4e2-a6b4-5c54-db76c05be5df@huawei.com>
 <alpine.LFD.2.21.1907312052310.3631@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.21.1907312052310.3631@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: hujunwei <hujunwei4@huawei.com>, wensong@linux-vs.org, horms@verge.net.au, kadlec@blackhole.kfki.hu, Florian Westphal <fw@strlen.de>, davem@davemloft.net, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Mingfangsen <mingfangsen@huawei.com>, wangxiaogang3@huawei.com, xuhanbing@huawei.com

On Wed, Jul 31, 2019 at 08:53:47PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 1 Aug 2019, hujunwei wrote:
> 
> > From: Junwei Hu <hujunwei4@huawei.com>
> > 
> > The ipvs module parse the user buffer and save it to sysctl,
> > then check if the value is valid. invalid value occurs
> > over a period of time.
> > Here, I add a variable, struct ctl_table tmp, used to read
> > the value from the user buffer, and save only when it is valid.
> > I delete proc_do_sync_mode and use extra1/2 in table for the
> > proc_dointvec_minmax call.
> > 
> > Fixes: f73181c8288f ("ipvs: add support for sync threads")
> > Signed-off-by: Junwei Hu <hujunwei4@huawei.com>
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Yep, Acked-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks.
