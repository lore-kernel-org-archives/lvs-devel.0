From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Remove dead debug code
Date: Wed, 16 Jul 2014 09:34:05 +0900
Message-ID: <20140716003405.GD25244@verge.net.au>
References: <1403835026-5506-1-git-send-email-scientist@fb.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1403835026-5506-1-git-send-email-scientist@fb.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Yannick Brosseau <scientist@fb.com>
Cc: wensong@linux-vs.org, ja@ssi.bg, lvs-devel@vger.kernel.org

On Thu, Jun 26, 2014 at 07:10:26PM -0700, Yannick Brosseau wrote:
> This code section cannot compile as it refer to non existing variable
> It also pre-date git history.
> 
> Signed-off-by: Yannick Brosseau <scientist@fb.com>

Thanks, applied.
