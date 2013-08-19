From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: Fix svc->pe_name conditional
Date: Mon, 19 Aug 2013 18:27:21 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308191817200.1606@ja.ssi.bg>
References: <1376844063-4298-1-git-send-email-rohara@redhat.com> <alpine.LFD.2.00.1308182035550.3222@ja.ssi.bg> <20130819145217.GA12716@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130819145217.GA12716@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Mon, 19 Aug 2013, Ryan O'Hara wrote:

> On Sun, Aug 18, 2013 at 09:13:39PM +0300, Julian Anastasov wrote:
> 
> > - CHECK_PE and CHECK_IPV4 as part of CHECK_COMPAT_SVC use
> > 'return' and we can leak svc in ipvs_get_service()
> >
> > - in ipvs_get_service() CHECK_PE does not need to be called,
> > it is already part of CHECK_COMPAT_SVC
> 
> Yes. I'm tempted to remove these macros due to the 'return'
> issue. Thoughts?

	May be they can use 'goto' instead of 'return':

	if (condition) {
		errno = XXX;
		goto out_err;
	}

	and funcs can have such exit point:

out_err:
	free stuff on error
	return ret;

> > - ipvs_get_service uses malloc but later calls CHECK_PE, may be
> > malloc should be changed with calloc
> 
> Aside from the fact that CHECK_PE could return without freeing memory,
> I don't see the problem here.

	malloc does not initialize the memory and checking of
svc->pe_name[0] in CHECK_PE would give random results.

Regards

--
Julian Anastasov <ja@ssi.bg>
