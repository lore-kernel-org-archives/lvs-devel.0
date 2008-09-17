From: "Julius Volz" <juliusv@google.com>
Subject: Should we move IPVS out of net/ipv4 now?
Date: Wed, 17 Sep 2008 15:00:11 +0200
Message-ID: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1221656412; bh=Gi5Vw2ez8Nw7I9s3RN+/h37g3fU=;
	h=DomainKey-Signature:Message-ID:Date:From:To:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Content-Disposition; b=arxy
	bPyLa4D4tgdi6C4UNvJesO0KTY7YzU23HpDbBoadc1VeZSp3VyudgC8YKJ0Il7+sH+c
	1CKxAhu+DVzY5MA==
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev@vger.kernel.org

Hi,

Since IPVS now does partial IPv6, should we finally move it from
"net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
long time ago, but that was before any of the actual v6 features, so
there was probably no interest.

Also, the tunables in /proc/sys/net/ipv4/vs/... apply to both v4 and
v6. Should we just duplicate them into /proc/sys/net/ipv6/vs? Or will
people be confused that setting a value in one directory changes the
value in the other and affects both IP versions?

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
