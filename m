From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Add missing options to ipvsadm(8)
Date: Thu, 5 Dec 2019 13:47:22 +0100
Message-ID: <20191205134722.128a9c15@carbon>
References: <1564656793.3546.64.camel@armitage.org.uk>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1575550053;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	content-transfer-encoding:content-transfer-encoding:
	in-reply-to:in-reply-to:references:references;
	bh=dCSP+OWY5s+EVxPlUvbauvM3zknf/JnJy1iXOn3yG3Q=;
	b=DarjII+4eX5lzlHqCHlyaqvVFkD7btWoRZfhx5y5dw8RhZ8/OBEQCEusqn84bxu8vZQSnx
	BGh+2dIBSicW603KCN1WseJq4RbbC88cBwCmKRdzajiUVvezq0fMl262KYUHouVvEouVMk
	qb8ILffaAXpzTtIvha5QOU1grnhNk84=
In-Reply-To: <1564656793.3546.64.camel@armitage.org.uk>
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
Cc: lvs-users@linuxvirtualserver.org, Inju Song <inju.song@navercorp.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, brouer@redhat.com

On Thu, 01 Aug 2019 11:53:13 +0100
Quentin Armitage <quentin@armitage.org.uk> wrote:

> Quentin Armitage (2):
>   Add --pe sip option in ipvsadm(8) man page
>   In ipvsadm(8) add using nft or an eBPF program to set a packet mark
> 
>  ipvsadm.8 | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)

This patchset is now applied to ipvsadm kernel.org git tree.
Sorry for not doing this sooner.

https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=e904a8cd1d7712
https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=089387716f0252

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

