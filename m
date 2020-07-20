From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: get rid of the address_space override in setsockopt
Date: Mon, 20 Jul 2020 13:47:56 -0700
Message-ID: <20200720204756.iengwcguikj2yrxt@ast-mbp.dhcp.thefacebook.com>
References: <20200720124737.118617-1-hch@lst.de>
Mime-Version: 1.0
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=W3gFxb9MTLvTnCe3A+iabUWXBAu7mA9HyhZHWgTOkUw=;
        b=OGmrrLECo+9bEWcObjspsB7mZd1Knz6TplGXozOrISTfqD7/NX21SXnbWcSkV3fL4v
         rTtVk5lWAA2Zu7uZ6u1mrfxhancqzyg3QAj3aPjlEycGVWZJlozkhUGEvXA8Lh3Zhd9y
         MI2pFWCUVAw0qhoczi2fzDR5o+9jsXf0u50JS+cFIfuTYX6fdThXqy7BkTGCK/dg3wkY
         mbds6x2z1GfwvAA0D5GwOBd9MLDFeCqWgb4tYptazoXAosQDHX7Ytsgw6xoiVQCij+q6
         LhYcFToAHR8FWmsf1prWh4sudrDF50FXVoAgPYMNb7eWHKWg9zXFnQitJW8+uw6BZBn8
         8EhQ==
Content-Disposition: inline
In-Reply-To: <20200720124737.118617-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Jakub Kicinski <kuba-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bpf-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dccp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mptcp-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, lvs-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel@oss.o

On Mon, Jul 20, 2020 at 02:47:13PM +0200, Christoph Hellwig wrote:
> Hi Dave,
> 
> setsockopt is the last place in architecture-independ code that still
> uses set_fs to force the uaccess routines to operate on kernel pointers.
> 
> This series adds a new sockptr_t type that can contained either a kernel
> or user pointer, and which has accessors that do the right thing, and
> then uses it for setsockopt, starting by refactoring some low-level
> helpers and moving them over to it before finally doing the main
> setsockopt method.
> 
> Note that I could not get the eBPF selftests to work, so this has been
> tested with a testing patch that always copies the data first and passes
> a kernel pointer.  This is something that works for most common sockopts
> (and is something that the ePBF support relies on), but unfortunately
> in various corner cases we either don't use the passed in length, or in
> one case actually copy data back from setsockopt, so we unfortunately
> can't just always do the copy in the highlevel code, which would have
> been much nicer.

could you rebase on bpf-next tree and we can route it this way then?
we'll also test the whole thing before applying.

sounds like v2 is needed anyway to address Eric's addr space concern?
