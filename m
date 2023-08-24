From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH -stable,4.14.y,4.19.y 0/1] ipvs: backport 1b90af292e71 and 5310760af1d4
Date: Thu, 24 Aug 2023 14:53:53 +0300
Message-ID: <20230824115354.61669-1-ja@ssi.bg>
References: <2023082114-remix-cable-0852@gregkh>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <stable-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=ssi.bg; s=ink;
        t=1692878080; bh=qkt+qZ8EP4kk2R9+Z4BG5noU2/Z7WK3VK1joYnfj7fA=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References;
        b=DP03lgWg66shJQXn+/zy04/JD4C0WoP2lDRUy+l0BobCc3UbAa6Fc/lzkINnY54hb
         Fwyk5aXQoSBsW8D9cY/d7l6Zm1ifnVTZMmSfjwCJxfUADJYr3hd9Gab9CFaKORG0Yg
         HVoGJ1yUPhBnrik8LFE+3mlyFjAxU1uMA3H4f18w=
In-Reply-To: <2023082114-remix-cable-0852@gregkh>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: stable@vger.kernel.org
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>, netfilter-devel@vger.kernel.org, Junwei Hu <hujunwei4@huawei.com>, Sishuai Gong <sishuai.system@gmail.com>

	Hello,

	This patchset contains backport for
commit 1b90af292e71b20d03b837d39406acfbdc5d4b2a. It applies
to linux-4.14.y and linux-4.19.y and differs from original commit
for the zero/one values used for extra1/extra2.

	When applied, the concerned commit
5310760af1d4fbea1452bfc77db5f9a680f7ae47 can be cherry-picked and
it will apply cleanly on top of 1b90af292e71.

Junwei Hu (1):
  ipvs: Improve robustness to the ipvs sysctl

 net/netfilter/ipvs/ip_vs_ctl.c | 70 +++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 34 deletions(-)

-- 
2.41.0


