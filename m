From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCHv6 2/7] ipvs: use common functions for stats allocation
Date: Sat, 12 Nov 2022 09:22:19 +0100
Message-ID: <20221112082219.GG3484@incl>
References: <20221031145647.156930-1-ja@ssi.bg>
 <20221031145647.156930-3-ja@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1668241340; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=tLvdR6jCI0+zVXkVUIgE59tJUklMVvsjdiMVkakOItM=;
        b=ffVU0vlIAlw1yFbWZ6r9AutuMPvCY4RNLLHBkMJv6xVPibkveBG7lSn+4ieJ9CFSwO0MCa
        0k4NUDCsS/98QeTYXeiOOBb5daWa557DEUzLfINXb5W9Df6pGl4tOrLlVdeXIz8gEAp9S9
        GkLo4gS0vhhHbsb5aHKMltXugJ2oTMQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1668241340;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=tLvdR6jCI0+zVXkVUIgE59tJUklMVvsjdiMVkakOItM=;
        b=/vRarqFZjb7rtPqAAF5amoM+x5GgZ0bczXm/Hap539dydc0e7FZhsvrhq7aog1MNdPWX3n
        JttYQyxKe1KLsMCQ==
Content-Disposition: inline
In-Reply-To: <20221031145647.156930-3-ja@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Mon, Oct 31, 2022 at 04:56:42PM +0200, Julian Anastasov wrote:
> Move alloc_percpu/free_percpu logic in new functions
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Reviewed-by: Jiri Wiesner <jwiesner@suse.de>

-- 
Jiri Wiesner
SUSE Labs
