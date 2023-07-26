From: Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH 10/14] netfilter: Update to register_net_sysctl_sz
Date: Wed, 26 Jul 2023 11:01:19 -0700
Message-ID: <ZMFfb4bJ6neACe5X@bombadil.infradead.org>
References: <20230726140635.2059334-1-j.granados@samsung.com>
 <CGME20230726140706eucas1p1b11e5f0bd17f0de19af9608cbd8d17f3@eucas1p1.samsung.com>
 <20230726140635.2059334-11-j.granados@samsung.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
        MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=mOs0FbEX7U/JftVf/7w+izAt0GEtfD+who6ul2jmL1A=; b=Iln/whwi3yb0OCDfnbyBjMdx+m
        juFI59CritCNSyW6F5D0XpHC0iscqFmdZ00//lCiuYir0a6u4x+Trb0fDiT1I8lWJsP6oU29GK/FQ
        HnfImdfWz3d/FFVFAVn2c5NvOhMlPOV/jQ9Gw7gF/R+QQhgAxkPBg30gZGpfWe9e6F1g3T860ToDU
        3b3igthrZTDls6/w68U1gJwMhAvJIATJevMX85S2LJO5gw+sF1p7LDa7daV4DC/GaXuMpeYo9ezaB
        YVbkS848bTHFzserKKNJffxnqBuL9rIXky9EaSjRDnBy0AFCo9mO69kFKWdY6Q9jqUcRgtsOlJyZn
        kzcXs81A==;
Content-Disposition: inline
In-Reply-To: <20230726140635.2059334-11-j.granados@samsung.com>
Sender: Luis Chamberlain <mcgrof@infradead.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joel Granados <j.granados@samsung.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, Roopa Prabhu <roopa@nvidia.com>, Nikolay Aleksandrov <razor@blackwall.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, willy@infradead.org, keescook@chromium.org, josh@joshtriplett.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org

On Wed, Jul 26, 2023 at 04:06:30PM +0200, Joel Granados wrote:
> This is part of the effort to remove the sentinel (last empty) element
> from the ctl_table arrays. We update to the new function and pass it the
> array size. Care is taken to mirror the NULL assignments with a size of
> zero (for the unprivileged users)

Same in this commit, the "why" is missing and size impact, if any.

  Luis
