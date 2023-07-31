From: Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to
 register functions in sysctl
Date: Mon, 31 Jul 2023 13:50:40 -0700
Message-ID: <ZMgeoDT0t3NeALM0@bombadil.infradead.org>
References: <20230731071728.3493794-1-j.granados@samsung.com>
Mime-Version: 1.0
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org F022740B49
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 3051740930
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 3D58940361
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 34BBF4031E
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
 MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=0rQhfOHno9kOrBF8fBhXP/I9K++I3qDiyVLQoCDK1W4=; b=M5P5CTtU8QVHseBu0j23jZKJQ5
 zdmFeCi+q8wFnS2+KLHSjnJHSd5pnzFickjfzr8jPwi/vCHqAcZ9WCA0mR/QI+0Kjh6XoL08hbzME
 VBoQ7z2I6Dq5QBWWD3rWbO5iIaX+lC0AM/wvJ+GiOSWfF9SPutpolOgNZ/ukNLIzK/aedDEcVPyTh
 B6h6pyyaLRZgV2Xnjk90uOZf4W9KyZ4Eh/0yo+2JjiRxVLIfvbTk5JuH66kGyMozCxgEvJ5Em1xlL
 kXWtKSBK2wPTpBoShax3yAK0g9H7optbF9G7QT4V+AJEEI2MXcMbpAcaMH4qxLMKm3Dc+XsCAUXi2
 4McdhxWA==;
Content-Disposition: inline
In-Reply-To: <20230731071728.3493794-1-j.granados@samsung.com>
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
To: Joel Granados <joel.granados@gmail.com>
Cc: Joel Granados <j.granados@samsung.com>, Wen Gu <guwen@linux.alibaba.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Catalin Marinas <catalin.marinas@arm.com>, Nikolay Aleksandrov <razor@blackwall.org>, Alexander Aring <alex.aring@gmail.com>, linux-sctp@vger.kernel.org, Miquel Raynal <miquel.raynal@bootlin.com>, Jan Karcher <jaka@linux.ibm.com>, Mat Martineau <martineau@kernel.org>, Will Deacon <will@kernel.org>, Alexander Gordeev <agordeev@linux.ibm.com>, Stefan Schmidt <stefan@datenfreihafen.org>, Steffen Klassert <steffen.klassert@secunet.com>, linux-s390@vger.kernel.org, rds-devel@oss.oracle.com, Xin Long <lucien.xin@gmail.com>, Herbert Xu <herbert@gondor.apana.org.au>, linux-rdma@vger.kernel.org, Tony Lu <tonylu@linux.alibaba.com>, bridge@lists.linux-foundation.org, willy@infradead.org, Jozsef Kadlecsik <kadlec@net>

On Mon, Jul 31, 2023 at 09:17:14AM +0200, Joel Granados wrote:
> Why?

It would be easier to read if the what went before the why.

> This is a preparation patch set that will make it easier for us to apply
> subsequent patches that will remove the sentinel element (last empty element)
> in the ctl_table arrays.
> 
> In itself, it does not remove any sentinels but it is needed to bring all the
> advantages of the removal to fruition which is to help reduce the overall build
> time size of the kernel and run time memory bloat by about ~64 bytes per
> sentinel.

s/sentinel/declared ctl array

Because the you're suggesting we want to remove the sentinel but we
want to help the patch reviewer know that a sentil is required per
declared ctl array.

You can also mention here briefly that this helps ensure that future moves of
sysctl arrays out from kernel/sysctl.c to their own subsystem won't
penalize in enlarging the kernel build size or run time memory consumption.

Thanks for spinning this up again!

  Luis
