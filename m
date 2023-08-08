From: Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to
 register functions in sysctl
Date: Mon, 7 Aug 2023 20:00:45 -0700
Message-ID: <ZNGv3Q5VBsS2/w4e@bombadil.infradead.org>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org>
 <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
 <CANnsUMG3WO_19GpnsNaXPqu6eEnpBvYUpkrf1QbHwsc9wEoCZQ@mail.gmail.com>
 <ZNGBrkP7J2g/BAWV@bombadil.infradead.org>
 <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
Mime-Version: 1.0
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 8178660E35
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 618C760E02
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org B782860E35
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp3.osuosl.org 06BC660E02
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
 MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=awhihqdhuWHeoYd3N+GeqIh75MDzai4L3hYXPN/a5fs=; b=tUST17gLJ8xZ0XM9L8/HrXEzU6
 tZMGClzY4pZ/RImt/bnbB/JZcOjtt5PmKLr+dRTMvmYeQEcUBooY2DNhz58NUerVaQqDC015TRyjc
 g1IssTuWVGi/DL9wssEj8dLTlcAJscsVmNWS5BVgJhme/xZGO0m8ySRFoRMNYJTG4Xl7MxTjTGp7C
 ZalLCKJuEZWuvODxF3D9hPb9kAHImXekJu/C7Hsr+LVqEdAUuRP99EiAC4ltf/mLdEYZHlbcagzl2
 JAzO8s3ORZZCLfmIi6xHnozbVOvMIBfDJ4vQwyENOCQFObn49Nzg3oOA/pzlUucU/MFJhjPm93T0s
 D1w47+5g==;
Content-Disposition: inline
In-Reply-To: <CANnsUMGRBnatKB4-3eYjb5aG7YnXDiZG6cjuwSgtjvVF6ErJNg@mail.gmail.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>, 
 <mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
 <mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: bridge-bounces@lists.linux-foundation.org
Sender: "Bridge" <bridge-bounces@lists.linux-foundation.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Chris Maness <christopher.maness@gmail.com>
Cc: Joel Granados <j.granados@samsung.com>, Alexander Aring <alex.aring@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, netfilter-devel@vger.kernel.org, Eric Dumazet <edumazet@google.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Paolo Abeni <pabeni@redhat.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Tony Lu <tonylu@linux.alibaba.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Will Deacon <will@kernel.org>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@netf>

On Mon, Aug 07, 2023 at 07:50:44PM -0700, Chris Maness wrote:
> I tried running the current mainline kernel (current Arch Linux) with
> simple single MUX socket (ax0) using LinFBB.  I was a happy camper as
> it seemed to work fine at first, then the system just slowed to a
> crawl.  I am wondering if any of these patches are addressing this
> behavior.

If its a regressio no.

> No kernel panic like before, but not what I was hoping for.
> I have also tried sixpack, and that explodes instantly the last time I
> have checked.   That goes all the way back to the v4 kernels. 

Are you reporting a separate regression that goes all the way back to v4 kernels?

> v2 is fine there.

What does this mean?

  Luis
