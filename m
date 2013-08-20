From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvsadm: Fix svc->pe_name conditional
Date: Tue, 20 Aug 2013 10:28:11 +1000
Message-ID: <20130820002811.GA13751@verge.net.au>
References: <1376844063-4298-1-git-send-email-rohara@redhat.com>
 <alpine.LFD.2.00.1308182035550.3222@ja.ssi.bg>
 <20130819145217.GA12716@redhat.com>
 <alpine.LFD.2.00.1308191817200.1606@ja.ssi.bg>
 <20130819204043.GB14857@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130819204043.GB14857@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: Julian Anastasov <ja@ssi.bg>, lvs-devel@vger.kernel.org

On Mon, Aug 19, 2013 at 03:40:44PM -0500, Ryan O'Hara wrote:
> On Mon, Aug 19, 2013 at 06:27:21PM +0300, Julian Anastasov wrote:
> > 
> > 	Hello,
> > 
> > On Mon, 19 Aug 2013, Ryan O'Hara wrote:
> > 
> > > On Sun, Aug 18, 2013 at 09:13:39PM +0300, Julian Anastasov wrote:
> > > 
> > > > - CHECK_PE and CHECK_IPV4 as part of CHECK_COMPAT_SVC use
> > > > 'return' and we can leak svc in ipvs_get_service()
> > > >
> > > > - in ipvs_get_service() CHECK_PE does not need to be called,
> > > > it is already part of CHECK_COMPAT_SVC
> > > 
> > > Yes. I'm tempted to remove these macros due to the 'return'
> > > issue. Thoughts?
> > 
> > 	May be they can use 'goto' instead of 'return':
> > 
> > 	if (condition) {
> > 		errno = XXX;
> > 		goto out_err;
> > 	}
> > 
> > 	and funcs can have such exit point:
> > 
> > out_err:
> > 	free stuff on error
> > 	return ret;
> 
> OK. It looks like ipvs_get_service() is the only function with a
> potential leak. The other functions that call any of the CHECK_*
> macros will just get an 'out_err: return -1'.
> 
> I also noticed that CHECK_COMPAT_DEST can be removed. This macro
> simply calls CHECK_IPV4, which is also called by CHECK_COMPAT_SVC. I
> noticed that CHECK_COMPAT_DEST is only called after CHECK_COMPAT_SVC,
> so this macro can be removed entirely. Agree?

That sounds reasonable to me.

> 
> > > > - ipvs_get_service uses malloc but later calls CHECK_PE, may be
> > > > malloc should be changed with calloc
> > > 
> > > Aside from the fact that CHECK_PE could return without freeing memory,
> > > I don't see the problem here.
> > 
> > 	malloc does not initialize the memory and checking of
> > svc->pe_name[0] in CHECK_PE would give random results.
> 
> I see. Thanks.
> 
> Ryan
> 
