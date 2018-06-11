From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: allow PMTU exceptions to local routes
Date: Mon, 11 Jun 2018 14:17:35 -0700 (PDT)
Message-ID: <20180611.141735.517794163299833338.davem@davemloft.net>
References: <20180610230254.6347-1-ja@ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180610230254.6347-1-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: ja@ssi.bg
Cc: netdev@vger.kernel.org, kafai@fb.com, kernel-team@fb.com, lvs-devel@vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 11 Jun 2018 02:02:54 +0300

> IPVS setups with local client and remote tunnel server need
> to create exception for the local virtual IP. What we do is to
> change PMTU from 64KB (on "lo") to 1460 in the common case.
> 
> Suggested-by: Martin KaFai Lau <kafai@fb.com>
> Fixes: 45e4fd26683c ("ipv6: Only create RTF_CACHE routes after encountering pmtu exception")
> Fixes: 7343ff31ebf0 ("ipv6: Don't create clones of host routes.")
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied and queued up for -stable, thanks.
