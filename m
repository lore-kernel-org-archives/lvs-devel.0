From: "overcastsky.zhao@gmail.com" <overcastsky.zhao@gmail.com>
Subject: Re: [ANNOUNCE] ipvsadm release v1.28
Date: Tue, 10 Feb 2015 10:42:58 +0800
Message-ID: <201502101042541489680@gmail.com>
References: <20150209185502.693488a1@redhat.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
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
To: Jesper Dangaard Brouer <brouer@redhat.com>, lvs-devel <lvs-devel@vger.kernel.org>, lvs-users <lvs-users@linuxvirtualserver.org>
Cc: Wensong Zhang <wensong@linux-vs.org>, logan <logan@ubuntu.com>, netdev <netdev@vger.kernel.org>, brouer <brouer@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, formorer <formorer@debian.org>, dborkman <dborkman@redhat.com>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>, support <support@remsnet.de>, Alex Gartrell <agartrell@fb.com>, mt <mt@suse.de>







Thank=A0you=A0for=A0your=A0help.I=A0will=A0download=A0and=A0test.Welcome=A0=
to=A0Nanjing,China.=A0I=A0will=A0your=A0guide.=A0


overcastsky.zhao@gmail.com
=A0From:=A0Jesper Dangaard BrouerDate:=A02015-02-09=A013:55To:=A0lvs-devel;=
 lvs-usersCC:=A0brouer; netdev; linux-kernel; Ryan O'Hara; Julian Anastasov=
; overcastsky.zhao; formorer; mt; logan; support; Daniel Borkmann; Wensong =
Zhang; Simon Horman; Alex GartrellSubject:=A0[ANNOUNCE] ipvsadm release v1.=
28=A0
We are happy to announce the release of ipvsadm v1.28.
=A0
 ipvsadm is a utility to administer the kernels IPVS/LVS load-balancer serv=
ice
=A0
It has been quite a while since the previous release, v1.27. A number of
fixes and improvements have been made; most noticeably in the area of IPv6.
=A0
One big addition is the support for heterogeneous pools (v4 and v6
mixed pools in 3.18), by Alex Gartrell (facebook).
=A0
Feature wise the SCTP protocol has been added which is available via the
cmdline parameter "--sctp-service". The kernel has supported SCTP since
kernel 2.6.34 but up until now ipvsadm users have been restricted to using
fwmark-based virtual services for SCTP.
=A0
This release is based on the kernel.org git tree:
=A0 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/
=A0
You can download the tarballs from:
 https://kernel.org/pub/linux/utils/kernel/ipvsadm/
=A0
Git tree:
 git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git
=A0
Shortlog:
 Alex Gartrell (2):
=A0=A0=A0=A0=A0 ipvsadm: specify real server address family to netlink sock=
et
=A0=A0=A0=A0=A0 ipvsadm: do not truncate ipv6 members of v4 services
=A0
 Daniel Borkmann (2):
=A0=A0=A0=A0=A0 ipvsadm: fix compile warning in print_largenum
=A0=A0=A0=A0=A0 ipvsadm: fix compile warning in modprobe_ipvs
=A0
 Hibari Michiro (1):
=A0=A0=A0=A0=A0 ipvsadm: enable displaying of IPv6 hostnames in listing
=A0
 Jesper Dangaard Brouer (1):
=A0=A0=A0=A0=A0 Release: Version 1.28
=A0
 Julian Anastasov (3):
=A0=A0=A0=A0=A0 ipvsadm: restrict different address family
=A0=A0=A0=A0=A0 ipvsadm: allow different address family in connection listi=
ng
=A0=A0=A0=A0=A0 ipvsadm: add SCTP support
=A0
 Ryan O'Hara (2):
=A0=A0=A0=A0=A0 libipvs: Initialize ipvs_service_t variable
=A0=A0=A0=A0=A0 ipvsadm: Fix list daemon to show backup daemon
=A0
=A0
-- =

Best regards,
=A0 Jesper Dangaard Brouer
=A0 MSc.CS, Sr. Network Kernel Developer at Red Hat
=A0 Author of http://www.iptv-analyzer.org
=A0 LinkedIn: http://www.linkedin.com/in/brouer
