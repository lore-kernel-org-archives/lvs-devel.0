From: patchwork-bot+netdevbpf@kernel.org
Subject: Re: [PATCH net v6 0/3] Insulate Kernel Space From SOCK_ADDR Hooks
Date: Sun, 01 Oct 2023 18:40:25 +0000
Message-ID: <169618562530.20334.3438760815048190740.git-patchwork-notify@kernel.org>
References: <20230926200505.2804266-1-jrife@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1696185625;
        bh=vHpYQw4Xo9ncTL+cTD5bhjtdjFWeRqIriCu/Ce16oc4=;
        h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
        b=BEstLtKJIXt0IJ4gCEvv4DRQRrPAiKpdLtX0LWl0eWl3Nty1flLkeAMAk6VoQ3hFH
         zfw2pT3j66ZWc4mAFtr0hI1r+/FdoaNS5LzyTt6pfQTwiVmIB3ytjv0Jx8v8IPwEBb
         Lswz85b/WEMSd+P5Aqfm8HJK4pxY7Vc3lDKxHO2ou4ct8H8qk6GPllQmsiRm14NXTE
         PExldMIYnTMvAOv5UWs9RqqO5bctrk+swoNCnH8Je1QlBthCz46pHYh+NRrdY+sVYa
         8FInmRSG0tvh+6NaOnjbWMJZ8lSCfrKmpZj7YuRXGfRFBRx+qMZRFTMMqhW2JbMr+k
         JgyencAyzITyw==
In-Reply-To: <20230926200505.2804266-1-jrife@google.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Jordan Rife <jrife@google.com>
Cc: davem@davemloft.net, edumazet@google.com, kuba@kernel.org, pabeni@redhat.com, willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org, dborkman@kernel.org, horms@verge.net.au, pablo@netfilter.org, kadlec@netfilter.org, fw@strlen.de, santosh.shilimkar@oracle.com, ast@kernel.org, rdna@fb.com, linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, ja@ssi.bg, lvs-devel@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net, daan.j.demeyer@gmail.com

Hello:

This series was applied to netdev/net.git (main)
by David S. Miller <davem@davemloft.net>:

On Tue, 26 Sep 2023 15:05:02 -0500 you wrote:
> ==OVERVIEW==
> 
> The sock_sendmsg(), kernel_connect(), and kernel_bind() functions
> provide kernel space equivalents to the sendmsg(), connect(), and bind()
> system calls.
> 
> When used in conjunction with BPF SOCK_ADDR hooks that rewrite the send,
> connect, or bind address, callers may observe that the address passed to
> the call is modified. This is a problem not just in theory, but in
> practice, with uninsulated calls to kernel_connect() causing issues with
> broken NFS and CIFS mounts.
> 
> [...]

Here is the summary with links:
  - [net,v6,1/3] net: replace calls to sock->ops->connect() with kernel_connect()
    https://git.kernel.org/netdev/net/c/26297b4ce1ce
  - [net,v6,2/3] net: prevent rewrite of msg_name and msg_namelen in sock_sendmsg()
    (no matching commit)
  - [net,v6,3/3] net: prevent address rewrite in kernel_bind()
    https://git.kernel.org/netdev/net/c/c889a99a21bf

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


