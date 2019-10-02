From: Duncan Roe <duncan_roe@optusnet.com.au>
Subject: Re: [PATCH v3 0/3] selftests: netfilter: introduce test cases for
 ipvs
Date: Wed, 2 Oct 2019 11:27:26 +1000
Message-ID: <20191002012726.GB9810@dimstar.local.net>
References: <1569939599-1872-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <alpine.LFD.2.21.1910012133330.3887@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.21.1910012133330.3887@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>, Shuah Khan <shuah@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, "David S. Miller" <davem@davemloft.net>, Simon Horman <horms@verge.net.au>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org

On Tue, Oct 01, 2019 at 09:34:13PM +0300, Julian Anastasov wrote:
>
> 	Hello,
>
> On Tue, 1 Oct 2019, Haishuang Yan wrote:
>
> > This series patch include test cases for ipvs.
> >
> > The test topology is who as below:
> > +--------------------------------------------------------------+
> > |                      |                                       |
> > |         ns0          |         ns1                           |
> > |      -----------     |     -----------    -----------        |
> > |      | veth01  | --------- | veth10  |    | veth12  |        |
> > |      -----------    peer   -----------    -----------        |
> > |           |          |                        |              |
> > |      -----------     |                        |              |
> > |      |  br0    |     |-----------------  peer |--------------|
> > |      -----------     |                        |              |
> > |           |          |                        |              |
> > |      ----------     peer   ----------      -----------       |
> > |      |  veth02 | --------- |  veth20 |     | veth12  |       |
> > |      ----------      |     ----------      -----------       |
> > |                      |         ns2                           |
> > |                      |                                       |
> > +--------------------------------------------------------------+
> >
> > Test results:
> > # selftests: netfilter: ipvs.sh
> > # Testing DR mode...
> > # Testing NAT mode...
> > # Testing Tunnel mode...
> > # ipvs.sh: PASS
> > ok 6 selftests: netfilter: ipvs.sh
> >
> > Haishuang Yan (3):
> >   selftests: netfilter: add ipvs test script
> >   selftests: netfilter: add ipvs nat test case
> >   selftests: netfilter: add ipvs tunnel test case
>
> Acked-by: Julian Anastasov <ja@ssi.bg>
>
> >  tools/testing/selftests/netfilter/Makefile |   2 +-
> >  tools/testing/selftests/netfilter/ipvs.sh  | 234 +++++++++++++++++++++++++++++
> >  2 files changed, 235 insertions(+), 1 deletion(-)
> >  create mode 100755 tools/testing/selftests/netfilter/ipvs.sh
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

I still prefer #!/bin/sh in 1/3. You never know what's in someone's environment

Cheers ... Duncan.
