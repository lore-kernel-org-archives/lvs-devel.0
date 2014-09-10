From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] ipvsadm: do not truncate ipv6 members of v4 services
Date: Wed, 10 Sep 2014 09:00:20 +0200
Message-ID: <20140910090020.1144a8b5@redhat.com>
References: <1410329806-1840-1-git-send-email-agartrell@fb.com>
	<alpine.LFD.2.11.1409100930500.22206@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1409100930500.22206@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com, ps@fb.com, brouer@redhat.com


On Wed, 10 Sep 2014 09:38:35 +0300 (EEST) Julian Anastasov <ja@ssi.bg> wrote:

> 	Jesper, I think you can now push all recent
> changes to the ipvsadm tree. This includes:
>
> ipvsadm: specify real server address family to netlink socket
> by Alex, from August 29
> 
> ipvsadm: restrict different address family
> ipvsadm: allow different address family in connection listing
> by me, from August 30
> 
> and finally this patch.

Sound good! -- Just applied an pushed patches to:
 https://git.kernel.org/cgit/utils/kernel/ipvsadm/ipvsadm.git/

Thanks every one!
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
