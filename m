From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvs: add sync_persist_mode flag
Date: Sun, 23 Jun 2013 11:34:08 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1306231108450.1584@ja.ssi.bg>
References: <20130524120935.GL264@eldamar.org.uk> <alpine.LFD.2.00.1305241633430.1636@ja.ssi.bg> <20130524151408.GM264@eldamar.org.uk> <519F92EB.4080509@gmail.com> <alpine.LFD.2.00.1305280011490.1728@ja.ssi.bg> <51A4B3ED.4070809@gmail.com>
 <alpine.LFD.2.00.1306191153590.2077@ja.ssi.bg> <51C5887A.1070301@gmail.com> <alpine.LFD.2.00.1306221510100.1577@ja.ssi.bg> <51C612F2.6080500@gmail.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <51C612F2.6080500@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Aleksey Chudov <aleksey.chudov@gmail.com>
Cc: lvs-devel@vger.kernel.org


	Hello,

On Sun, 23 Jun 2013, Aleksey Chudov wrote:

> May be some connection on LVS Master erroneously considered non-persistent?

	May be we can know more if we
grep ESTAB ip_vs_conn_sync

	It will show SYNC or LOCAL. As for persistent
conns I assume they all are SYNC.

	I see this:

- for some IPs from these 50 ESTABLISHED conns there are
persistent templates, some to same real server, others to
different real server

- there are only ESTABLISHED TCP conns, no other closing states
such as TIME_WAIT, etc. One option is the traffic to be
some outdated retransmissions with ACK bit. But this
can happen only if these ESTABLISHED conns are LOCAL in
Backup, if they are SYNC Master would assign them
real server by using the persistence scheduling. And
if they have assigned persistent template via cp->control,
they will not be synced when sync_persist_mode is 1.

	So, may be only the SYNC/LOCAL flag can
give us more information.

Regards

--
Julian Anastasov <ja@ssi.bg>
