From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/4] treewide: convert ISO_8859-1 text comments to utf-8
Date: Wed, 25 Jul 2018 08:33:47 -0700
Message-ID: <0fa2951559a9618c635d5a1fc6d4e32a5b795826.camel@perches.com>
References: <20180724111600.4158975-1-arnd@arndb.de>
         <20180724140010.e24a9964fd340afe2d98a994@linux-foundation.org>
         <aa39b6d15f44555cb79d5ebdef74aeab19003d6a.camel@perches.com>
         <20180724175531.75276cf4e539124aa9e27177@linux-foundation.org>
         <CAK8P3a3tOuP1FVS7oD1UhO5s4C+fLkL8VT3eCpRnSxBZxKzf6A@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK8P3a3tOuP1FVS7oD1UhO5s4C+fLkL8VT3eCpRnSxBZxKzf6A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>, Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, DTML <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux ARM <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linuxppc-dev <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux PM list <linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org

On Wed, 2018-07-25 at 15:12 +0200, Arnd Bergmann wrote:
> tools/perf/tests/.gitignore:
>                             LLVM byte-codes, uncompressed
> On Wed, Jul 25, 2018 at 2:55 AM, Andrew Morton
> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > On Tue, 24 Jul 2018 17:13:20 -0700 Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > 
> > > On Tue, 2018-07-24 at 14:00 -0700, Andrew Morton wrote:
> > > > On Tue, 24 Jul 2018 13:13:25 +0200 Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> > > > > Almost all files in the kernel are either plain text or UTF-8
> > > > > encoded. A couple however are ISO_8859-1, usually just a few
> > > > > characters in a C comments, for historic reasons.
> > > > > This converts them all to UTF-8 for consistency.
> > > 
> > > []
> > > > Will we be getting a checkpatch rule to keep things this way?
> > > 
> > > How would that be done?
> > 
> > I'm using this, seems to work.
> > 
> >         if ! file $p | grep -q -P ", ASCII text|, UTF-8 Unicode text"
> >         then
> >                 echo $p: weird charset
> >         fi
> 
> There are a couple of files that my version of 'find' incorrectly identified as
> something completely different, like:
> 
> Documentation/devicetree/bindings/pinctrl/pinctrl-sx150x.txt:
>             SemOne archive data
> Documentation/devicetree/bindings/rtc/epson,rtc7301.txt:
>             Microsoft Document Imaging Format
> Documentation/filesystems/nfs/pnfs-block-server.txt:
>             PPMN archive data
> arch/arm/boot/dts/bcm283x-rpi-usb-host.dtsi:
>         Sendmail frozen configuration  - version = "host";
> Documentation/networking/segmentation-offloads.txt:
>         StuffIt Deluxe Segment (data) : gmentation Offloads in the
> Linux Networking Stack
> arch/sparc/include/asm/visasm.h:                              SAS 7+
> arch/xtensa/kernel/setup.c:                                         ,
> init=0x454c, stat=0x090a, dev=0x2009, bas=0x2020
> drivers/cpufreq/powernow-k8.c:
> TI-XX Graphing Calculator (FLASH)
> tools/testing/selftests/net/forwarding/tc_shblocks.sh:
>                             Minix filesystem, V2 (big endian)
> tools/perf/tests/.gitignore:
>                             LLVM byte-codes, uncompressed
> 
> All of the above seem to be valid ASCII or UTF-8 files, so the check
> above will lead
> to false-positives, but it may be good enough as they are the
> exception, and may be
> bugs in 'file'.
> 
> Not sure if we need to worry about 'file' not being installed.

checkpatch works on patches so I think the test isn't
really relevant.  It has to use the appropriate email
header that sets the charset.

perhaps:
---
 scripts/checkpatch.pl | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 34e4683de7a3..57355fbd2d28 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2765,9 +2765,13 @@ sub process {
 # Check if there is UTF-8 in a commit log when a mail header has explicitly
 # declined it, i.e defined some charset where it is missing.
 		if ($in_header_lines &&
-		    $rawline =~ /^Content-Type:.+charset="(.+)".*$/ &&
-		    $1 !~ /utf-8/i) {
-			$non_utf8_charset = 1;
+		    $rawline =~ /^Content-Type:.+charset="?([^\s;"]+)/) {
+			my $charset = $1;
+			$non_utf8_charset = 1 if ($charset !~ /^utf-8$/i);
+			if ($charset !~ /^(?:us-ascii|utf-8|iso-8859-1)$/) {
+				WARN("PATCH_CHARSET",
+				     "Unpreferred email header charset '$charset'\n" . $herecurr);
+			}
 		}
 
 		if ($in_commit_log && $non_utf8_charset && $realfile =~ /^$/ &&



