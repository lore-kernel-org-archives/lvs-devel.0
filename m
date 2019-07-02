From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 0/2] Allow tunneling with gue
	encapsulation
Date: Tue, 2 Jul 2019 13:12:09 +0200
Message-ID: <20190702131209.57c018ea@carbon>
References: <20190530080057.8218-1-hengqing.hu@gmail.com>
	<alpine.LFD.2.21.1905302130360.4725@ja.home.ssi.bg>
	<20190531084955.7cd4af00@carbon>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <20190531084955.7cd4af00@carbon>
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
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, horms@verge.net.au, jacky.hu@walmart.com, brouer@redhat.com, Jacky Hu <hengqing.hu@gmail.com>, jason.niesz@walmart.com

On Fri, 31 May 2019 08:49:55 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Thu, 30 May 2019 21:37:34 +0300 (EEST) Julian Anastasov <ja@ssi.bg> wrote:
> 
> > On Thu, 30 May 2019, Jacky Hu wrote:
> >   
> > > This patchset allows tunneling with gue encapsulation.
> > >   
> [...]
> > 
> > 	Both patches look ok to me, thanks!
> > 
> > Acked-by: Julian Anastasov <ja@ssi.bg>
> > 
> > 	Jesper, this patchset is based on the kernel patch
> > "[PATCH v4] ipvs: add checksum support for gue encapsulation"
> > which is to be applied to kernel trees. If needed, I can ping
> > you when the patch is accepted.  

Looks like this commit got applied to the kernel in commit 29930e314da3
("ipvs: add checksum support for gue encapsulation"), but only net-next.

Thus, I've applied this user-side patchset to ipvsadm.
 https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/

As you might have noticed, I've created a release v1.30 prio to applying
these.  As we have to wait for a kernel release, likely kernel v5.3,
before making an ipvsadm release with this GUE feature.

It should also make it easier for Julian's GRE work, to build on top.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

commit 29930e314da3833437a2ddc7b17f6a954f38d8fb
Author: Jacky Hu <hengqing.hu@gmail.com>
Date:   Thu May 30 08:16:40 2019 +0800

    ipvs: add checksum support for gue encapsulation
    
    Add checksum support for gue encapsulation with the tun_flags parameter,
    which could be one of the values below:
    IP_VS_TUNNEL_ENCAP_FLAG_NOCSUM
    IP_VS_TUNNEL_ENCAP_FLAG_CSUM
    IP_VS_TUNNEL_ENCAP_FLAG_REMCSUM
    
    Signed-off-by: Jacky Hu <hengqing.hu@gmail.com>
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: Simon Horman <horms@verge.net.au>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
