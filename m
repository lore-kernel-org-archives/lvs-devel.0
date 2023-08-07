From: Luis Chamberlain <mcgrof@kernel.org>
Subject: Re: [PATCH v2 00/14] sysctl: Add a size argument to
 register functions in sysctl
Date: Mon, 7 Aug 2023 14:44:11 -0700
Message-ID: <ZNFlqwwvE6w6HyHl@bombadil.infradead.org>
References: <20230731071728.3493794-1-j.granados@samsung.com>
 <ZMgpck0rjqHR74sl@bombadil.infradead.org>
Mime-Version: 1.0
Return-path: <bridge-bounces@lists.linux-foundation.org>
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org 5B347408F7
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp4.osuosl.org DCAB1408F5
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 6123C4048E
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp2.osuosl.org 9D73040150
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=bombadil.20210309; h=Sender:In-Reply-To:Content-Type:
 MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=g+VsSpIIvTZp+OYSzc71ePgWKvh9dbj0dOgrtfhVY08=; b=nv3YiaN+c2/xvyBTT2Scu3RVHn
 Tj4b/HyzInNj8yGoInNGOYxe01yyjWs033Jma+vixDeIw5QdEW3/KFTOOcij/qjKWMuu5yJugNPak
 5bGUWL8QxbO2hds1oMmC1dHP1V6cQK2D4CaALau+vpGeX5XE9OvQJDFIO1Yi21zaO8HE2+pk34l2n
 BVyUdtZzZvxBzsi1joxY+1qA9ciAyv62012YcPxmBErjy0ZIa5JCIYEpqbx+tuJU0O0v/7lnUWQPd
 Rgxo3BYCj2n7RrlkjDHbuZtr8gKU8wmwOtvkewC4c71qhu+pMW57ycko0SZ5Zi0jULdqh4x1zPD/o
 G0OdFzXQ==;
Content-Disposition: inline
In-Reply-To: <ZMgpck0rjqHR74sl@bombadil.infradead.org>
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

On Mon, Jul 31, 2023 at 02:36:50PM -0700, Luis Chamberlain wrote:
> > Joel Granados (14):
> >   sysctl: Prefer ctl_table_header in proc_sysctl
> >   sysctl: Use ctl_table_header in list_for_each_table_entry
> >   sysctl: Add ctl_table_size to ctl_table_header
> >   sysctl: Add size argument to init_header
> >   sysctl: Add a size arg to __register_sysctl_table
> >   sysctl: Add size to register_sysctl
> >   sysctl: Add size arg to __register_sysctl_init
> 
> This is looking great thanks, I've taken the first 7 patches above
> to sysctl-next to get more exposure / testing and since we're already
> on rc4.

Ok I havent't heard much more feedback from networking folks, and
since this is mostly sysctl love I've taken in the rest of these
patches. Thanks to Jani Nikula for the reviews and to Greg KH for
the suggestion on simplifying things.

Let's see what busts in linux-next, and if anything does I can reset
my tree back to only the first 7 patches.

  Luis
