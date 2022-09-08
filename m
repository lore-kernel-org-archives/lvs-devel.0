From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 2/4] ipvs: use kthreads for stats estimation
Date: Thu, 8 Sep 2022 18:00:44 +0200
Message-ID: <20220908160044.GH18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220827174154.220651-3-ja@ssi.bg>
 <20220905131905.GD18621@incl>
 <6a7bec4b-557-298b-b2e9-f3a517a47489@ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662652845; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=WCtM9jkq+O2J63ASjaSwLT4QgvR/jlTzd+XIvIaFLoY=;
        b=xDWE90B/e4lTRvcj24AffKNIht/62f1eKdoye5LiYIY/dEnK7OT2saaZ1/IyEpceOpc8gY
        FiCvWu6bVHORFBQo2F5qBsdTZjE+EoTv8WEowBoZ7OUMYjF76nF+yomWD4gLcPDfuhntPd
        3SIqwK0XCWg5SqQVrYSeM1jZ8svfYm0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662652845;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=WCtM9jkq+O2J63ASjaSwLT4QgvR/jlTzd+XIvIaFLoY=;
        b=s0vxbHEwH9U5pqanndb40tbL9ZBhnGdkrG9UpZY6o3o3mwwRsAJ5u4GOLvJ3DTouBUntrp
        ipEDxE1+jAGvxHCQ==
Content-Disposition: inline
In-Reply-To: <6a7bec4b-557-298b-b2e9-f3a517a47489@ssi.bg>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Wed, Sep 07, 2022 at 10:01:27PM +0300, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 5 Sep 2022, Jiri Wiesner wrote:
> 
> > On Sat, Aug 27, 2022 at 08:41:52PM +0300, Julian Anastasov wrote:
> > >  
> > > +static void est_reload_work_handler(struct work_struct *work)
> > > +{
> > > +	struct netns_ipvs *ipvs =
> > > +		container_of(work, struct netns_ipvs, est_reload_work.work);
> > > +	int genid = atomic_read(&ipvs->est_genid);
> > > +	int genid_done = atomic_read(&ipvs->est_genid_done);
> > > +	unsigned long delay = HZ / 10;	/* repeat startups after failure */
> > > +	bool repeat = false;
> > > +	int id;
> > > +
> > > +	mutex_lock(&ipvs->est_mutex);
> > > +	for (id = 0; id < ipvs->est_kt_count; id++) {
> > > +		struct ip_vs_est_kt_data *kd = ipvs->est_kt_arr[id];
> > > +
> > > +		/* netns clean up started, abort delayed work */
> > > +		if (!ipvs->enable)
> > > +			goto unlock;
> > 
> > It would save some code to move the ipvs->enable check before the critical section and use a return statement right away.
> 
> 	I preferred to react to cleanup_net() faster and
> avoid creating threads if this is what we try to do here.

I meant putting
if (!ipvs->enable)
	return;
right before the mutex_lock() statement.

-- 
Jiri Wiesner
SUSE Labs
