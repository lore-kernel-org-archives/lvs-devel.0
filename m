From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: [PATCH 2/4] lpfc: reduce stack size with
 CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE
Date: Thu, 11 Jul 2019 20:47:03 -0400
Message-ID: <yq1y3146pvc.fsf@oracle.com>
References: <20190628123819.2785504-1-arnd@arndb.de>
 <20190628123819.2785504-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com;
 h=to : cc : subject :
 from : references : date : in-reply-to : message-id : mime-version :
 content-type; s=corp-2018-07-02;
 bh=bswtM7KXfcTUrZa5tnJd6JLuh5yaxIc3HYQdk3Zuwr4=;
 b=QkEPqMp3mKHL42qF1Uaya2p5wJUkj3FO2QR4290uZjskPuH+45kpwJstRfLq2CQZsHXI
 bGvmrTEyFoUgSvLt9UqzWx7zuKq7gXPjoHJOqOB0OAWocwzVyE1jI5VIB2qLUVXOLTb1
 4MoD99TdxTY0/Md8hMz/ROHW3oDkPYr5AA+HrV0/VUqyykGXJH0uy+ZwC0SE6Oyxg0CI
 k6XtjbOE5Z3qGpSgkbdih4M3+q5Dl7s00OOj1iOH7Vyd09uDepWKW+k/jFw9uxUfLhJQ
 J1oZl4Ro0Zzn3tcGseuiYkmMIrHIitgN27aZoCxwFCHhGWunD9ZG7RQtqLkGTv4rsDw4 AQ== 
In-Reply-To: <20190628123819.2785504-2-arnd@arndb.de> (Arnd Bergmann's message
 of "Fri, 28 Jun 2019 14:37:47 +0200")
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>, 
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>, 
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: James Morris <jmorris@namei.org>, devel@driverdev.osuosl.org, Hannes Reinecke <hare@suse.com>, linux-scsi@vger.kernel.org, James Smart <james.smart@broadcom.com>, lvs-devel@vger.kernel.org, Julian Anastasov <ja@ssi.bg>, coreteam@netfilter.org, Pablo Neira Ayuso <pablo@netfilter.org>, Wensong Zhang <wensong@linux-vs.org>, Dick Kennedy <dick.kennedy@broadcom.com>, Kees Cook <keescook@chromium.org>, "James E.J. Bottomley" <jejb@linux.ibm.com>, Silvio Cesare <silvio.cesare@gmail.com>, Simon Horman <horms@verge.net.au>, Florian Schilhabel <florian.c.schilhabel@googlemail.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Willy Tarreau <w@1wt.eu>, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Larr


Arnd,

> The lpfc_debug_dump_all_queues() function repeatedly calls into
> lpfc_debug_dump_qe(), which has a temporary 128 byte buffer.  This was
> fine before the introduction of CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE
> because each instance could occupy the same stack slot. However, now
> they each get their own copy, which leads to a huge increase in stack
> usage as seen from the compiler warning:

Applied to 5.3/scsi-fixes. Thank you!

-- 
Martin K. Petersen	Oracle Linux Engineering
