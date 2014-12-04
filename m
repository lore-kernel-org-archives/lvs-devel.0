From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [ipvsadm PATCH 0/2] trivial compile warning fixes for ipvsadm
Date: Thu, 04 Dec 2014 10:38:50 +0100
Message-ID: <20141204093757.20470.92421.stgit@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Some trivial compile warning fixes from Daniel Borkmann to the ipvsadm tool.

I'll apply these to the git repo[1] if nobody objects.

[1] git://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git

---

Daniel Borkmann (2):
      ipvsadm: fix compile warning in print_largenum
      ipvsadm: fix compile warning in modprobe_ipvs


 ipvsadm.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

