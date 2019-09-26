From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH trivial 1/2] net: Fix Kconfig indentation
Date: Thu, 26 Sep 2019 08:56:02 +0200 (CEST)
Message-ID: <20190926.085602.2172736725970238315.davem@davemloft.net>
References: <20190923155243.6997-1-krzk@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190923155243.6997-1-krzk@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: Text/Plain; charset="us-ascii"
To: krzk@kernel.org
Cc: m.grzeschik@pengutronix.de, wg@grandegger.com, mkl@pengutronix.de, andrew@lunn.ch, f.fainelli@gmail.com, hkallweit1@gmail.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, trivial@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-can@vger.kernel.org, linux-rdma@vger.kernel.org, linux-wireless@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, lvs-devel@vger.kernel.org, rds-devel@oss.oracle.com

From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Mon, 23 Sep 2019 17:52:42 +0200

> Adjust indentation from spaces to tab (+optional two spaces) as in
> coding style with command like:
>     $ sed -e 's/^        /\t/' -i */Kconfig
> 
> Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>

Ok, I'll apply these to 'net'.
