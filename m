From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v6 0/3] selftests: netfilter: introduce test cases for
 ipvs
Date: Fri, 11 Oct 2019 11:45:26 +0200
Message-ID: <20191011094524.ruopnvvh6bedhhgl@verge.net.au>
References: <1570719055-25110-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1570719055-25110-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Cc: Shuah Khan <shuah@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, Julian Anastasov <ja@ssi.bg>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Thu, Oct 10, 2019 at 10:50:52PM +0800, Haishuang Yan wrote:
> This series patch include test cases for ipvs.
> 
> The test topology is who as below:
> +--------------------------------------------------------------+
> |                      |                                       |
> |         ns0          |         ns1                           |
> |      -----------     |     -----------    -----------        |
> |      | veth01  | --------- | veth10  |    | veth12  |        |
> |      -----------    peer   -----------    -----------        |
> |           |          |                        |              |
> |      -----------     |                        |              |
> |      |  br0    |     |-----------------  peer |--------------|
> |      -----------     |                        |              |
> |           |          |                        |              |
> |      ----------     peer   ----------      -----------       |
> |      |  veth02 | --------- |  veth20 |     | veth12  |       |
> |      ----------      |     ----------      -----------       |
> |                      |         ns2                           |
> |                      |                                       |
> +--------------------------------------------------------------+
> 
> Test results:
> # selftests: netfilter: ipvs.sh
> # Testing DR mode...
> # Testing NAT mode...
> # Testing Tunnel mode...
> # ipvs.sh: PASS
> ok 6 selftests: netfilter: ipvs.sh
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Thanks, applied to ipvs-next.
