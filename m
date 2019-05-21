From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] ipvs: Fix use-after-free in ip_vs_in
Date: Tue, 21 May 2019 18:30:30 +0200
Message-ID: <20190521163030.ly3mnllygtmfnx5d@salvia>
References: <alpine.LFD.2.21.1905171015040.2233@ja.home.ssi.bg>
 <20190517143149.17016-1-yuehaibing@huawei.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190517143149.17016-1-yuehaibing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: YueHaibing <yuehaibing@huawei.com>
Cc: davem@davemloft.net, wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, kadlec@blackhole.kfki.hu, fw@strlen.de, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Fri, May 17, 2019 at 10:31:49PM +0800, YueHaibing wrote:
> BUG: KASAN: use-after-free in ip_vs_in.part.29+0xe8/0xd20 [ip_vs]
> Read of size 4 at addr ffff8881e9b26e2c by task sshd/5603

Applied, thanks.
