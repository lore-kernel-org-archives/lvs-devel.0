From: patchwork-bot+netdevbpf@kernel.org
Subject: Re: [PATCH net-next] genetlink: start to validate reserved header
 bytes
Date: Mon, 29 Aug 2022 12:10:17 +0000
Message-ID: <166177501728.22813.10790787483082655487.git-patchwork-notify@kernel.org>
References: <20220825001830.1911524-1-kuba@kernel.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <wireguard-bounces@lists.zx2c4.com>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1661775017;
 bh=fK7S2U9FH3Mh1H4KPhuYrCAu21172KjX+5QYn8bZxhw=;
 h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
 b=TBIvehqlXAnaUEIBMGrGtucuAxZHCjYUbH9gZTzp39B5ATUAioe8WO3EhAjb3uXxe
 dMkxYY6hb+WC6eHZyS/cPa8r2CKTI01EB9MGyg1IsF1/oZT7KJghqNmyKNC9XH8ves
 Cj3pIf4EmX/G+vS/jKdpHZhOleUGsARHnbS9xEcHQZhYvclYHJsMAatPyh4hKIzTRv
 ajwmDjfIKqrpsF4i7DFIPFPAdyZsb0nMzw3IdNk/hNCLbimS7UVtlTLrinQs2UaKDw
 YTwmujROS5OWbAtqbFtveKef90uGKF6IuQSib+pIDDHdy0cvO/DcGODQekO/LzgUrc
 qkbrfSs4DNb4A==
In-Reply-To: <20220825001830.1911524-1-kuba@kernel.org>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <https://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
Content-Type: text/plain; charset="us-ascii"
To: Jakub Kicinski <kuba@kernel.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com, pabeni@redhat.com, jiri@resnulli.us, johannes@sipsolutions.net, linux-block@vger.kernel.org, osmocom-net-gprs@lists.osmocom.org, linux-wpan@vger.kernel.org, wireguard@lists.zx2c4.com, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-pm@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-cifs@vger.kernel.org, cluster-devel@redhat.com, mptcp@lists.linux.dev, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-security-module@vger.kernel.org, dev@openvswitch.org, linux-s390@vger.kernel.org, tipc-discussion@lists.sourceforge.net

Hello:

This patch was applied to netdev/net-next.git (master)
by David S. Miller <davem@davemloft.net>:

On Wed, 24 Aug 2022 17:18:30 -0700 you wrote:
> We had historically not checked that genlmsghdr.reserved
> is 0 on input which prevents us from using those precious
> bytes in the future.
> 
> One use case would be to extend the cmd field, which is
> currently just 8 bits wide and 256 is not a lot of commands
> for some core families.
> 
> [...]

Here is the summary with links:
  - [net-next] genetlink: start to validate reserved header bytes
    https://git.kernel.org/netdev/net-next/c/9c5d03d36251

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


