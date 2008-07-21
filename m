From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 0/2] IPVS: Add Generic Netlink configuration interface
Date: Mon, 21 Jul 2008 15:02:53 +0200
Message-ID: <1216645375-20410-1-git-send-email-juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1216645384; bh=i9YP0FXvHO7OXEC+rf7VLlX82WE=;
	h=DomainKey-Signature:From:To:Cc:Subject:Date:Message-Id:X-Mailer;
	b=aykAwCdiF4S/groTNdrGqErKlXdfTMc9yVkipGhcJQZY4yOfhmA0fZ2E9e6pyGuqp
	tdwTj6LLUD9ZOvZ7Sql2g==
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Cc: horms@verge.net.au, kaber@trash.net, davem@davemloft.net, tgraf@suug.ch, vbusam@google.com

This is the second version of the Generic Netlink interface for
IPVS. I integrated some comments from Thomas Graf, Patrick McHardy and
Yoshifuji Hideaki and changed a few things myself. The interface should
now follow existing Netlink conventions more closely and has been
tested without problems.

The two patches add a Generic Netlink interface to IPVS while keeping
the old get/setsockopt interface for userspace backwards compatibility.
The motivation for this is to have a more extensible interface for
future changes, such as the planned IPv6 support. ipvsadm is currently
being extended to support the new interface and features.

The ip_vs.h header change depends on this patch I sent previously:
"IPVS: Move userspace definitions to include/linux/ip_vs.h"
(this one looked good to Horms, can it go in?)

Julius
