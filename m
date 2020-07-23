From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH 01/26] bpfilter: fix up a sparse annotation
Date: Thu, 23 Jul 2020 13:14:47 +0200
Message-ID: <20200723111447.3xj7cidlsspofsja@ltop.local>
References: <20200723060908.50081-1-hch@lst.de>
 <20200723060908.50081-2-hch@lst.de>
Mime-Version: 1.0
Return-path: <netfilter-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=vdYyoECOJpkvRW+iDSJN0RIdv+nH41NS293U/5tTNzU=;
        b=B5vDCuMK34uIsnpD9z3FcIKsP+ARgUC68tC2JBNii294ZVz92X5OyPMGm1cnHIYPvl
         3DKQSNa/jdlu0biVdgVy3X/Usw30FobXy8VPbwfs9mZO4hgKFIB5Q6ou4++0iHZWcmIg
         rfstWtDzaQOlAHrnGsoBfnDZMJ2kD6uwV1y2oKkj2sr770VnwjwNmw0Za18fcxNwyhPN
         PX5gNfWd5bOhXJY1Kvg+SfF57+CLOAPlOGTBbqcVuFCBHygW7tXdpNSN+uznlRCislSc
         n2D4vVeaN2C63ZjJ8LYUcP4YwR3kpvL7IT5R8VKRAe3yBJewccDUsJmVY4TugCpk7vZl
         wX7Q==
Content-Disposition: inline
In-Reply-To: <20200723060908.50081-2-hch@lst.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Eric Dumazet <edumazet@google.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, linux-bluetooth@vger.kernel.org, bridge@lists.linux-foundation.org, linux-can@vger.kernel.org, dccp@vger.kernel.org, linux-decnet-user@lists.sourceforge.net, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, mptcp@lists.01.org, lvs-devel@vger.kernel.org, rds-devel@oss.o

On Thu, Jul 23, 2020 at 08:08:43AM +0200, Christoph Hellwig wrote:
> The __user doesn't make sense when casting to an integer type, just
> switch to a uintptr_t cast which also removes the need for the __force.

Feel free to add my:

Reviewed-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

-- Luc
