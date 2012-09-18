From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvsadm: Fix buffer overrun in ipvs_dests_parse_cb()
 (bnc#775051)
Date: Tue, 18 Sep 2012 21:04:36 +0900
Message-ID: <20120918120429.GG3198@verge.net.au>
References: <1347962513-9933-1-git-send-email-tserong@suse.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347962513-9933-1-git-send-email-tserong@suse.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tim Serong <tserong@suse.com>
Cc: lvs-devel@vger.kernel.org

On Tue, Sep 18, 2012 at 08:01:53PM +1000, Tim Serong wrote:
> The attrs and dest_attrs arrays in ipvs_dest_parse_cb() seem to be using
> the wrong defines for their length.  This resulted in a buffer overrun
> corrupting EBX, which later caused a segfault running 'ipvsadm -Ln' on
> 32 bit intel (SLES 11 SP2).
> 
> Signed-off-by: Tim Serong <tserong@suse.com>

Thanks, applied.
