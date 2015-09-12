From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH ipvs-next] ipvs: add sysctl to ignore tunneled packets
Date: Sat, 12 Sep 2015 02:09:47 -0700
Message-ID: <CALCkm3e36Y+LS6_cFbmVzv8EkrdNpo0yD5JARVUk-g5_TykSBw@mail.gmail.com>
References: <1441907665-1703876-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1509112212460.1836@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=ZtgLupuM7yKZHg/gA1bPK0gmUlaSMsHYe2a35fqWDDs=;
        b=BX82HhYGge+EJYDXdWChufcIoIo2ezZs+LRX2dJ1Ph6EdPFHNy3ASlqttgsGBabsa8
         jXqb29LJjymIsxJOCavuLCVt0lvURYdPtDk6zatRvQNiWCQ3acC9waWhyGtQMYTp/f40
         H/jhhPiVLkwFVT02fovdoATsQzFT1I+CKjqG3ANKCTB7rs6n1xnrFF5zVOvaKMwvFMF5
         IIpqgHn3vhDivjTYf7j34X/hBtsmpJb4CuUEHM+VlcYnFs3L0F5S56w5YBICOpST2H42
         kdAyMKCRDJ0thhz/HW05DML8OJf+fFmVvqGvGe6HVnJS8x83ziMHAOe2SU6/NvGr0QCd
         nmCA==
In-Reply-To: <alpine.LFD.2.11.1509112212460.1836@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

On Fri, Sep 11, 2015 at 12:24 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         We can use "ipvs" here. I remember people used
> matching by src MAC to solve such problem for DR. For TUN
> fwmark or match by input device can work too. In all cases,
> a fwmark-based service is needed...

Yeha, to be honest, this approach isn't my ideal.  We've had a much
nastier version of this patch (that adds a field to skbuff...) for a
long time, and this was just a less awful way of doing this.

The problem for us is that moving the whole of our load balancing to
fwmark-based pools is a giant nightmare.  On top of the obvious stuff
(redeploying the userspace element to our load balancers), we'd also
need to find a way to prevent conflict between that and our firewalls.
It was more engineering than I had time for, sadly.

Other ideas I had to address this:
* Add some mechanism wherein certain fwmark's are ignored
* Add an iptables target that sets ipvs_property=1

I'm also totally open to ideas

cheers,
-- 
Alex Gartrell <agartrell@fb.com>
