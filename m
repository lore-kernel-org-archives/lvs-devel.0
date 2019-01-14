From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/3] ipvsadm: Document/add support for
 fo/ovf/mh schedulers
Date: Mon, 14 Jan 2019 19:49:43 +0100
Message-ID: <20190114194943.49b8e8c9@redhat.com>
References: <1546633587.3577.11.camel@armitage.org.uk>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <1546633587.3577.11.camel@armitage.org.uk>
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
To: Quentin Armitage <quentin@armitage.org.uk>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>, brouer@redhat.com

On Fri, 04 Jan 2019 20:26:27 +0000
Quentin Armitage <quentin@armitage.org.uk> wrote:

> The kernel supports the fo, ovf and mh IPVS schedulers, but ipvsadm has not
> yet been updated to document/support them. Currently ipvsadm can support them,
> but users of ipvsadm will not be aware of their existence without reading the
> kernel sources.
> 
> The following patches document support for these schedulers, and also adds
> new flags mh-fallback and mh-port.

Hi Quentin,

Can you please update the patchset according to Julian's comments, and
submit a V2 of this patchset?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
