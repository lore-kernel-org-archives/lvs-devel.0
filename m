From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH net-next] ipvs: replace ip_vs_fill_ip4hdr with ip_vs_fill_iph_skb_off
Date: Mon, 10 Aug 2015 19:28:54 -0700
Message-ID: <CALCkm3dKP1H2=Cd1E-RLt1kNSFJ2GiJxaDfZ+P7eCtxZXvtUQg@mail.gmail.com>
References: <1439239564-1677815-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=A4YNf9P96qUagyulEN4CZVNBI7FCAhIzFQN84i6w78c=;
        b=ZstudFhRuLRcMQpjAEMOB7BDBp5O44ez+++tSKfrl2wt7wKX8Uhf3689mzxp1pFFDE
         7Qf150hxR1aG5pVA7oKGJOH5ThZCvUzCXOC76Q7FnEkuUUE2N99mE0gtYAajSM4ml/E+
         puJrT04wFPKzZZ9zBreprmox5EQKagZ6FhOUF+s7wPmQO1mDt5/aXwcO4gvwZEKXuHgT
         a9dLarFE0SKDAUsb6x3WTWvofwypdLTsoZkgq/JMbpZ5d9+wpsYYK5AJpMIgeN09PRvV
         lGPzp1rF6upp9eNZlvfNbM/nkYE7QfH8EqYy8RdS1cckMFHUc6TJWITIuura3Ne1aTQ8
         7knw==
In-Reply-To: <1439239564-1677815-1-git-send-email-agartrell@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Gartrell <agartrell@fb.com>
Cc: Julian Anastasov <ja@ssi.bg>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

Hey everyone,

On Mon, Aug 10, 2015 at 1:46 PM, Alex Gartrell <agartrell@fb.com> wrote:
> This removes some duplicated code and makes the ICMPv6 path look more like
> the ICMP path.

Please disregard for now.  I will roll this into another patch series.

-- 
Alex Gartrell <agartrell@fb.com>
