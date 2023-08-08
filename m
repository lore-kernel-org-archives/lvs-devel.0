From: Jakub Kicinski <kuba@kernel.org>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to register
 functions in sysctl
Date: Mon, 7 Aug 2023 19:09:14 -0700
Message-ID: <20230807190914.4ff3eb36@kernel.org>
References: <20230731071728.3493794-1-j.granados@samsung.com>
        <ZMgpck0rjqHR74sl@bombadil.infradead.org>
        <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1691460558;
        bh=K3rT1tMnJnj38jr/g9b0xYkr68We3HjPQOUUOlFXffQ=;
        h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
        b=kfyzdKVH4OgGOyi5OtD6F24v25o2XDZ5m6SvveMEOszRKEfZZ9SylUaGPkfodN407
         7/mPqRmYpPbp2dPcTKlrEIJC1Zv5LRh+2JzB18DxJOynATxXwotatsdvn/NN5ZyIbh
         xI+yzS42slBVvOmIzuzIZ6xOpvVg9Aci3OwoLZalL/uth32GZhSMU/Wd7rI2yT3/O0
         8Adq7sCyzqTTK9WNmXggxjvLnQQRycaDNcLAjqz5Xumgx4CBBdd3EH6PcwJH0/qRJv
         JwU8b8s4wpS/lSbZzxiGwrvY+tzvlO3JN8W9VVJoIsZYauX65nm8kTPwSMSOK7oodS
         bvwbazvAzKZwg==
In-Reply-To: <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Joel Granados <joel.granados@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Iurii Zaikin <yzaikin@google.com>, Jozsef Kadlecsik <kadlec@netfilter.org>, Sven Schnelle <svens@linux.ibm.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>, "D. Wythe" <alibuda@linux.alibaba.com>, mptcp@lists.linux.dev, Vasily Gorbik <gor@linux.ibm.com>, Paolo Abeni <pabeni@redhat.com>, coreteam@netfilter.org, Jan Karcher <jaka@linux.ibm.com>, Alexander Aring <alex.aring@gmail.com>, Will Deacon <will@kernel.org>, Stefan Schmidt <stefan@datenfreihafen.org>, Matthieu Baerts <matthieu.baerts@tessares.net>, bridge@lists.linux-foundation.org, linux-arm-kernel@lists.infradead.org

On Mon, 7 Aug 2023 14:44:11 -0700 Luis Chamberlain wrote:
> > This is looking great thanks, I've taken the first 7 patches above
> > to sysctl-next to get more exposure / testing and since we're already
> > on rc4.  
> 
> Ok I havent't heard much more feedback from networking folks

What did you expect to hear from us?

My only comment is to merge the internal prep changes in and then send
us the networking changes in the next release cycle.
