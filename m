From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] libipvs: fix some buffer sizes
Date: Tue, 29 May 2018 16:06:55 +0200
Message-ID: <20180529160655.673cd177@redhat.com>
References: <20180524203745.25950-1-ja@ssi.bg>
	<20180525092935.39a68441@redhat.com>
	<alpine.LFD.2.20.1805252144090.3447@ja.home.ssi.bg>
Reply-To: "LinuxVirtualServer.org users mailing list."
	<lvs-users@linuxvirtualserver.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <lvs-users-bounces+gcll-lvs-users=m.gmane.org@linuxvirtualserver.org>
In-Reply-To: <alpine.LFD.2.20.1805252144090.3447@ja.home.ssi.bg>
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
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org, lvs-users@linuxvirtualserver.org, Simon Horman <horms@verge.net.au>, Ryan O'Hara <rohara@redhat.com>, brouer@redhat.com

On Fri, 25 May 2018 21:48:31 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	Hello,
> 
> On Fri, 25 May 2018, Jesper Dangaard Brouer wrote:
> 
> > 
> > On Thu, 24 May 2018 23:37:45 +0300 Julian Anastasov <ja@ssi.bg> wrote:
> >   
> > > Size or length? Here is the answer:
> > > 
> > > - IP_VS_SCHEDNAME_MAXLEN and IP_VS_IFNAME_MAXLEN are sizes
> > > because they are used in kernel structures exported to user
> > > space for the old setsockopt interface. We can not change
> > > these structures in the kernel.
> > > 
> > > - IP_VS_PENAME_MAXLEN and IP_VS_PEDATA_MAXLEN are max lengths
> > > because they are not exported to the old interface.
> > > 
> > > As result:
> > > - buffers should have space for NUL terminator
> > > - strncpy should use sizeof(buffer) - 1 as max length
> > > 
> > > As we change the libipvs structures, their users should be
> > > recompiled.
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>  
> > 
> > This all looks fine to me.  I'll give other people a little time to
> > review and ACK, before I apply this.  
> 
> 	Thanks!

Applied:
 https://git.kernel.org/pub/scm/utils/kernel/ipvsadm/ipvsadm.git/commit/?id=5cd1778489c52
 
> > (To Julian) did you find this by manual review, or did you use some tool
> > to find these?  
> 
> 	As you noticed the kernel patch, all started with
> the syzkaller report, then by manual review...

I added a note to the commit desc, pointing to the kernel commit,
gracefully reminding future distro backporters that the kernel side
also have issues in this area ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
