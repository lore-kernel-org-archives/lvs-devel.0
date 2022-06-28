From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH][next] treewide: uapi: Replace zero-length
 arrays with flexible-array members
Date: Tue, 28 Jun 2022 09:27:21 +0200
Message-ID: <CAMuHMdU27TG_rpd=WTRPRcY22A4j4aN-6d_8OmK2aNpX06G3ig@mail.gmail.com>
References: <20220627180432.GA136081@embeddedor>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Return-path: <intel-gfx-bounces@lists.freedesktop.org>
In-Reply-To: <20220627180432.GA136081@embeddedor>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/intel-gfx>
List-Post: <mailto:intel-gfx@lists.freedesktop.org>
List-Help: <mailto:intel-gfx-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/intel-gfx>,
 <mailto:intel-gfx-request@lists.freedesktop.org?subject=subscribe>
Errors-To: intel-gfx-bounces@lists.freedesktop.org
Sender: "Intel-gfx" <intel-gfx-bounces@lists.freedesktop.org>
Content-Type: text/plain; charset="utf-8"
To: "Gustavo A. R. Silva" <gustavoars@kernel.org>
Cc: nvdimm@lists.linux.dev, ALSA Development Mailing List <alsa-devel@alsa-project.org>, KVM list <kvm@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, target-devel <target-devel@vger.kernel.org>, MTD Maling List <linux-mtd@lists.infradead.org>, linux-hardening@vger.kernel.org, linux1394-devel@lists.sourceforge.net, linux-stm32@st-md-mailman.stormreply.com, linux-s390 <linux-s390@vger.kernel.org>, scsi <linux-scsi@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, lvs-devel@vger.kernel.org, coreteam@netfilter.org, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Kees Cook <keescook@chromium.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, linux-can@vger.kernel

Hi Gustavo,

Thanks for your patch!

On Mon, Jun 27, 2022 at 8:04 PM Gustavo A. R. Silva
<gustavoars@kernel.org> wrote:
> There is a regular need in the kernel to provide a way to declare
> having a dynamically sized set of trailing elements in a structure.
> Kernel code should always use =E2=80=9Cflexible array members=E2=80=9D[1]=
 for these
> cases. The older style of one-element or zero-length arrays should
> no longer be used[2].

These rules apply to the kernel, but uapi is not considered part of the
kernel, so different rules apply.  Uapi header files should work with
whatever compiler that can be used for compiling userspace.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
