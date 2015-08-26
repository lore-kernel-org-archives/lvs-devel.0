From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next,v4 01/14] ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
Date: Wed, 26 Aug 2015 10:48:29 -0700
Message-ID: <CALCkm3dUakzPN4ffMsWUrCuXCMKbBhY5z2EN8oJR2Yw9NMr6Bw@mail.gmail.com>
References: <1440607241-355987-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1508262034120.22375@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=NpWZyjgwj5C2Yx5SHG3HdPMNYwoEqRPKBPCj+sLaFAk=;
        b=OajpmIcZ5fTbw0U8+CoQJdXzY9SfQ+hOej8FhIiVdrSf6BUx46VOE7rO0XpbuCuLTM
         A7zyKtcyjSAgTEfZKl70PRB/RIFpocels7xq6wB9jBLi0IS53Um3/QSsokDQ/IIA3kC4
         YTZ72TnJaQoIOWoc1P6H2QQUIkRSPzdmU6EMlHExBetb17ty99DjL+lZJlzchPb3tOSo
         O9k+RYTu0rrosLew4LcIiTr5LJ6lopmy9MH+PeF1brFGN6f4Fzh+Uwls4m2D+qV3Al6K
         uwFdmYn0N9BUNSEnM8K3b3nSjh62o2irA6q8GC06/zJ5ZfjS+Z3rPzgCx9mXa/fMO2q/
         Ublw==
In-Reply-To: <alpine.LFD.2.11.1508262034120.22375@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

Hey,

On Wed, Aug 26, 2015 at 10:37 AM, Julian Anastasov <ja@ssi.bg> wrote:
>         All patches 1-14 look ok to me, thanks!
>
> Acked-by: Julian Anastasov <ja@ssi.bg>

Thanks so much for all of your help!

>         Not sure why 00/14 is missing, it is useful.

This is because I am stupid :)  I've sent it now.
