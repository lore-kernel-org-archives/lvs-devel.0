From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH 0/3] ipvsadm: Document/add support for fo/ovf/mh
	schedulers
Date: Fri, 04 Jan 2019 20:26:27 +0000
Message-ID: <1546633587.3577.11.camel@armitage.org.uk>
Reply-To: quentin@armitage.org.uk, "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
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
To: Jesper Dangaard Brouer <brouer@redhat.com>, Simon Horman <horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org

The kernel supports the fo, ovf and mh IPVS schedulers, but ipvsadm has not
yet been updated to document/support them. Currently ipvsadm can support them,
but users of ipvsadm will not be aware of their existence without reading the
kernel sources.

The following patches document support for these schedulers, and also adds
new flags mh-fallback and mh-port.

Quentin Armitage (3):
  ipvsadm: Document support of fo scheduler
  ipvsadm: Document support of ovf scheduler
  ipvsadm: Add support for mh scheduler

 SCHEDULERS |  2 +-
 ipvsadm.8  | 19 +++++++++++++++++++
 ipvsadm.c  | 31 +++++++++++++++++++++++++++----
 3 files changed, 47 insertions(+), 5 deletions(-)
