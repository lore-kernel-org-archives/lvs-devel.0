From: Chris Maness <christopher.maness@gmail.com>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Mon, 7 Aug 2023 19:50:44 -0700
Message-ID: <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org> <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
 <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com> <ZNGBrkP7J2g/BAWV@bombadil.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev+bounces-25245-gl-netdev-2=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1691463055; x=1692067855;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=To5RXdgTZuuS1AHvSrlZPoAVtMBfYbQuZKe1V5PCHGU=;
        b=hk+jDZrl3g+o4sMGmZCabtN/5AnLtuwYSMj/gPgSP5jEYRltMDEp8gR1KR3PAoQdbl
         1mPD04e7QwuBYp8dQtUhan7IrsHCz9nRfLpKT2kV9/mlU+mh7iLzNzoUSrFPVWwipOD6
         q1TBPuDV4nRSRSBp4V/lOBEhKgMReru3RolSHSEN0f12SXGiqxPgWA4lemQjUrXgfP0b
         9eSMaS0Lrlh3Hp5R6eNkjFGOMxplIuqi6pgCBrEZ/rsfKVThX0JpHq6AykEIQJrm9ZkH
         +wvjvoi0OZeiAqnoiw+ZytKa3+4s6OOqLNTXelwoIk85Wm8mUEBMLgOG45iVyn8pij86
         aDKg==
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:netdev+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:netdev+unsubscribe@vger.kernel.org>
In-Reply-To: <ZNGBrkP7J2g/BAWV@bombadil.infradead.org>
Content-Type: text/plain; charset="windows-1252"
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Alexander Aring <alex.aring@gmail.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, "D. Wythe" <alibuda@linux.alibaba.com>, David Ahern <dsahern@kernel.org>, "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Florian Westphal <fw@strlen.de>, Heiko Carstens <hca@linux.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Iurii Zaikin <yzaikin@google.com>, Jakub Kicinski <kuba@kernel.org>, Jan Karcher <jaka@linux.ibm.com>, Joel Granados <joel.granados@gmail.com>, Joel Granados <j.granados@samsung.com>, Joerg Reuter <jreuter@yaina.de>, Jozsef Kadlecsik <kadlec@netfilter.org>, Julian Anastasov <ja@ssi.bg>, Karsten Graul <kgraul@linux.ibm.com>, Kees Cook <keescook@chromium.org>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Mat Martineau <martine>

I tried running the current mainline kernel (current Arch Linux) with
simple single MUX socket (ax0) using LinFBB.  I was a happy camper as
it seemed to work fine at first, then the system just slowed to a
crawl.  I am wondering if any of these patches are addressing this
behavior.  No kernel panic like before, but not what I was hoping for.
I have also tried sixpack, and that explodes instantly the last time I
have checked.   That goes all the way back to the v4 kernels.  v2 is
fine there.

73 de Chris KQ6UP

On Mon, Aug 7, 2023 at 4:43=E2=80=AFPM Luis Chamberlain <mcgrof@kernel.org>=
 wrote:
>
> On Mon, Aug 07, 2023 at 04:00:49PM -0700, Chris Maness wrote:
> > When are these likely to hit the mainline release code?
>
> linux-next tomorrow. The first 7 patches are scheduled for mainline
> as they were merged + tested without any hiccups. These last few patches
> I'll wait and see. If nothing blows up on linux-next perhaps I'll
> include them to Linux for mainline during the next merge window.
>
>   Luis



--=20
Thanks,
Chris Maness

