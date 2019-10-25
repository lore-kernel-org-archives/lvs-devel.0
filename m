From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH trivial] net: Fix various misspellings of "connect"
Date: Fri, 25 Oct 2019 08:00:03 +0200
Message-ID: <20191025060000.GA3009@verge.net.au>
References: <20191024152323.29987-1-geert+renesas@glider.be>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20191024152323.29987-1-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Geert Uytterhoeven <geert+renesas@glider.be>
Cc: "David S . Miller" <davem@davemloft.net>, Ping-Ke Shih <pkshih@realtek.com>, Kalle Valo <kvalo@codeaurora.org>, Johannes Berg <johannes@sipsolutions.net>, Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 24, 2019 at 05:23:23PM +0200, Geert Uytterhoeven wrote:
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

Thanks Geert,

for the IPVS portion:

Acked-by: Simon Horman <horms@verge.net.au>

