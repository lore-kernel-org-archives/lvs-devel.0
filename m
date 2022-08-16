From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH nf-next] netfilter: ipvs: Divide estimators into
 groups
Date: Tue, 16 Aug 2022 18:22:57 +0200
Message-ID: <20220816162257.GA18621@incl>
References: <20220812103459.GA7521@incl>
 <f1657ace-59fb-7265-faf8-8a1a26aaf560@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1660666978; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=oJeBNMRfo88AxUhhWQ0t4TxTFqdEjT8eIfnKmX+Lkrg=;
        b=WW4MUIcKFTW5QnJMfkOhGqQ9Ap07SJnZhbgBx/dohfT7e2Z1OL7W8xqmuLKft9LMUWxfcI
        y/KwYl268nHGVBftHhct+wj3WtE7/dJ9E4RiCM+wxiz9/DT/SZWatp2z01dvM2QyPYTA6R
        p10LH3P4I/yk2uq+gnSuRCG0aK36r7k=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1660666978;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=oJeBNMRfo88AxUhhWQ0t4TxTFqdEjT8eIfnKmX+Lkrg=;
        b=rGUG0IM+6XGR+A0FCPwffxIyze32E0j/WMhhR1nD30ck//eiHvp0le+J6VxRS85PTXk0cI
        va8HOkEWAOes9HAA==
Content-Disposition: inline
In-Reply-To: <f1657ace-59fb-7265-faf8-8a1a26aaf560@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: netfilter-devel@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On Sat, Aug 13, 2022 at 03:11:48PM +0300, Julian Anastasov wrote:
> > The intention is to develop this RFC patch into a short series addressing
> > the design changes proposed in [1]. Also, after moving the rate estimation
> > out of softirq context, the whole estimator list could be processed
> > concurrently - more than one work item would be used.
> 
> 	Other developers tried solutions with workqueues
> but so far we don't see any results. Give me some days, may be
> I can come up with solution that uses kthread(s) to allow later
> nice/cpumask cfg tuning and to avoid overload of the system
> workqueues.

The RFC patch already resolves the issue despite having the code still run in softirq context. Even if estimators were processed in groups, moving the rate estimation out of softirq context is a good idea. I am interested in implementing this. An alternative approach would be moving the rate estimation out of softirq context and reworking locking so that cond_resched() could be used to let other processes run as the scheduler sees fit. I would be willing to try to implement this alternative approach as well.
Jiri Wiesner
SUSE Labs
