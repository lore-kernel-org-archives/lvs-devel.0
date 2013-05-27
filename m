From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] Sloppy TCP, SH rebalancing, SHP scheduling
Date: Tue, 28 May 2013 00:31:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <519F92EB.4080509@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: Alexander Frolkin <avf@eldamar.org.uk>, lvs-devel@vger.kernel.org


	Hello,

On Fri, 24 May 2013, Aleksey Chudov wrote:

> May be better to modify the sync algorithm to synchronize only persistence
> templates for these specific cases? Is it possible at all?

	May be, with some flag and also sloppy_tcp. Then the
parametrized SH with netmask will do the same - we can avoid
the sync messages. Of course, with SH there is more risk
for imbalance and it can be exploited. Also SH requires
equal configuration for the real servers.

Regards

--
Julian Anastasov <ja@ssi.bg>
