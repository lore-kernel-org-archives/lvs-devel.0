From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: Fix space before '[' error.
Date: Mon, 31 Jul 2017 10:15:49 +0200
Message-ID: <20170731081549.GC17242@verge.net.au>
References: <3b2fae111371a2abd12d6838e825452a3c9bd4fa.1501397734.git.arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=verge.net.au; s=mail;
        t=1501488967; bh=SwolE+7zCi7LrOYjLK+AV/Y6j4W3ZxnMVXy0uihA8Pw=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=FE/MVM5x8cSijrOKpyFdOpra1dYrUdbFgNY04WvFrfwZtiRlzCPCplkI6xHvtOMBb
         73CcgGk9DZYTpQGpZaLsb0PW3rfLAp5OUJDPdCaE08rezG3hW5i2Z7hGGWeDvQQcp+
         9JHy6tOvDH5QQstiGpn0JQ5nn4aqHw4QrHW7fN8E=
Content-Disposition: inline
In-Reply-To: <3b2fae111371a2abd12d6838e825452a3c9bd4fa.1501397734.git.arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org, kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.ne, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org

On Sun, Jul 30, 2017 at 12:29:25PM +0530, Arvind Yadav wrote:
> Fix checkpatch.pl error:
> ERROR: space prohibited before open square bracket '['.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Thanks, applied for v4.14.
