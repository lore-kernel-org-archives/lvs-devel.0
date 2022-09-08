From: Jiri Wiesner <jwiesner@suse.de>
Subject: Re: [RFC PATCH 0/4] Use kthreads for stats
Date: Thu, 8 Sep 2022 20:32:34 +0200
Message-ID: <20220908183234.GI18621@incl>
References: <20220827174154.220651-1-ja@ssi.bg>
 <20220905082642.GB18621@incl>
 <4e16b591-dd0-86e1-afcf-5759362908b@ssi.bg>
 <20220908153521.GG18621@incl>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1662661954; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=VhVkHTNnDQYtQ3LHoYDD+5gX21eI/lJMeBrBHVuEkOM=;
        b=WhaLj4OnZMDyVEqW9si1I+p3gGh1o6CSFvOZMP9RCJLK9s4HgNotSftkCHivZ6Cf2b6nh2
        FcNUC/4Sr7weO+P2FE5oHEt+0GDjHrUZgxTBLe5RigGWfkoBtENXnCSLdht/ajKjKvi/J2
        g8Pw6nO7D5pCXX6xgKcDqy0jTwsgUfU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1662661954;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=VhVkHTNnDQYtQ3LHoYDD+5gX21eI/lJMeBrBHVuEkOM=;
        b=koxxmLTeckiolJS4azL7Hwf97rUNW3ODtw7fJUOEn13Be1y2pRK57EyXi7xCCNyiwAxyrr
        Y7lS4mIUhC4VQSBA==
Content-Disposition: inline
In-Reply-To: <20220908153521.GG18621@incl>
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, yunhong-cgl jiang <xintian1976@gmail.com>, dust.li@linux.alibaba.com

On Thu, Sep 08, 2022 at 05:35:21PM +0200, Jiri Wiesner wrote:
> There is an alternative design where you could increase kd->est_max_count for all kthreads once all of the available kthreads have kd->est_max_count estimators. Nevertheless, there would also have to be a limit to the value of kd->est_max_count. Imagine the estimation during a single tick would take so long that the gap variable in ip_vs_estimation_kthread() would become negative. You would need to have circa 250,000 estimators per kthread. Since you are already measuring the timeout you need for schedule_timeout() in ip_vs_estimation_kthread(), it should be possible to set the kd->est_max_count limit based on the maximum processing time per chain. It could be half a IPVS_EST_TICK, for example.
> 
> But it seems to me that the alternative design - increasing kd->est_max_count - should have some support in what is used in production. Are there servers with more than 983,040 estimators (which would be IPVS_EST_MAX_COUNT * 30 kthreads) or even one third of that?

I did some profiling (but could have just looked at top, actually) of a kthread with IPVS_EST_MAX_COUNT estimators for 100 seconds:
# Samples: 4K of event 'bus-cycles'
# Event count (approx.): 125024900
# Overhead        Period  Command          Shared Object      Symbol
# ........  ............  ...............  .................  .........................................
#
    76.44%      95570475  ipvs-e:0:0       [kernel.kallsyms]  [k] ip_vs_estimation_kthread
     8.75%      10935925  ipvs-e:0:0       [kernel.kallsyms]  [k] _find_next_bit
     3.18%       3978975  swapper          [kernel.kallsyms]  [k] intel_idle
     1.00%       1251250  ipvs-e:0:0       [kernel.kallsyms]  [k] _raw_spin_lock_bh
     0.36%        450450  swapper          [kernel.kallsyms]  [k] _raw_spin_lock
     0.36%        450450  swapper          [kernel.kallsyms]  [k] update_rq_clock

The bus-cycles event on this particular machine makes 25,000,000 events per second. Based on the period in the profile, the CPU utilization for various functions is:
ip_vs_estimation_kthread: 95570475/100/25000000*100 = 3.82%
_find_next_bit: 10935925/100/25000000*100 = 0.44%
_raw_spin_lock_bh: 1251250/100/25000000*100 = 0.05%

The kthread could definitely utilize the CPU more, which is an argument for increasing kd->est_max_count.

-- 
Jiri Wiesner
SUSE Labs
