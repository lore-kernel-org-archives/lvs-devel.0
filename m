From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH 3/4] staging: rtl8712: reduce stack usage, again
Date: Fri, 28 Jun 2019 15:52:03 -0400
Message-ID: <CA+FuTSdL=GwjhbERsePAJfbakgEQZb7X51UHw=+4R9dJD3JD4A@mail.gmail.com>
References: <20190628123819.2785504-1-arnd@arndb.de> <20190628123819.2785504-3-arnd@arndb.de>
Mime-Version: 1.0
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/Zbt8t4OGSrBZUltQdpu2XfV4/PLifVH/Z0A6OyR0+8=;
        b=bsREio19ZCYiktCkIASujl5tmzasz+I6GbX0QwjW1yWtrPHLtl8F72d/tP0OV718gu
         JhET9fkvZSnspuxgKrEOx/1kP1SYjQ7fj0fI/XoKoCGyk+qi6UDO6wRJo+hNRVYcyyxq
         0JSncshPTPt64doooXNY6ma4/ktV2ka0yVK/xrE/yAYCFGpIjfHmlQ4eCCCi+mJeJUsc
         8W4PI0vw66GNUmY1JGqXcSHa2CiCZHRkpxNiXv/kZ+fttkGp4qs1PP7G81iPFP6xFUG7
         n7G6MbZWqfBIpLiVXTzG3xd/E7GrLNqS/TCCUVcsr/qDjsGrDy2eGI721OOsI6wgTV9h
         S/yg==
In-Reply-To: <20190628123819.2785504-3-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Kees Cook <keescook@chromium.org>, Larry Finger <Larry.Finger@lwfinger.net>, Florian Schilhabel <florian.c.schilhabel@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Smart <james.smart@broadcom.com>, Dick Kennedy <dick.kennedy@broadcom.com>, "James E . J . Bottomley" <jejb@linux.ibm.com>, "Martin K . Petersen" <martin.petersen@oracle.com>, "David S . Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, James Morris <jmorris@namei.org>, linux-scsi@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, Network Development <netdev@vger.kernel.org>, lvs-devel@vger.kernel.org

On Fri, Jun 28, 2019 at 8:41 AM Arnd Bergmann <arnd@arndb.de> wrote:
>
> An earlier patch I sent reduced the stack usage enough to get
> below the warning limit, and I could show this was safe, but with
> GCC_PLUGIN_STRUCTLEAK_BYREF_ALL, it gets worse again because large stack
> variables in the same function no longer overlap:
>
> drivers/staging/rtl8712/rtl871x_ioctl_linux.c: In function 'translate_scan.isra.2':
> drivers/staging/rtl8712/rtl871x_ioctl_linux.c:322:1: error: the frame size of 1200 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
>
> Split out the largest two blocks in the affected function into two
> separate functions and mark those noinline_for_stack.
>
> Fixes: 8c5af16f7953 ("staging: rtl8712: reduce stack usage")
> Fixes: 81a56f6dcd20 ("gcc-plugins: structleak: Generalize to all variable types")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Willem de Bruijn <willemb@google.com>
