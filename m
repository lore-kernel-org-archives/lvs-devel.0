From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH trivial 2/2] drivers: net: Fix Kconfig indentation
Date: Tue, 24 Sep 2019 08:15:39 +0300
Message-ID: <87sgomi8as.fsf@tynnyri.adurom.net>
References: <20190923155243.6997-1-krzk@kernel.org>
        <20190923155243.6997-2-krzk@kernel.org>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
        s=default; t=1569302147;
        bh=azdN6vc/PGfI2bjrfNHt+vK3hA51rRmp/zu9UwVEnFE=;
        h=From:To:Cc:Subject:References:Date:In-Reply-To:From;
        b=OLBplSJ8QK2fuDQ89srMfDYzbHh19cEyYIPeEsii4HRtIELHAPm2/Bj4HjIWZXbrz
         /ghU6UC7s7RGXH9PaTA2M7cO0Y+Tl1Tpz4nk04oTdOYa9q6gh8IfvMgAhybAQw24qA
         +MsumvlYAN0nGHMUT7XPSltgWncFxCom6omq3DHw=
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
        s=default; t=1569302146;
        bh=azdN6vc/PGfI2bjrfNHt+vK3hA51rRmp/zu9UwVEnFE=;
        h=From:To:Cc:Subject:References:Date:In-Reply-To:From;
        b=V0LrSJ65dpf3rFn2VjpBmfRFfW6ofjXym1S9bUV43cIfh1B+Izf9IeMywVs7MWDvQ
         Q4eVfHhYpjXfey9K+PrTenhrts+tzG6/7DcQlcBpDeIdqCt24Fw+fYZPsGUAXoDwsn
         B9wbiz9mXwVc2iXDjEl8E1xHTX6aJcLeBzwEzFvY=
In-Reply-To: <20190923155243.6997-2-krzk@kernel.org> (Krzysztof Kozlowski's
        message of "Mon, 23 Sep 2019 17:52:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Krzysztof Kozlowski <krzk@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, Michael Grzeschik <m.grzeschik@pengutronix.de>, Wolfgang Grandegger <wg@grandegger.com>, Marc Kleine-Budde <mkl@pengutronix.de>, Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>, Heiner Kallweit <hkallweit1@gmail.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-can@vger.kernel.org, linux-rdma@vger.kernel.org, linux-wireless@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, lvs-devel@vger.kernel

Krzysztof Kozlowski <krzk@kernel.org> writes:

> Adjust indentation from spaces to tab (+optional two spaces) as in
> coding style with command like:
>     $ sed -e 's/^        /\t/' -i */Kconfig
>
> Signed-off-by: Krzysztof Kozlowski <krzk@kernel.org>

[...]

>  drivers/net/wireless/ath/Kconfig              |   2 +-
>  drivers/net/wireless/ath/ar5523/Kconfig       |   4 +-
>  drivers/net/wireless/ath/ath6kl/Kconfig       |   2 +-
>  drivers/net/wireless/ath/ath9k/Kconfig        |   2 +-
>  drivers/net/wireless/ath/carl9170/Kconfig     |   6 +-
>  drivers/net/wireless/atmel/Kconfig            |  32 ++---
>  drivers/net/wireless/intel/ipw2x00/Kconfig    | 116 +++++++++---------
>  drivers/net/wireless/intel/iwlegacy/Kconfig   |   6 +-
>  drivers/net/wireless/intel/iwlwifi/Kconfig    |   6 +-
>  drivers/net/wireless/ralink/rt2x00/Kconfig    |  24 ++--

I hope this goes through net or net-next, less chances of conflits then.

Acked-by: Kalle Valo <kvalo@codeaurora.org>

-- 
https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
