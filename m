From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v7 0/2] Allow tunneling with gue
	encapsulation
Date: Thu, 30 May 2019 10:27:38 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1905301015160.4257@ja.home.ssi.bg>
References: <20190526150106.18622-1-hengqing.hu@gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <20190526150106.18622-1-hengqing.hu@gmail.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: Jacky Hu <hengqing.hu@gmail.com>
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, horms@verge.net.au, jacky.hu@walmart.com, brouer@redhat.com, jason.niesz@walmart.com


	Hello,

On Sun, 26 May 2019, Jacky Hu wrote:

> This patchset allows tunneling with gue encapsulation.
> 
> v7->v6:
>   1) fix type of local variable in parse_tun_type
>   2) use up to 4 letters in the comments
>   3) document new options

	May be we should fix some final styling problems:

scripts/checkpatch.pl --strict file.patch

	For patch 1/2: all

	For patch 2/2: some of them:

- "spaces preferred around" ...
- "Please don't use multiple blank lines"

	Also, in the new examples multiple -a lines do not give
much information, one -a would be enough. Or may be we can add
variations with the 3 csum options. If you prefer you can also
use 10.0.0.1 as VIP.

> v6->v5:
>   1) split the patch into two:
>      - ipvsadm: convert options to unsigned long long
>      - ipvsadm: allow tunneling with gue encapsulation
>   2) do not mix static and dynamic allocation in fwd_tun_info
>   3) use correct nla_get/put function for tun_flags
>   4) fixed || style
>   5) use correct return value for parse_tun_type
> 
> v5->v4:
>   1) add checksum support for gue encapsulation
> 
> v4->v3:
>   1) removed changes to setsockopt interface
>   2) use correct nla_get/put function for tun_port
> 
> v3->v2:
>   1) added missing break statements to a few switch cases
> 
> v2->v1:
>   1) pass tun_type and tun_port as new optional parameters
>      instead of a few bits in existing conn_flags parameters
> 
> Jacky Hu (2):
>   ipvsadm: convert options to unsigned long long
>   ipvsadm: allow tunneling with gue encapsulation
> 
>  ipvsadm.8         |  72 ++++++++
>  ipvsadm.c         | 427 +++++++++++++++++++++++++++++++++++++++-------
>  libipvs/ip_vs.h   |  28 +++
>  libipvs/libipvs.c |  15 ++
>  4 files changed, 476 insertions(+), 66 deletions(-)
> 
> -- 
> 2.21.0

Regards

--
Julian Anastasov <ja@ssi.bg>
