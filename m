Received: from smtpbgsg1.qq.com (smtpbgsg1.qq.com [54.254.200.92])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4320E28E3F;
	Mon, 14 Apr 2025 04:28:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=54.254.200.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1744604915; cv=none; b=tehnHW+4YDXGbOXxnQcPNOI7aaAkjz6TMlzCtH8AT4aHeNFojdbxMRlSJCAN6A93idMNT6OpY7XV6tw9YGqrQLVRc0UBC3wRvWfwEwwFaNb4sHMnoxOt7Wi90YpKDrIgYOt0J22Ak5jdPD0UlYy2A/TRWhEbMgUevM/notectjc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1744604915; c=relaxed/simple;
	bh=LZnUR7vmtdVSTSo6qFETKaD8UU1KgCEWRyr8qPadleE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=joOwyhUJEjY6CqsxEnAXJL5A5mO2LXYT79zmBL1K8/q526V7LEkMhAVQEM9UjfNA9jSEJpkkmZuEmEDfc/LOWwm7hVsF5D05zd5Gwl41CYIY+vrN7AVFvC799xnxIJMQyA2J3LgycIZDMyYEQVGX/JjR/RP09JENNJDVPC/cQGc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com; spf=pass smtp.mailfrom=uniontech.com; dkim=pass (1024-bit key) header.d=uniontech.com header.i=@uniontech.com header.b=dD3+9m1R; arc=none smtp.client-ip=54.254.200.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uniontech.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=uniontech.com header.i=@uniontech.com header.b="dD3+9m1R"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uniontech.com;
	s=onoh2408; t=1744604866;
	bh=CUo+WSAZNxdFKYjPSCBE4ce1w0JxS0K3qkF+MdMjaw8=;
	h=From:To:Subject:Date:Message-ID:MIME-Version;
	b=dD3+9m1RvEvw3uOakXHDtv4SPuquDW+XsXTbMkw4WyP/jxwlhVuMxeTclMMtpie/m
	 INsml8DlJJIERx1hLE9fcmDtnWzhkWRwmTZXqDXLDNtoE0XS4c+vIYeu9c4fUo5L4s
	 qo4dOlTqNpiPc96arVLk3sjdjf5OI8OVswbIKiig=
X-QQ-mid: bizesmtpip4t1744604822t17b86d
X-QQ-Originating-IP: 9EUIoungktXur6Ak3HAJ9BQt/09nZjDSBOqmFnfFsJk=
Received: from localhost.localdomain ( [localhost])
	by bizesmtp.qq.com (ESMTP) with 
	id ; Mon, 14 Apr 2025 12:26:59 +0800 (CST)
X-QQ-SSF: 0000000000000000000000000000000
X-QQ-GoodBg: 1
X-BIZMAIL-ID: 274253829898234873
EX-QQ-RecipientCnt: 20
From: WangYuli <wangyuli@uniontech.com>
To: wangyuli@uniontech.com
Cc: akpm@linux-foundation.org,
	guanwentao@uniontech.com,
	linux-kernel@vger.kernel.org,
	mingo@kernel.org,
	niecheng1@uniontech.com,
	tglx@linutronix.de,
	zhanjun@uniontech.com,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org
Subject: [PATCH v2 4/5] ipvs: ip_vs_conn_expire_now: Rename del_timer in comment
Date: Mon, 14 Apr 2025 12:26:28 +0800
Message-ID: <F1C0F449361FF57A+20250414042629.63019-4-wangyuli@uniontech.com>
X-Mailer: git-send-email 2.49.0
In-Reply-To: <37A1CE32D2AEA134+20250414042251.61846-1-wangyuli@uniontech.com>
References: <37A1CE32D2AEA134+20250414042251.61846-1-wangyuli@uniontech.com>
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-QQ-SENDSIZE: 520
Feedback-ID: bizesmtpip:uniontech.com:qybglogicsvrgz:qybglogicsvrgz8a-1
X-QQ-XMAILINFO: OMHTpzRlrft8gDeIaQEw9WPwIiw9JGvZCWC7H7kHYniHsG8TN9Psc+ql
	fPya3/UElyR9DVO1olGnHWz/O1mMoLKb+ebYMj39hhe4PXPGxsNdzYtCWsjPi+t5QK1pp0j
	QTL5rNp3XVByUnPbxIhmzcqQkZpPOCbJ15saaqF9v8YJc9WMD664zKZ2BdqDf7Amb/NDCHS
	EgaMxpFrzjXbVup/AUE/ltN8mdftuMqXU0a6wkiriOsLqUYP+x5olCxdsOaKcNeA/85RdrS
	ZQjamCWI3n0XkMGndeWKD6JeiQyt/8HMPDTJalOBMVTyQUmv20lX6agY0TpxH8QFijq3vIY
	azf0gJJ43riaXCXLUTwpwIa+NcXlxFu5y3upCxc66XUq+cpMXVJ73SQjyc6CN/uhU2afQBC
	VbIyw7WHvWTE6164N9kI13BCwwu2B2FYVW+hgzFRQ/0v/KF1SVPhdmydgmDQLXGCocmkEuV
	SucWpO65AZos6cTXkQEzJeeos8kuBTqaB2XlVGkbKnEBqsZ6/j3wUUi2+/el5zybC2GNg3S
	omeRRfenvTWO4fa/xUTOuLVafZL3udg6MvPxd/5v+YAcbqupMIxG51aUzDXjQT3UIk8mZXi
	ZFkwC+aPW0SlgUkdENBfQvCaMnwLgmOMDNaIKHO3Z/9slJpmKzMSziQ7Yu1tzEB1BG5BrMj
	9pO4K2uzPfTenp0Gp0iF8wy2LTWY6yGmv67OpH2G6lM5tVZJj8vu7zVfgOXG+3mYfytUpkK
	HU0sl7DxRrq4cd/d8jrLbtMO07n2eBZE5eHHBj7GWcpvB5221s44kQJnWgWTV06cmO/4hnD
	e3UBfBJCCUb7/rT1en1OveNfla8o05nRE0gPmQOfw2yCZ+/ui4ah7DzQYzhYZnM55xav/MR
	GBzoDp4S1/ik6n0nqLuYcER+ugR+CaOj4VOEZRYtrHRS9CurL4Bq4+ASfvZCFJJUYdHZLzh
	Ic7zyWWBvR2r0x9uVGnisEqfWp6fD35knF+licpO5OcTqJ369jV1/k06bUsbPQ7P65hLw9L
	vnc+Foa5A4bd/HF0rgMjsRXrMKFV0=
X-QQ-XMRINFO: NS+P29fieYNw95Bth2bWPxk=
X-QQ-RECHKSPAM: 0

Commit 8fa7292fee5c ("treewide: Switch/rename to timer_delete[_sync]()")
switched del_timer to timer_delete, but did not modify the comment for
ip_vs_conn_expire_now(). Now fix it.

Cc: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@netfilter.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jakub Kicinski <kuba@kernel.org>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org
Cc: lvs-devel@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: coreteam@netfilter.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: WangYuli <wangyuli@uniontech.com>
---
 net/netfilter/ipvs/ip_vs_conn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 8699944c0baf..ccc39c6557ee 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -926,7 +926,7 @@ static void ip_vs_conn_expire(struct timer_list *t)
 void ip_vs_conn_expire_now(struct ip_vs_conn *cp)
 {
 	/* Using mod_timer_pending will ensure the timer is not
-	 * modified after the final del_timer in ip_vs_conn_expire.
+	 * modified after the final timer_delete in ip_vs_conn_expire.
 	 */
 	if (timer_pending(&cp->timer) &&
 	    time_after(cp->timer.expires, jiffies))
-- 
2.49.0

