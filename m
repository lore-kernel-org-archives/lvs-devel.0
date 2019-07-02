From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: allow tunneling with gre
	encapsulation
Date: Tue, 2 Jul 2019 13:44:42 +0200
Message-ID: <20190702134442.2c646c76@carbon>
References: <20190701192537.4991-1-ja@ssi.bg>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <20190701192537.4991-1-ja@ssi.bg>
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
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, brouer@redhat.com, Vadim Fedorenko <vfedorenko@yandex-team.ru>, Jacky Hu <hengqing.hu@gmail.com>

On Mon,  1 Jul 2019 22:25:37 +0300
Julian Anastasov <ja@ssi.bg> wrote:

> Add support for real server tunnels with GRE encapsulation:
> --tun-type gre [--tun-nocsum|--tun-csum]
> 
> Co-developed-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
> Signed-off-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>  ipvsadm.8       | 19 ++++++++++++++-----
>  ipvsadm.c       | 20 +++++++++++++++++++-
>  libipvs/ip_vs.h |  1 +
>  3 files changed, 34 insertions(+), 6 deletions(-)
> 
> 	Jesper, this will follow the other patchset from 30-MAY-2019,
> "Allow tunneling with gue encapsulation".

I've applied Jacky's patches, which this patch builds on top of, to the
ipvsadm kernel.org git tree[1].

Simon already signed off on your kernel side patch, but it's not
applied to a kernel git tree yet... Do you want me to apply this, or
wait for this to hit a kernel tree?


[1] https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
