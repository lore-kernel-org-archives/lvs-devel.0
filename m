From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 0/3] ipvsadm: Document/add support for
 fo/ovf/mh schedulers
Date: Tue, 22 Jan 2019 12:02:35 +0100
Message-ID: <20190122120235.0a98b47d@redhat.com>
References: <1547679304.3577.207.camel@armitage.org.uk>
	<alpine.LFD.2.21.1901170203590.8721@ja.home.ssi.bg>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <alpine.LFD.2.21.1901170203590.8721@ja.home.ssi.bg>
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
Cc: lvs-users@linuxvirtualserver.org, Inju Song <inju.song@navercorp.com>, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, brouer@redhat.com, Quentin Armitage <quentin@armitage.org.uk>


On Thu, 17 Jan 2019 02:09:22 +0200 (EET) Julian Anastasov <ja@ssi.bg> wrote:

> On Wed, 16 Jan 2019, Quentin Armitage wrote:
> 
> > The kernel supports the fo, ovf and mh IPVS schedulers, but ipvsadm has not
> > yet been updated to document/support them. Currently ipvsadm can support them,
> > but users of ipvsadm will not be aware of their existence without reading the
> > kernel sources.
> > 
> > The following patches document support for these schedulers, and also adds
> > new flags mh-fallback and mh-port.
> > 
> > Changes since v1:
> > - Correct description of fo scheduler
> > - Correct description of ovf scheduler
> > - Completely rewrite description of mh scheduler
> > - Move definitions of IP_VS_SVC_F_SCHED_MH* from ipvsadm.c to libipvs/ip_vs.h
> > - Don't print flag-3 for SH and MH schedulers
> > 
> > With many thanks to Julian Anastasov for pointing out the errors in the
> > v1 patches and the suggested improvements.
> > 
> > Quentin Armitage (3):
> >   ipvsadm: Document support of fo scheduler
> >   ipvsadm: Document support of ovf scheduler
> >   ipvsadm: Add support for mh scheduler
> > 
> >  SCHEDULERS      |  2 +-
> >  ipvsadm.8       | 18 ++++++++++++++++++
> >  ipvsadm.c       | 17 +++++++++++++++--
> >  libipvs/ip_vs.h |  3 +++
> >  4 files changed, 37 insertions(+), 3 deletions(-)  
> 
> 	The 3 patches look ok to me. Thanks!
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Jesper, you can apply them if there are no other
> suggestions/comments.

Nobody else objected, thus I've applied this patchset to git tree:
  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/

Thank you Quentin for keeping this tool up-to-date.
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
