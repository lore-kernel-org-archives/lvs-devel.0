From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence
 support
Date: Mon, 1 Nov 2010 23:53:38 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1011012312550.1621@ja.ssi.bg>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg> <201011011103.41004.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <201011011103.41004.hans.schillstrom@ericsson.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: TEXT/PLAIN; charset="us-ascii"; format="flowed"
Content-Transfer-Encoding: 7bit
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Cc: LVS-Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>


 	Hello,

On Mon, 1 Nov 2010, Hans Schillstrom wrote:

>> v2 PATCH 2/4
>>  	- Do we change the name from "Option" to "Parameter" ?
> Sure, why not Optional Parameter

 	Initially, we wanted parameters to be mandatory and
optional, more correctly the backup's treatment for them.
I.e. as a way to handle unsupported parameters in backup.
Now we decided that backup must support all parameters,
if some parameter is unknown the connection entry is
ignored. Of course, when sending parameters their
presence in message is optional and they are added only
when the connection has that property: PE DATA, etc.

>>  	Also, 'Option Length" will be part of the DATA, i.e.
>>  	it should be present depending on type, in some cases
>>  	it will be implicit, eg. for IPVS_OPT_SEQ_DATA:
>
> No,
> I think this is a bad idea.
> Commonication protocols/formats should be simple an clean without exceptions.
> So in our case Param options should consits of (without exceptions):
> - TYPE and a LENGTH field, followed by data
> Where TYPE is 1 byte
> and   LENGTH is 1 byte, (value 1-255, 0 is illegal)

 	ok, for me this method was required to accept
connection entries with unknown parameters and is not
needed if message is accepted only with known parameters.

>>  	- lets drop the optional parameters from ip_vs_process_message()?
>
> I guess that you mean ip_vs_sync_conn_options,
> in that case I do agree.

 	Not ip_vs_sync_conn_options but the support for
accepting connection entries with unknown parameters,
i.e. unknownOpt code. As for ip_vs_sync_conn_options
there is no app in mainline kernel 2.6.36+ that will trigger
this parameter. And we do not know (yet) how to sync SEQs with
Netfilter in the case for ip_vs_ftp.

>>       Also note that p->pe is
>>  	pointer without reference while called in ip_vs_sched_persist.
>>  	In our case with ip_vs_conn_fill_param_sync we should
>>  	put this reference after calling ip_vs_proc_conn().
>>  	May be ip_vs_find_dest should check that p->pe matches
>>  	svc->pe. ip_vs_try_bind_dest should provide p->pe too
>>  	for this check. But we must somehow ignore new conns
>>  	with PE if they don't have cp->dest (service) because
>>  	it is risky to attach PE that is not held by svc.
>>  	It is bad that the check for p->pe is before
>>  	ip_vs_find_dest.
>
> Can we agree upon that Simons patch "IPVS: Add persistence engine to connection entry"
> solves this issue ?

 	Yes, agreed

> The basic principle for param decoding is;
> - Unknown param: skip this entry and continue with next
> - Invalid param length: drop the buffer.
> - Invalid param data: skip this entry and continue with next
>   (If possible to check)

 	Yes, that is fine

> There is a violation to this that I will correct:
> Checking for a terminating Zero in pe_name string causes a drop of entire buffer, not just the conn. entry.
>
>> v2 PATCH 4/4
>>  	May be we should add configuration option if sync is enabled
>>  	to default to version 0 because how we solve the problem if
>>  	backup can not be upgraded?
>
> That means that we need to have a "version 0 sending functions" as well.
> I think that version 1 should be default, if you ran into problems activate ver 0.

 	I'm not sure how to solve this problem. I worry to
leave users without option to sync to some old backups that can
not be upgraded to new kernel. And if we have such config
option it is not fatal if it defaults to 1. At least, it
can be changed.

>>  	For IPVS_OPT_PE_NAME: because we have length better not to
>>  	add zero terminator in sync message. It complicates the
>>  	checks in backup. Or backup prefers to check with zero
>>  	terminated string directly from message? In this case we
>>  	should check for existing terminator.
>
> My hart says, don't use terminating Zeroes when there is a length but:
> "Since there is no space to add a trailing Zero in the buffer
> some changes has to be done. (I'm not going to make temp copy!)
> Length param needs to be added to ip_vs_pe_get() and ip_vs_pe_getbyname()
> which affects ip_vs_add_service() and  ip_vs_edit_service()"

 	May be adding pe_name_len argument to ip_vs_pe_getbyname
is a better way.

> Leave it as is or remove the trailing Zero thats the question ?

 	With above method terminator is not needed.

Regards

--
Julian Anastasov <ja@ssi.bg>
