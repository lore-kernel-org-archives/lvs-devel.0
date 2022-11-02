From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] ipvs: use explicitly signed chars
Date: Wed, 2 Nov 2022 03:44:38 +0100
Message-ID: <CAHmME9phbAJEbogBVZqmmb+44_V--rG_L5hAZCWeJVJy6-W7ag@mail.gmail.com>
References: <20221026123216.1575440-1-Jason@zx2c4.com>
Mime-Version: 1.0
Return-path: <netdev-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=zx2c4.com; s=20210105;
        t=1667357091;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=UBDll3aYfc54ok2vGI+aLXjCxJBzqPNfmky2K1csXd8=;
        b=QABkUn6/Oy6XT6TEVj0zIC+t0OIaIi74m1DlLjhBC2UUC0vf6H2NixR2DkmiZJFVpxxB0L
        it7OVWJtXOS5RpjPqRhvapbKSIjYp27zXwKIO9++vCWDVWdw+cB63qydiMMkhDgmRIbXhp
        Cd+/vmigoMADd0ec/gewUBqXPVU+gc4=
In-Reply-To: <20221026123216.1575440-1-Jason@zx2c4.com>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, stable@vger.kernel.org, netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Hi Pablo,

On Wed, Oct 26, 2022 at 2:34 PM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> The `char` type with no explicit sign is sometimes signed and sometimes
> unsigned. This code will break on platforms such as arm, where char is
> unsigned. So mark it here as explicitly signed, so that the
> todrop_counter decrement and subsequent comparison is correct.
>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: stable@vger.kernel.org
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>

Wondering if you planned on taking this into nf.git for 6.1?

Thanks,
Jason
