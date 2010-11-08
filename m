From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Mon, 8 Nov 2010 22:59:39 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011082245360.1690@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <20101030231601.GA5908@verge.net.au> <201011032108.07311.hans.schillstrom@ericsson.com> <20101106005614.GA11220@verge.net.au>
 <alpine.LFD.2.00.1011061543130.4009@ja.ssi.bg> <20101106143405.GB27212@verge.net.au> <alpine.LFD.2.00.1011061959370.5280@ja.ssi.bg> <20101108062121.GA17685@verge.net.au> <alpine.LFD.2.00.1011081027080.1504@ja.ssi.bg> <20101108111600.GA14454@verge.net.au>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20101108111600.GA14454@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Simon Horman <horms@verge.net.au>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, LVS-Devel <lvs-devel@vger.kernel.org>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Mon, 8 Nov 2010, Simon Horman wrote:

>> today. May be if Hans uses ip_vs_pe_getbyname instead of
>> ip_vs_pe_get that should solve the request_module problem.
>
> I changed things around a bit in "IPVS: Add persistence engine to
> connection entry".
>
> 	ip_vs_pe_getbyname() became __ip_vs_pe_getbyname()
> 	ip_vs_pe_get() became ip_vs_pe_getbyname()
> 	And ip_vs_pe_get() now just takes a reference on the module if its
> 	loaded.
>
> So yes I agree, except that __ip_vs_pe_getbyname() is the name
> of the function that should be called, which needs to be made
> un-static and possibly renamed (again).
>
> Also, to __ip_vs_pe_getbyname() calls try_module_get().
> Is that safe from interrupt context?

 	Yes, we already use it for cp->app: ip_vs_bind_app ->
tcp_app_conn_bind -> ip_vs_app_inc_get -> ip_vs_app_get

>> 	What should we do if PE module is not loaded
>> while we are creating connection in backup? We can not
>> load modules, may be when connection is bound to
>> dest+svc we should inherit the PE from svc->pe ?
>
> If the modules isn't loaded, then svc->pe can't be non-NULL, right?

 	Adding svc will load the PE module, for example:

- backup creates template but there is no PE => cp->pe remains NULL if
 	we want to keep conn entry. Option 2 is that we can ignore
 	the conn entry if the PE module is not loaded before this step

- svc is added => PE module is loaded (request_module)

- next sync message comes and we bind cp->dest => if cp->pe
is NULL we should set cp->pe to svc->pe. The problem here is
that svc can be added without PE, then this template will not
work as expected.

Regards

--
Julian Anastasov <ja@ssi.bg>
