From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH v8 0/2] Allow tunneling with gue
	encapsulation
Date: Thu, 30 May 2019 21:37:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.21.1905302130360.4725@ja.home.ssi.bg>
References: <20190530080057.8218-1-hengqing.hu@gmail.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <20190530080057.8218-1-hengqing.hu@gmail.com>
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

On Thu, 30 May 2019, Jacky Hu wrote:

> This patchset allows tunneling with gue encapsulation.
> 
> v8->v7:
>   1) fixed a few style issues from scripts/checkpatch.pl --strict
>   2) use up to 4 letters in the comments
>   3) updated document for new options
> 
> v7->v6:
>   1) fix type of local variable in parse_tun_type
>   2) use up to 4 letters in the comments
>   3) document new options
> 
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
>  ipvsadm.8         |  70 ++++++++
>  ipvsadm.c         | 426 +++++++++++++++++++++++++++++++++++++++-------
>  libipvs/ip_vs.h   |  28 +++
>  libipvs/libipvs.c |  15 ++
>  4 files changed, 473 insertions(+), 66 deletions(-)
> 
> -- 
> 2.21.0

	Both patches look ok to me, thanks!

Acked-by: Julian Anastasov <ja@ssi.bg>

	Jesper, this patchset is based on the kernel patch
"[PATCH v4] ipvs: add checksum support for gue encapsulation"
which is to be applied to kernel trees. If needed, I can ping
you when the patch is accepted.

Regards

--
Julian Anastasov <ja@ssi.bg>
