From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] treewide: convert ISO_8859-1 text comments to utf-8
Date: Tue, 24 Jul 2018 17:13:20 -0700
Message-ID: <aa39b6d15f44555cb79d5ebdef74aeab19003d6a.camel@perches.com>
References: <20180724111600.4158975-1-arnd@arndb.de>
         <20180724140010.e24a9964fd340afe2d98a994@linux-foundation.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20180724140010.e24a9964fd340afe2d98a994@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>
Cc: Samuel Ortiz <sameo@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, Rob Herring <robh+dt@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Cameron <jic23@kernel.org>, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-iio@vger.kernel.org, linux-pm@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org

On Tue, 2018-07-24 at 14:00 -0700, Andrew Morton wrote:
> On Tue, 24 Jul 2018 13:13:25 +0200 Arnd Bergmann <arnd@arndb.de> wrote:
> > Almost all files in the kernel are either plain text or UTF-8
> > encoded. A couple however are ISO_8859-1, usually just a few
> > characters in a C comments, for historic reasons.
> > This converts them all to UTF-8 for consistency.
[]
> Will we be getting a checkpatch rule to keep things this way?

How would that be done?
