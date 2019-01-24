From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: Fix signed integer overflow when setsockopt timeout
Date: Thu, 24 Jan 2019 13:32:04 +0100
Message-ID: <20190124123204.yllpivzdshofap6z@salvia>
References: <1547109546-11344-1-git-send-email-zhangxiaoxu5@huawei.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1547109546-11344-1-git-send-email-zhangxiaoxu5@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
Cc: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Jan 10, 2019 at 04:39:06PM +0800, ZhangXiaoxu wrote:
> There is a UBSAN bug report as below:
> UBSAN: Undefined behaviour in net/netfilter/ipvs/ip_vs_ctl.c:2227:21
> signed integer overflow:
> -2147483647 * 1000 cannot be represented in type 'int'

Applied, thanks.
