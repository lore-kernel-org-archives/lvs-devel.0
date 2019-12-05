From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: allow tunneling with gre
	encapsulation
Date: Thu, 5 Dec 2019 12:34:43 +0100
Message-ID: <20191205123443.75eeb03c@carbon>
References: <20190701192537.4991-1-ja@ssi.bg> <20190702134442.2c646c76@carbon>
	<alpine.LFD.2.21.1907022210200.4236@ja.home.ssi.bg>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1575545698;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	content-transfer-encoding:content-transfer-encoding:
	in-reply-to:in-reply-to:references:references;
	bh=MKtp+WpNbuhLdMOTzJSR1yYLCXWsbks7EQnS7Btik7w=;
	b=BuMWNS4W5bnX4933lZssu2YnjgR6PIC22/mKi7v75mTEO1A0A7ukUnUjcm6hDJYpel2VkK
	VZqZO0pZ17me3DWrn9TlAwh5p6wubMfHTMiVR2IFMZ7VAkU79hbP24dWBL5L3EEymwLVrt
	pva6sHTMp6lkBS3kYAumDJZPyS+l+RU=
In-Reply-To: <alpine.LFD.2.21.1907022210200.4236@ja.home.ssi.bg>
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
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, netfilter-devel@vger.kernel.org, brouer@redhat.com, Vadim Fedorenko <vfedorenko@yandex-team.ru>, Jacky Hu <hengqing.hu@gmail.com>, Quentin Armitage <quentin@armitage.org.uk>

On Tue, 2 Jul 2019 22:21:01 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	Hello,
> 
> On Tue, 2 Jul 2019, Jesper Dangaard Brouer wrote:
> 
> > On Mon,  1 Jul 2019 22:25:37 +0300
> > Julian Anastasov <ja@ssi.bg> wrote:
> >   
> > > Add support for real server tunnels with GRE encapsulation:
> > > --tun-type gre [--tun-nocsum|--tun-csum]
> > > 
> > > Co-developed-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
> > > Signed-off-by: Vadim Fedorenko <vfedorenko@yandex-team.ru>
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > ---
> > >  ipvsadm.8       | 19 ++++++++++++++-----
> > >  ipvsadm.c       | 20 +++++++++++++++++++-
> > >  libipvs/ip_vs.h |  1 +
> > >  3 files changed, 34 insertions(+), 6 deletions(-)
> > > 
> > > 	Jesper, this will follow the other patchset from 30-MAY-2019,
> > > "Allow tunneling with gue encapsulation".  
> > 
> > I've applied Jacky's patches, which this patch builds on top of, to the
> > ipvsadm kernel.org git tree[1].
> > 
> > Simon already signed off on your kernel side patch, but it's not
> > applied to a kernel git tree yet... Do you want me to apply this, or
> > wait for this to hit a kernel tree?  
> 
> 	The both GRE patches are already part of nf-next, so
> it is fine to apply this ipvsadm patch for GRE now. It would be
> better in case one wants to test the new features...

I noticed that I had applied this patch, but forgot to push the ipvsadm
git tree[1] on kernel.org.  I've now pushed this...

https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=4a72198e7a3f9f275ff5752

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/

