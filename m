From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 2/3] ipvs: replace the SCTP state machine
Date: Fri, 21 Jun 2013 09:43:32 +0900
Message-ID: <20130621004331.GB18705@verge.net.au>
References: <1371539288-5036-1-git-send-email-ja@ssi.bg>
 <1371539288-5036-3-git-send-email-ja@ssi.bg>
 <20130619005256.GA19345@verge.net.au>
 <alpine.LFD.2.00.1306190740080.1632@ja.ssi.bg>
 <20130620131658.GC24993@verge.net.au>
 <alpine.LFD.2.00.1306202312380.1818@ja.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1306202312380.1818@ja.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-devel@vger.kernel.org

On Thu, Jun 20, 2013 at 11:33:06PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 20 Jun 2013, Simon Horman wrote:
> 
> > Thanks, and sorry for being a bit slow.
> 
> 	Thanks, no problem.
> 
> > Pablo has accepted patch 1 into his nf tree via my ipvs tree.
> > At this stage I expect it to show up in net and v3.10.
> > 
> > I have queued-up the remaining patches that you list above to
> > ipvs-next and pushed it. I'll send a pull request to Pablo in
> > the not to distant future.
> 
> 	OK. In the next days after tests by Aleksey Chudov
> we will know about the last patch from me:
> "ipvs: add sync_persist_mode flag". I'll post an official
> version on success. I don't know if we have time for
> all these patches, I guess we have to wait the merge window.

Thanks.

I think it would be best to send the changes that we have so far
and then send another batch when new patches are ready.
