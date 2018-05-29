From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] libipvs: fix some buffer sizes
Date: Tue, 29 May 2018 21:56:17 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1805292154160.3304@ja.home.ssi.bg>
References: <20180524203745.25950-1-ja@ssi.bg>
	<20180525092935.39a68441@redhat.com>
	<alpine.LFD.2.20.1805252144090.3447@ja.home.ssi.bg>
	<20180529160655.673cd177@redhat.com>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <20180529160655.673cd177@redhat.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=unsubscribe>
List-Archive: <http://lists.graemef.net/pipermail/lvs-users>
List-Post: <mailto:lvs-users@linuxvirtualserver.org>
List-Help: <mailto:lvs-users-request@linuxvirtualserver.org?subject=help>
List-Subscribe: <http://lists.graemef.net/mailman/listinfo/lvs-users>,
	<mailto:lvs-users-request@linuxvirtualserver.org?subject=subscribe>
Sender: lvs-users-bounces@linuxvirtualserver.org
Errors-To: lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>


	Hello,

On Tue, 29 May 2018, Jesper Dangaard Brouer wrote:

> Applied:
>  https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=5cd1778489c52
>  
> > > (To Julian) did you find this by manual review, or did you use some tool
> > > to find these?  
> > 
> > 	As you noticed the kernel patch, all started with
> > the syzkaller report, then by manual review...
> 
> I added a note to the commit desc, pointing to the kernel commit,
> gracefully reminding future distro backporters that the kernel side
> also have issues in this area ;-)

	Very good, thanks!

Regards

--
Julian Anastasov <ja@ssi.bg>
