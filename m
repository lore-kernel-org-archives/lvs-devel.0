From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH trivial] net: Fix various misspellings of "connect"
Date: Thu, 24 Oct 2019 19:14:39 +0300
Message-ID: <874kzyqfww.fsf@kamboji.qca.qualcomm.com>
References: <20191024152323.29987-1-geert+renesas@glider.be>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
        s=default; t=1571933688;
        bh=5LYj+S7mUQpRFG78UNWcpu0TFawfTdvqUpL+Kysi69w=;
        h=From:To:Cc:Subject:References:Date:In-Reply-To:From;
        b=hrWNeIkToNDdVRdtpTlshKMIp37BiUqtnBsa0inqk3kgJbBJYuZoYulc+KvAIf9rc
         rWGXjdWX/Knm99607FydhcAcuincgwTM7Pnx0psbG2wP+dZDm2eJ32bhWSkDZr6XBe
         MzJkSv+DIrzri8haYWstUQ9nxRAfdcUYvPCFdFG8=
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
        s=default; t=1571933686;
        bh=5LYj+S7mUQpRFG78UNWcpu0TFawfTdvqUpL+Kysi69w=;
        h=From:To:Cc:Subject:References:Date:In-Reply-To:From;
        b=Q5EX7o8UOEsIEmJ98Y9SLgS044IficfMRDPf7VvWOvqSxHiA5pviytY7GK2fFtU6P
         4AVgW+dQ+9swtwtQu+Or3dfKYeL+kmq4IOwxYNfd28CUUSZBI37hYfJT+BXMyo0wlG
         ji+kcrlTq3lRLDp+MT7ApIpA416QkGjJkqsVkDN4=
In-Reply-To: <20191024152323.29987-1-geert+renesas@glider.be> (Geert
        Uytterhoeven's message of "Thu, 24 Oct 2019 17:23:23 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: "David S . Miller" <davem@davemloft.net>, Ping-Ke Shih <pkshih@realtek.com>, Johannes Berg <johannes@sipsolutions.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

Geert Uytterhoeven <geert+renesas@glider.be> writes:

> Fix misspellings of "disconnect", "disconnecting", "connections", and
> "disconnected".
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  drivers/net/wimax/i2400m/usb.c                      | 2 +-
>  drivers/net/wireless/realtek/rtlwifi/rtl8192se/hw.c | 4 ++--
>  include/net/cfg80211.h                              | 2 +-
>  net/netfilter/ipvs/ip_vs_ovf.c                      | 2 +-
>  net/wireless/reg.h                                  | 2 +-
>  5 files changed, 6 insertions(+), 6 deletions(-)

For the wireless:

Acked-by: Kalle Valo <kvalo@codeaurora.org>

-- 
https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
