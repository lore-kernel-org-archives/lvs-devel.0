From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: use explicitly signed chars
Date: Wed, 2 Nov 2022 09:26:52 +0100
Message-ID: <Y2IpzHKuRmDA++dO@salvia>
References: <20221026123216.1575440-1-Jason@zx2c4.com>
Mime-Version: 1.0
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20221026123216.1575440-1-Jason@zx2c4.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, stable@vger.kernel.org

On Wed, Oct 26, 2022 at 02:32:16PM +0200, Jason A. Donenfeld wrote:
> The `char` type with no explicit sign is sometimes signed and sometimes
> unsigned. This code will break on platforms such as arm, where char is
> unsigned. So mark it here as explicitly signed, so that the
> todrop_counter decrement and subsequent comparison is correct.

Applied, thanks
