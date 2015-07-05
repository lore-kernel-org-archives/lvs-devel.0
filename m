From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH,v2 net-next] ipvs: skb_orphan in case of forwarding
Date: Sun, 5 Jul 2015 15:19:27 -0700
Message-ID: <CALCkm3eyEbHpzfF1zk0OUnGaSf51=r9DmZs_2Xq4fTtOed3nNQ@mail.gmail.com>
References: <1436131706-1559824-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=Npvip0LUvklpSbB2u8PqiuwJxoCnqubdMenG6ttWQP0=;
        b=Hw+q2h5qTizQsUgPEcaCmB4S/E79Tik556K5lsFsju9Fx3bfiq60IL8JPS+JUbzbDW
         c6Oyv26BRua1P6RNx7TSxI+AKrgtiKnn4sRN2bQBGyYgr93e3OwjrCP+iVaDbdfd5trj
         K9sgt6V7M8AEXZMnPdpuIhG56lajgcn7mhPW9slhJL5klns9ZzMjpm+oGMIrceL3I9QR
         N/YuDsFDpzDQ0FXGFPV8OQ0VNfVbFho9bkbeKQuWgy+xJn7MDcc0g0BW9sBJQkmFZjiA
         Vvg7Q0rQAZ06/FSwcfPbHaSRg2F3Noi8h/KQGCXjb9QZXcOOwXlHvUI34a8vqIT1flRY
         n9Zw==
In-Reply-To: <alpine.LFD.2.11.1507060105470.12815@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Sun, Jul 5, 2015 at 3:13 PM, Julian Anastasov <ja@ssi.bg> wrote:
>         May be the patch fixes crashes? If yes, Simon
> should apply it for ipvs/net tree, otherwise after
> the merge window...

Yeah this is definitely a crash-fix and it's existed since at least 3.10.

-- 
Alex Gartrell <agartrell@fb.com>
