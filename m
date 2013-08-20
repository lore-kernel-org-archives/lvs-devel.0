From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] ipvsadm: Fix svc->pe_name conditional
Date: Tue, 20 Aug 2013 09:35:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1308200924430.1698@ja.ssi.bg>
References: <1376844063-4298-1-git-send-email-rohara@redhat.com> <alpine.LFD.2.00.1308182035550.3222@ja.ssi.bg> <20130819145217.GA12716@redhat.com> <alpine.LFD.2.00.1308191817200.1606@ja.ssi.bg> <20130819204043.GB14857@redhat.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130819204043.GB14857@redhat.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ryan O'Hara <rohara@redhat.com>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org


	Hello,

On Mon, 19 Aug 2013, Ryan O'Hara wrote:

> On Mon, Aug 19, 2013 at 06:27:21PM +0300, Julian Anastasov wrote:
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

	Yes

> I also noticed that CHECK_COMPAT_DEST can be removed. This macro
> simply calls CHECK_IPV4, which is also called by CHECK_COMPAT_SVC. I
> noticed that CHECK_COMPAT_DEST is only called after CHECK_COMPAT_SVC,
> so this macro can be removed entirely. Agree?

	No. It looks like the macros work with more
than one structure: svc and dest. Same was for CHECK_PE
where both structs were supported: ipvs_service_entry_t and
ipvs_service_t when CHECK_PE was called from CHECK_COMPAT_SVC.

	CHECK_COMPAT_SVC does not check the dest->af,
it checks svc->af. Without both checks, svc can come
with address from AF_INET family while -r option has address
from AF_INET6 family. IMHO, we need just the return->goto
change.

Regards

--
Julian Anastasov <ja@ssi.bg>
