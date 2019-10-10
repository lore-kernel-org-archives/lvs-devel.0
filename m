From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v5 1/3] selftests: netfilter: add ipvs test script
Date: Thu, 10 Oct 2019 11:42:16 +0200
Message-ID: <20191010094215.73rlcbn2tt4wgr54@verge.net.au>
References: <1570619790-6086-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1570619790-6086-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1570619790-6086-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Cc: Shuah Khan <shuah@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Wed, Oct 09, 2019 at 07:16:28PM +0800, Haishuang Yan wrote:
> Test virutal server via directing routing for IPv4.
> 
> Tested:
> 
> # selftests: netfilter: ipvs.sh
> # Testing DR mode...
> # ipvs.sh: PASS
> ok 6 selftests: netfilter: ipvs.sh
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
> v5: use cmp to compare two file contents suggested by Simon Horman
> v4: use #!/bin/bash -p suggested by Duncan Roe
> v3: use bash style
> v2: optimize test script
> ---
>  tools/testing/selftests/netfilter/Makefile |   2 +-
>  tools/testing/selftests/netfilter/ipvs.sh  | 178 +++++++++++++++++++++++++++++
>  2 files changed, 179 insertions(+), 1 deletion(-)
>  create mode 100755 tools/testing/selftests/netfilter/ipvs.sh
> 
> diff --git a/tools/testing/selftests/netfilter/Makefile b/tools/testing/selftests/netfilter/Makefile
> index 4144984..de1032b 100644
> --- a/tools/testing/selftests/netfilter/Makefile
> +++ b/tools/testing/selftests/netfilter/Makefile
> @@ -2,6 +2,6 @@
>  # Makefile for netfilter selftests
>  
>  TEST_PROGS := nft_trans_stress.sh nft_nat.sh bridge_brouter.sh \
> -	conntrack_icmp_related.sh nft_flowtable.sh
> +	conntrack_icmp_related.sh nft_flowtable.sh ipvs.sh
>  
>  include ../lib.mk
> diff --git a/tools/testing/selftests/netfilter/ipvs.sh b/tools/testing/selftests/netfilter/ipvs.sh
> new file mode 100755
> index 0000000..f844c0a
> --- /dev/null
> +++ b/tools/testing/selftests/netfilter/ipvs.sh
> @@ -0,0 +1,178 @@
> +#!/bin/bash -p

Please change this to /bin/sh
