From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCHv2 RFC 22/25] IPVS: Adjust various debug outputs to use
	new macros
Date: Tue, 2 Sep 2008 18:00:16 +1000
Message-ID: <20080902080015.GL13730@verge.net.au>
References: <1220273782-19901-1-git-send-email-juliusv@google.com> <1220273782-19901-23-git-send-email-juliusv@google.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1220273782-19901-23-git-send-email-juliusv@google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julius Volz <juliusv@google.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net, vbusam@google.com

On Mon, Sep 01, 2008 at 02:56:19PM +0200, Julius Volz wrote:
> Adjust various debug outputs to use the new *_BUF macro variants for
> correct output of v4/v6 addresses.
> 
> Signed-off-by: Julius Volz <juliusv@google.com>

Hi Julius,

I realise that these are existing style problems not new ones, but
could you run this patch through checkpatch.pl and clean things up
a little?
