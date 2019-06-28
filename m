From: James Smart <james.smart@broadcom.com>
Subject: Re: [PATCH 2/4] lpfc: reduce stack size with
 CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE
Date: Fri, 28 Jun 2019 11:57:22 -0700
Message-ID: <3027eebb-e49f-6db6-ae0a-39a61c0e34e1@broadcom.com>
References: <20190628123819.2785504-1-arnd@arndb.de>
 <20190628123819.2785504-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=broadcom.com; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=GEJr3AqvHre2EqiUp9wkeTIrlXFQndtx5Gxgp/CLC/Y=;
        b=XoArU2Aw8uy6yHzMzOQ8pchviB6L+RP4fgA/8H3T5PNGYyVaXqKQqTIwc7a4oy+fnV
         F1iR3tXMQ34FbQ+fE8PXhJfHqbNf+Sn8tcEf7KYCanV+dVUAQA5PC6ql/3/lkLjzI4Cv
         BT9bbsuFZ5wsJLWle1D+GKJmmk4aHobb+e2eY=
In-Reply-To: <20190628123819.2785504-2-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Arnd Bergmann <arnd@arndb.de>, Kees Cook <keescook@chromium.org>, Dick Kennedy <dick.kennedy@broadcom.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, Florian Schilhabel <florian.c.schilhabel@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "David S . Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, James Morris <jmorris@namei.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hannes Reinecke <hare@suse.com>, Willy Tarreau <w@1wt.eu>, Silvio Cesare <silvio.cesare@gmail.com>



On 6/28/2019 5:37 AM, Arnd Bergmann wrote:
> The lpfc_debug_dump_all_queues() function repeatedly calls into
> lpfc_debug_dump_qe(), which has a temporary 128 byte buffer.
> This was fine before the introduction of CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE
> because each instance could occupy the same stack slot. However,
> now they each get their own copy, which leads to a huge increase
> in stack usage as seen from the compiler warning:
>
> drivers/scsi/lpfc/lpfc_debugfs.c: In function 'lpfc_debug_dump_all_queues':
> drivers/scsi/lpfc/lpfc_debugfs.c:6474:1: error: the frame size of 1712 bytes is larger than 100 bytes [-Werror=frame-larger-than=]
>
> Avoid this by not marking lpfc_debug_dump_qe() as inline so the
> compiler can choose to emit a static version of this function
> when it's needed or otherwise silently drop it. As an added benefit,
> not inlining multiple copies of this function means we save several
> kilobytes of .text section, reducing the file size from 47kb to 43.
>
> It is somewhat unusual to have a function that is static but not
> inline in a header file, but this does not cause problems here
> because it is only used by other inline functions. It would
> however seem reasonable to move all the lpfc_debug_dump_* functions
> into lpfc_debugfs.c and not mark them inline as a later cleanup.

I agree with this cleanup.

>
> Fixes: 81a56f6dcd20 ("gcc-plugins: structleak: Generalize to all variable types")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>   drivers/scsi/lpfc/lpfc_debugfs.h | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
>

Reviewed-by: James Smart <james.smart@broadcom.com>

-- james

