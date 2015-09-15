From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH ipvs-next] ipvs: add sysctl to ignore tunneled packets
Date: Mon, 14 Sep 2015 23:24:24 -0700
Message-ID: <CALCkm3c1RUyV5z_cn=KFXZqAC_FoFbY8tkemO9t=A5dn_JZR5Q@mail.gmail.com>
References: <1441907665-1703876-1-git-send-email-agartrell@fb.com>
 <alpine.LFD.2.11.1509112212460.1836@ja.home.ssi.bg> <CALCkm3e36Y+LS6_cFbmVzv8EkrdNpo0yD5JARVUk-g5_TykSBw@mail.gmail.com>
 <alpine.LFD.2.11.1509140931220.1893@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=wN/S1twPuK/3jw1GQD5QHcJ21MNyKgdwiDKgSbauwzo=;
        b=bQX82rRpcFY7Pr4XqVrLrRrWQ5E6ksTXE3NkZpriBXk+yMKeSdeM52alY8EIq/bkQL
         9RAsKO7DaFI0dbDH3ODNrrzzDw/LTitMDV8JyYB5OxuX6yHkjNPipr8fzMYTzwWsIwPL
         9TTNjs7CzwCynkvpP6X+WXGRhPfr7cGwCID3J10N7emzx4155IOT3HPIRLxaanrk/sm5
         jV1DHltJ19tuH5e992uLVVBmxZH/jDdVuGqtMQJnLzRtviH1sBlZ3hUQmIS3E63CLCZJ
         ZR2n7pxbWlu9fj2WtvEVJWbZzcNNK/YG4TPGztzNH3iwUjIxWvi4DrdKCusmm2fgrStx
         r1tQ==
In-Reply-To: <alpine.LFD.2.11.1509140931220.1893@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

On Sun, Sep 13, 2015 at 11:46 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         Also, think for adding info for all flags you add
> in Documentation/networking/ipvs-sysctl.txt, for this patch
> and for your previous work.

I'll include the change for ignore_tunneled in the sysctls doc and
send additional patches for the other sysctls.

-- 
Alex Gartrell <agartrell@fb.com>
