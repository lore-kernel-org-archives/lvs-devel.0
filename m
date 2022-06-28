From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH][next] treewide: uapi: Replace zero-length arrays with
 flexible-array members
Date: Tue, 28 Jun 2022 10:36:51 -0300
Message-ID: <20220628133651.GO23621@ziepe.ca>
References: <20220627180432.GA136081@embeddedor>
 <6bc1e94c-ce1d-a074-7d0c-8dbe6ce22637@iogearbox.net>
 <20220628004052.GM23621@ziepe.ca>
 <20220628005825.GA161566@embeddedor>
 <20220628022129.GA8452@embeddedor>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <virtualization-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org 7B00B83EE3
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp1.osuosl.org 30A7E83EE0
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 11AE3408DE
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 92542408DB
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ziepe.ca; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=gN4ZNyT9GRZ46Vwx3CUzNgwGxKE3ptwelsb3O/2waMc=;
 b=SRPS2zIET11DP06FAnMANUW30rX+F+KLnmvgpItTZuHDiHMYbx191l+udZ0BIKVo+p
 DUqKNFcRnPxEdciA9v/rjMoUuUABeinU5a59o91m7mO0ei+LjGwfeqP1sFK6bST4r2Sc
 +kwNrequilw+r3whlSvEqjUrw7uEou8aBEv26lUqmckZs7QEO1gxqNAIdKmR6ixdoBBW
 VwXL+VitONeiHER4+6czyOuvux/gSa01CsajOGl6xQeKgTZdOU9/PF5ai6yeP3/8Na6A
 VkyCaiWAoLiX3IML+rZ/qAH9obhof6Stg3VEpk4n7D6sOfmWV6A4zI2itZ9nI+NyrBEn
 GAtg==
Content-Disposition: inline
In-Reply-To: <20220628022129.GA8452@embeddedor>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>, 
 <mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>, 
 <mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: virtualization-bounces@lists.linux-foundation.org
Sender: "Virtualization" <virtualization-bounces@lists.linux-foundation.org>
To: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Cc: nvdimm@lists.linux.dev, alsa-devel@alsa-project.org, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mips@vger.kernel.org, dm-devel@redhat.com, target-devel@vger.kernel.org, linux-mtd@lists.infradead.org, linux-hardening@vger.kernel.org, linux1394-devel@lists.sourceforge.net, linux-stm32@st-md-mailman.stormreply.com, linux-s390@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>, linux-rdma@vger.kernel.org, x86@kernel.org, kasan-dev@googlegroups.com, lvs-devel@vger.kernel.org, coreteam@netfilter.org, v9fs-developer@lists.sourceforge.net, Kees Cook <keescook@chromium.org>, intel-gfx@lists.freedesktop.org, linux-can@vger.kernel.org, linux-raid@vger.kernel.org, linux-m68k@lists.linux-m68k.org, virtualization@lists.linux-foundation.org, io-uring@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, linux-us

On Tue, Jun 28, 2022 at 04:21:29AM +0200, Gustavo A. R. Silva wrote:

> > > Though maybe we could just switch off -Wgnu-variable-sized-type-not-at-end  during configuration ?

> We need to think in a different strategy.

I think we will need to switch off the warning in userspace - this is
doable for rdma-core.

On the other hand, if the goal is to enable the array size check
compiler warning I would suggest focusing only on those structs that
actually hit that warning in the kernel. IIRC infiniband doesn't
trigger it because it just pointer casts the flex array to some other
struct.

It isn't actually an array it is a placeholder for a trailing
structure, so it is never indexed.

This is also why we hit the warning because the convient way for
userspace to compose the message is to squash the header and trailer
structs together in a super struct on the stack, then invoke the
ioctl.

Jason 
