From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] ipvs: Lock socket before setting SK_CAN_REUSE
Date: Mon, 13 Jun 2016 20:18:23 -0700
Message-ID: <1465874303.7945.181.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
	 <1465868613-26146-5-git-send-email-quentin@armitage.org.uk>
	 <1465873924.7945.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kzYhMdz3GhARaD7BybyrgEnXWip4NkTg7fyW0RQiHd0=;
        b=TT/qWwMGiDCmucX088QkbhkofiPlEzgrsKHXMDBYXox7wDvivlFe8Ctlk8ms3aFXxS
         /e0CDKyBeR2VOQ6Nu1lqwJGfeYq0A70tS7TMddE3GR3Z4Q2QqfqdKV72A49lSQyDPA+B
         kbzpjXjIrZAEjN+4tW3BlVcw1DlFw4yCN+Ni/+fw1SuaqEQDn9O0z93Z77tsvV2RC1hc
         uKuFIhns00wtT99bZGrJEnNZFx2Vd7BUdn3mlOMmwFxLWIvO8pj4giCJToMCPFD6IVaD
         TSNLEFg0E/MYggH7U/2GqiIMj8ktzQd2XFeuqb2jXnzuGoiyhZeFpZUJIIFOFrklO8Cw
         xpWQ==
In-Reply-To: <1465873924.7945.180.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Quentin Armitage <quentin@armitage.org.uk>
Cc: Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Patrick McHardy <kaber@trash.net>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Mon, 2016-06-13 at 20:12 -0700, Eric Dumazet wrote:

> 
> Have you tested this patch ?

Hmm, please ignore this question ;)


