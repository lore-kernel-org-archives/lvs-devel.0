From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH trivial 2/2] drivers: net: Fix Kconfig indentation
Date: Tue, 24 Sep 2019 10:03:05 +0300
Message-ID: <20190924070305.GP14368@unreal>
References: <20190923155243.6997-1-krzk@kernel.org>
 <20190923155243.6997-2-krzk@kernel.org>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569308588;
        bh=AlEW8CxXuFn8P/oDpAqEk3frXBsRLiuf+egkL9mACt8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=NgPhsXprAhfXfXBMPmhNi6zDCC8P+Lv1t1OJaBYYq/OuXI2l+wTr48atArBd4iujI
         pEiGSyKx2TzTQHYLZDzoFRzF7eIxparEi1i+IHrr5h2FzyssV4vjBmgrl3X4i81jMA
         Gpzm0UZN6E6YR5znnHJXZueTNcgVSqzF9xZTqB1c=
Content-Disposition: inline
In-Reply-To: <20190923155243.6997-2-krzk@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, Michael Grzeschik <m.grzeschik@pengutronix.de>, Wolfgang Grandegger <wg@grandegger.com>, Marc Kleine-Budde <mkl@pengutronix.de>, Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>, Heiner Kallweit <hkallweit1@gmail.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-can@vger.kernel.org, linux-rdma@vger.kernel.org, linux-wireless@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, lvs-devel@vger.kernel

On Mon, Sep 23, 2019 at 05:52:43PM +0200, Krzysztof Kozlowski wrote:
> Adjust indentation from spaces to tab (+optional two spaces) as in
> coding style with command like:
>     $ sed -e 's/^        /\t/' -i */Kconfig
>
> Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>

<--->

>  .../net/ethernet/mellanox/mlx5/core/Kconfig   |  36 +++---

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
