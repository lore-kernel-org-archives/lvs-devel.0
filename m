Received: from azure-sdnproxy.icoremail.net (azure-sdnproxy.icoremail.net [207.46.229.174])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 3B76F42DA30;
	Fri, 31 Jul 2026 14:28:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=207.46.229.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785508124; cv=none; b=An3/caZMav7ZsdpzG6hu9ZVaygTdQW+xbSPirojJMksLuVFqzitNoeNyd1sf8fJmn7Vy9VUXmiuoYwsc1EWcxlEabgfgoQkC/IkyE904Gzjl6aftqhd1HRUhQf1AAU4XKAD2gla6dxV/79/KLwrfs1QNHTJhtELYX3k1PzrK55c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785508124; c=relaxed/simple;
	bh=xxGXXaHnsoofIC2ydDID8htJYXWEjAi8DfUzCD7vX5A=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Iru/7aUAEErpdK8g4AuLU0FZBilDrYHFuo9x1miT15v9+xmythy9vQs8rN94LKhS248BpExk0Jg0c3Be8Oq+gIDZdCEy3ID9H0bUhC3ru4AN9VepuDEBUswivG/YJE8GTRGqxoXDUXbI/aniw5YGpa+pYSfzYtMFkorLwfnfEps=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn; dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b=lvNbCRhO; arc=none smtp.client-ip=207.46.229.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mails.tsinghua.edu.cn
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=mails.tsinghua.edu.cn header.i=@mails.tsinghua.edu.cn header.b="lvNbCRhO"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=mails.tsinghua.edu.cn; s=dkim; h=Received:From:To:Cc:Subject:
	Date:Message-ID:MIME-Version:Content-Transfer-Encoding; bh=mLGso
	flB7nEpHez+1E+91ZwAVc1VU9UYhCn9iDvCylQ=; b=lvNbCRhORkXYjDG5YJk5v
	WeFv1Q2Asdzh09ibfQABp6O5eB85xe4lI6IHy/fDzWc8fwsb8sjaroBGOeKs/MIi
	Q5/9R64w8c2ex75SmYZxH/h6o9WmoNg9r2uCX0VhuLDeazXsASQK1BiqdjNAhoi8
	9R31VXy32rrcs0IorSGKVs=
Received: from localhost.localdomain (unknown [106.111.19.240])
	by web1 (Coremail) with SMTP id yAQGZQAXuMfosGxqWfTeAA--.54054S2;
	Fri, 31 Jul 2026 22:27:54 +0800 (CST)
From: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>
To: David Ahern <dsahern@kernel.org>,
	Ido Schimmel <idosch@nvidia.com>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	"David S . Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>,
	Phil Sutter <phil@nwl.cc>
Cc: Yizhou Zhao <zhaoyz24@mails.tsinghua.edu.cn>,
	netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org,
	stable@vger.kernel.org,
	Yuxiang Yang <yangyx22@mails.tsinghua.edu.cn>,
	Ao Wang <wangao@seu.edu.cn>,
	Xuewei Feng <fengxw06@126.com>,
	Qi Li <qli01@tsinghua.edu.cn>,
	Ke Xu <xuke@tsinghua.edu.cn>
Subject: [PATCH nf v4 0/3] ipvs: fix destination overload state updates
Date: Fri, 31 Jul 2026 22:27:40 +0800
Message-ID: <20260731142748.56545-1-zhaoyz24@mails.tsinghua.edu.cn>
X-Mailer: git-send-email 2.46.2
Precedence: bulk
X-Mailing-List: lvs-devel@vger.kernel.org
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:lvs-devel+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:lvs-devel+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:yAQGZQAXuMfosGxqWfTeAA--.54054S2
X-Coremail-Antispam: 1UD129KBjvJXoW7WF48CF4rJw4Dur4UuF4Uurg_yoW8ZFW5pF
	ZIka4fX34UJr9xKrsxGayxCrW5Ka1rCrW7ur9xKryfA34UZF45tw4Sy3yjya4rZrn3Kry5
	tF90g3yUCwn8A3DanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9q1xkIjI8I6I8E6xAIw20EY4v20xvaj40_Wr0E3s1l8cAvFVAK
	0II2c7xJM28CjxkF64kEwVA0rcxSw2x7M28EF7xvwVC0I7IYx2IY67AKxVWUCVW8JwA2z4
	x0Y4vE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwA2z4x0Y4vEx4A2jsIE14v26rxl6s0DM28E
	F7xvwVC2z280aVCY1x0267AKxVW0oVCq3wAac4AC62xK8xCEY4vEwIxC4wAS0I0E0xvYzx
	vE52x082IY62kv0487Mc02F40EFcxC0VAKzVAqx4xG6I80ewAv7VCjz48v1sIEY20_GrWk
	Jr1UJwAm72CE4IkC6x0Yz7v_Jr0_Gr1lF7xvr2IYc2Ij64vIr41lF7I21c0EjII2zVCS5c
	I20VAGYxC7M4IIrI8v6xkF7I0E8cxan2IY04v7MxkF7I0En4kS14v26r4a6rW5MxkIecxE
	wVAFwVW5XwCF04k20xvY0x0EwIxGrwCF04k20xvE74AGY7Cv6cx26r4rKr1UJr1l4I8I3I
	0E4IkC6x0Yz7v_Jr0_Gr1lx2IqxVAqx4xG67AKxVWUJVWUGwC20s026x8GjcxK67AKxVWU
	GVWUWwC2zVAF1VAY17CE14v26r4a6rW5MIIYrxkI7VAKI48JMIIF0xvE2Ix0cI8IcVAFwI
	0_Jr0_JF4lIxAIcVC0I7IYx2IY6xkF7I0E14v26r4j6F4UMIIF0xvE42xK8VAvwI8IcIk0
	rVWUJVWUCwCI42IY6I8E87Iv67AKxVWUJVW8JwCI42IY6I8E87Iv6xkF7I0E14v26r4j6r
	4UJbIYCTnIWIevJa73UjIFyTuYvjfUw9a9DUUUU
X-CM-SenderInfo: 52kd05r2suqzpdlo2hxwvl0wxkxdhvlgxou0/1tbiAgQFAWprz6HfCgAAs4

IPVS schedulers read destination overload state while connection accounting
and destination configuration can update it concurrently.

The first patch adds a single total connection counter. The second patch
uses it to identify threshold crossings precisely, and updates OVERLOAD at
the crossings and on a threshold edit under dst_lock. The third patch moves
configuration-controlled AVAILABLE to a separate cflags word, so it cannot
clobber OVERLOAD through an unrelated read-modify-write update.

Readers can still observe stale destination state. This series does not
provide a cross-field consistent snapshot.

Changes in v4:
- Add the total connection counter and threshold-crossing overload updates.
- Update OVERLOAD under dst_lock at threshold crossings and destination edits.
- Keep OVERLOAD in dest->flags; drop the flags2/bitops approach.
- Move AVAILABLE to the separate cflags word, avoiding RMW interference
  between availability and overload updates.
- Link to v3: https://lore.kernel.org/netfilter-devel/cover.1783931964.git.zhaoyz24@mails.tsinghua.edu.cn/

Julian Anastasov (2):
  ipvs: add totalconns for dest
  ipvs: properly update the overload flag on dest edit

Yizhou Zhao (1):
  ipvs: separate destination availability state

 include/net/ip_vs.h                   | 27 +++++++--
 include/uapi/linux/ip_vs.h            |  6 --
 net/netfilter/ipvs/ip_vs_conn.c       | 45 +++++----------
 net/netfilter/ipvs/ip_vs_core.c       |  6 +-
 net/netfilter/ipvs/ip_vs_ctl.c        | 81 ++++++++++++++++++++++-----
 net/netfilter/ipvs/ip_vs_dh.c         |  4 +-
 net/netfilter/ipvs/ip_vs_lblc.c       |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c      |  8 +--
 net/netfilter/ipvs/ip_vs_lc.c         |  4 +-
 net/netfilter/ipvs/ip_vs_proto_sctp.c |  2 -
 net/netfilter/ipvs/ip_vs_proto_tcp.c  |  2 -
 net/netfilter/ipvs/ip_vs_sync.c       |  7 +--
 net/netfilter/ipvs/ip_vs_xmit.c       |  4 +-
 13 files changed, 118 insertions(+), 80 deletions(-)


base-commit: 2195424c3da2ef1829a63b807e3a900a90e57d85
-- 
2.34.1

