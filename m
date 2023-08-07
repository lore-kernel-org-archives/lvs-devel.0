From: Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Mon, 7 Aug 2023 16:43:42 -0700
Message-ID: <ZNGBrkP7J2g/BAWV@bombadil.infradead.org>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org>
 <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
 <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
        MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=R7l6QScXv7U38OrlWS7Mcrb8Q93Tbo+TJ0PZi9bIVzI=; b=lvQhpYkugp8p+MnqK1ZwyEPyPV
        qQ13g/zVYcvPRrYd2noywzgnhct1y5FSUHLn9ld+CBTnhLURNvgr/bgoc4bC5EjlpBpGWWJSfX6T/
        Qmk68ZOOTeEEYcestzUADl5Dpi2gJuWSQGiqWBWdo7zHkuT9gtEQcp0EWL0J2TwWVfknB/pb1efBJ
        /qWuJAAvELKv3Gu45SonJbWc0VbDj+8+j0QZPdUmEmVKMoxo/rXWuGEKo/o2tIRBYi/rELO7VQcCa
        I8mjAfAkS2C8C5SdfIKOYZeY5S9V20FFyb9rMjgiCJ7HvitG7HyaaV+Ort6BR6cHisL1dXBl+Z9Mq
        S3J7uphA==;
Content-Disposition: inline
In-Reply-To: <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
Sender: Luis Chamberlain <mcgrof@infradead.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Maness <christopher.maness@gmail.com>
Cc: Alexander Aring <alex.aring@gmail.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, "D. Wythe" <alibuda@linux.alibaba.com>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Heiko Carstens <hca@linux.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Iurii Zaikin <yzaikin@google.com>, Jakub Kicinski <kuba@kernel.org>, Jan Karcher <jaka@linux.ibm.com>, Joel Granados <joel.granados@gmail.com>, Joel Granados <j.granados@samsung.com>, Joerg Reuter <jreuter@yaina.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Karsten Graul <k>

On Mon, Aug 07, 2023 at 04:00:49PM -0700, Chris Maness wrote:
> When are these likely to hit the mainline release code?

linux-next tomorrow. The first 7 patches are scheduled for mainline
as they were merged + tested without any hiccups. These last few patches
I'll wait and see. If nothing blows up on linux-next perhaps I'll
include them to Linux for mainline during the next merge window.

  Luis
