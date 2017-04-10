From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: ipvs: Replace explicit NULL comparison
Date: Mon, 10 Apr 2017 13:53:00 +0200
Message-ID: <20170410115300.GB2155@salvia>
References: <20170408171805.GA9156@arushi-HP-Pavilion-Notebook>
 <201704090633.AKZxFfWl%fengguang.wu@intel.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201704090633.AKZxFfWl%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kbuild test robot <lkp@intel.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>, kbuild-all@01.org, wensong@linux-vs.org, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

Arushi,

On Sun, Apr 09, 2017 at 06:21:51AM +0800, kbuild test robot wrote:
> Hi Arushi,
> 
> [auto build test WARNING on ipvs-next/master]
> [also build test WARNING on v4.11-rc5 next-20170407]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Arushi-Singhal/net-netfilter-ipvs-Replace-explicit-NULL-comparison/20170409-044710
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git master
> config: i386-randconfig-x002-201715 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All warnings (new ones prefixed by >>):
> 
>    net/netfilter/ipvs/ip_vs_proto.c: In function 'ip_vs_protocol_net_cleanup':
> >> net/netfilter/ipvs/ip_vs_proto.c:350:3: warning: suggest parentheses around assignment used as truth value [-Wparentheses]
>       while (pd = ipvs->proto_data_table[i])
>       ^~~~~

This is bad, you have to be more careful in what you do. This is not a
speed coding contest.

Showing careful patchset handling, even if you submit less of them, is
way more prefered in my opinion.
