From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/4] lpfc: reduce stack size with CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE
Date: Fri, 28 Jun 2019 14:37:47 +0200
Message-ID: <20190628123819.2785504-2-arnd@arndb.de>
References: <20190628123819.2785504-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20190628123819.2785504-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Kees Cook <keescook@chromium.org>, James Smart <james.smart@broadcom.com>, Dick Kennedy <dick.kennedy@broadcom.com>, "James E.J. Bottomley" <jejb@linux.ibm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>, Florian Schilhabel <florian.c.schilhabel@googlemail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "David S . Miller" <davem@davemloft.net>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, James Morris <jmorris@namei.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Hannes Reinecke <hare@suse.com>, Willy Tarreau <w@1wt.eu>, Silvio Cesare <silvio.cesare@gmail.com>

The lpfc_debug_dump_all_queues() function repeatedly calls into
lpfc_debug_dump_qe(), which has a temporary 128 byte buffer.
This was fine before the introduction of CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE
because each instance could occupy the same stack slot. However,
now they each get their own copy, which leads to a huge increase
in stack usage as seen from the compiler warning:

drivers/scsi/lpfc/lpfc_debugfs.c: In function 'lpfc_debug_dump_all_queues':
drivers/scsi/lpfc/lpfc_debugfs.c:6474:1: error: the frame size of 1712 bytes is larger than 100 bytes [-Werror=frame-larger-than=]

Avoid this by not marking lpfc_debug_dump_qe() as inline so the
compiler can choose to emit a static version of this function
when it's needed or otherwise silently drop it. As an added benefit,
not inlining multiple copies of this function means we save several
kilobytes of .text section, reducing the file size from 47kb to 43.

It is somewhat unusual to have a function that is static but not
inline in a header file, but this does not cause problems here
because it is only used by other inline functions. It would
however seem reasonable to move all the lpfc_debug_dump_* functions
into lpfc_debugfs.c and not mark them inline as a later cleanup.

Fixes: 81a56f6dcd20 ("gcc-plugins: structleak: Generalize to all variable types")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/scsi/lpfc/lpfc_debugfs.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/lpfc/lpfc_debugfs.h b/drivers/scsi/lpfc/lpfc_debugfs.h
index 2322ddb085c0..34070874616d 100644
--- a/drivers/scsi/lpfc/lpfc_debugfs.h
+++ b/drivers/scsi/lpfc/lpfc_debugfs.h
@@ -330,7 +330,7 @@ enum {
  * This function dumps an entry indexed by @idx from a queue specified by the
  * queue descriptor @q.
  **/
-static inline void
+static void
 lpfc_debug_dump_qe(struct lpfc_queue *q, uint32_t idx)
 {
 	char line_buf[LPFC_LBUF_SZ];
-- 
2.20.0

