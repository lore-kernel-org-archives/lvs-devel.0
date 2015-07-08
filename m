From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Wed, 8 Jul 2015 13:56:39 -0700
Message-ID: <CALCkm3f0NTwUugb=sWVWQ2bJdecmZR_LFHocznuVR8fKRtRLkQ@mail.gmail.com>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg> <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
 <20150706035019.GA9155@verge.net.au> <CALCkm3d4Xqq+eWryejKhi84rM_fS4QRyu8Fn_Z7RHZv+zbv3_Q@mail.gmail.com>
 <20150708013355.GE28100@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=sYey7F+GbH2kUWf3c6inf/8uYXMIbq2ioHhjx9PAPFE=;
        b=tj4oevC5pViEBXsVYSY7RPPQrWU1j2QeKfm9p+pV2+ojbVfrLZLKptHa4XY5aVQzCf
         9FT0YWLoU75QRCwZ0kEdCVhBHzQkzhR83+EaCWWXZ3zW3ns/guMyOp0vJ8+MWQpD3n+4
         jIdw+7qOXGybNSQNnnDDhdDZVp/CKt5tZd8S26eUCXIdfb/9cXhENeWy449q8H4f6XO1
         /Z5FI2BJG+VDTyJKfVwyBsg8Xv4vLVDFUpiDGvCs1x4OEJIsZJ7gLaxiqX7w2N5pSiL8
         0Z2mitzP7QIx4eB99N8D4Rh2BpByGi3ExJ3pC9odYJiD0c0teYviE7ejjRJtgfvRhZRS
         zArA==
In-Reply-To: <20150708013355.GE28100@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Julian Anastasov <ja@ssi.bg>, Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Tue, Jul 7, 2015 at 6:33 PM, Simon Horman <horms@verge.net.au> wrote:

> Is there any possibility you could investigate which stable trees are
> effected by this bug?

Well this was certainly a problem in 3.10 (we had our own hacky
solution at the time) and every kernel since then would have also had
this problem.  I'm pretty sure this isn't a problem in 3.4 or before.

-- 
Alex Gartrell <agartrell@fb.com>
