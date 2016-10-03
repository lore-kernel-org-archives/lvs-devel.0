From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ip_vs_conn_expire_now may cause timer callback runs on two CPUs
 for a same session
Date: Mon, 3 Oct 2016 10:49:03 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1610031023520.1805@ja.home.ssi.bg>
References: <2C44267D-1193-4F59-9A49-356F38E90064@icloud.com> <alpine.LFD.2.11.1610022052320.1911@ja.home.ssi.bg> <1E75A59A-CDE5-42F1-B914-96C4BD2E0916@icloud.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1548692487-1475480945=:1805"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <1E75A59A-CDE5-42F1-B914-96C4BD2E0916@icloud.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: HePeng <xnhp0320@icloud.com>
Cc: lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1548692487-1475480945=:1805
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Mon, 3 Oct 2016, HePeng wrote:

> Hello Julian, 
> Thank you very much for the reply.
> 
> I guess this is the same reason that 
> instead of using *__ip_vs_conn_get*, 
> you use *atomic_inc* to the ref of 
> *cp* in *ip_vs_conn_expire* when fails to unlink *cp*, 
> since there is no callback is running on other CPUs, the 
> ref must be large than 0. That is also 
> one of my questions when I read the code. 

	Yes, ip_vs_conn_unlink() can see refcnt=2 or more
in which case it does not change refcnt (1->0) and conn remains
hashed. But we have to start the timer again, so the pair
atomic_inc+__ip_vs_conn_put_timer is used. It looks safe
to call __ip_vs_conn_get, atomic_inc_not_zero will work
in this case because while in timer callback refcnt can not
go below 1, even if other CPUs call ip_vs_conn_unhash+
ip_vs_conn_hash. But atomic_inc is better.

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1548692487-1475480945=:1805--
