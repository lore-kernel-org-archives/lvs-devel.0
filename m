From: Alexander Vasiliev <a.vasylev@404-group.com>
Subject: Re: [lvs-users] LVS kernel panic
Date: Fri, 19 Jun 2015 10:53:56 +0300
Message-ID: <2BC9E46D-82C8-4C85-817C-95DCB52D64E8@404-group.com>
References: <761B8899-EB6E-4326-9FF3-1B1B44B35D64@404-group.com> <alpine.LFD.2.11.1506182130220.1659@ja.home.ssi.bg>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1506182130220.1659@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: lvs-users@linuxvirtualserver.org, lvs-devel@vger.kernel.org

Hi.
Thanks, for answer. I will use -D ==> -A for edit services.

> On Jun 18, 2015, at 9:52 PM, Julian Anastasov <ja@ssi.bg> wrote:
> 
> 
> 	Hello,
> 
> On Thu, 18 Jun 2015, Alexander Vasiliev wrote:
> 
>> Hello.
>> 
>> I have installed ipvsadm (1.2.1) on Linux Ubuntu-14.04 (3.13.0-55-generic) server.
>> Next I create service: ipvsadm -A -t 172.16.0.12:http -s lblc.
>> When I tried edit created service I got kernel panic. Edit command: ipvsadm -A -t 172.16.0.12:http -s rr, for example.
>> The problem is repeatable, I try in VirtualBox.
> 
> 	You mean second command is -E, not -A, right?
> It looks like I completely messed the scheduler editing
> with commit ceec4c381681 ("ipvs: convert services to rcu").
> The problem is with the svc->sched_data. I forgot about it.
> The reverse order of ip_vs_bind_scheduler and
> ip_vs_unbind_scheduler causes problem in all cases
> for schedulers that maintain sched_data.
> And RCU readers are not guaranteed to get the
> scheduler+sched_data pointers safely for same scheduler.
> 
> 	The simple fix would be to make sure
> ip_vs_unbind_scheduler and ip_vs_bind_scheduler work
> in this order but with synchronize_rcu between them.
> Something like what was before this change.
> The individual schedulers will not be touched.
> As changing of scheduler is a rare operation it can
> be the initial bugfix. If we want to fix it without
> such delay we have to change all schedulers, may be
> by moving sched_data in some new struct scheduler_context
> where schedulers can store their sched_data. Then
> svc->sched_context (RCU ptr) can contain both the
> scheduler and the sched_data pointers.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

