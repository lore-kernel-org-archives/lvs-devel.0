From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v2 PATCH 0/4] IPVS: Backup Adding Ipv6 and Persistence support
Date: Mon, 1 Nov 2010 11:03:40 +0100
Message-ID: <201011011103.41004.hans.schillstrom@ericsson.com>
References: <201010291415.35299.hans.schillstrom@ericsson.com> <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1010301741280.2294@ja.ssi.bg>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: LVS-Devel <lvs-devel@vger.kernel.org>, Simon Horman <horms@verge.net.au>, "wensong@linux-vs.org" <wensong@linux-vs.org>, "daniel.lezcano@free.fr" <daniel.lezcano@free.fr>

Hello,
On Saturday 30 October 2010 16:55:32 Julian Anastasov wrote:
>
>  	Hello,
>
> On Fri, 29 Oct 2010, Hans Schillstrom wrote:
>
> > PATCH STATUS:
> > - Persistence data is not tested.
> >
> >
> > THANKS
> > The Persistence part is based on Simon Hormans Backup RFC
> > Julian for the comments and the Review of the RFC
> >
> > *v2
> > Simlified fwmark handling patch 1/4
> > New handling of optional data patch 2/4
> > Seconds in timeout
> > Basically all changes is based on Julians and Simons comments on the RFC
> > For details see individual patches.
>
> v2 PATCH 1/4
>  	OK
>
> v2 PATCH 2/4
>  	- Do we change the name from "Option" to "Parameter" ?
Sure, why not Optional Parameter

>  	Also, 'Option Length" will be part of the DATA, i.e.
>  	it should be present depending on type, in some cases
>  	it will be implicit, eg. for IPVS_OPT_SEQ_DATA:

No,
I think this is a bad idea.
Commonication protocols/formats should be simple an clean without exceptions.
So in our case Param options should consits of (without exceptions):
 - TYPE and a LENGTH field, followed by data
Where TYPE is 1 byte
and   LENGTH is 1 byte, (value 1-255, 0 is illegal)

>
>  	IPVS_OPT_SEQ_DATA:
>  		- 1 octet IPVS_OPT_SEQ_DATA followed by
>  		struct ip_vs_sync_conn_options
>

No, This breaks the rules.

>  	IPVS_OPT_PE_DATA:
>  		- 1 octet IPVS_OPT_PE_DATA, 1 or 2 octets
>  		for Parameter Length (pe_data_len) followed by
>  		pe_data. If the decision is to support large
>  		data please use 2 octets and get_unaligned_be16
>  		to read it. Other PEs may need it, they can decide
>  		to add many things in PE data, they will not
>  		allocate other cp fields for their data.
>
No,
If you need to send more than 255 bytes of data to identify a call,
then you should go back to the drawing board again.
Remember that we are using "tiny" datagrams.
If we later on needs changes there is a place for that,
 - the version.

>  	IPVS_OPT_PE_NAME:
>  		- 1 octet for IPVS_OPT_PE_NAME, 1 octet
>  		for Parameter Length (pe_name_len) followed by
>  		pe_name

Yes, It is like that now, including a terminating Zero...

>
>  	- struct ip_vs_sync_mesg_v2 with spaces instead of tabs?
>
>  	- can we add check in backup for timeout not to exceed
>  		(MAX_SCHEDULE_TIMEOUT / HZ)
>
>  	For example:
>
>  	if (timeout) {
>  		if (timeout > MAX_SCHEDULE_TIMEOUT / HZ)
>  			timeout = MAX_SCHEDULE_TIMEOUT / HZ;
>  		cp->timeout = timeout * HZ;
>  	} else ...

Yes, Sounds like a good Idea

>
>  	- extra space in protocol:
>  	ip_vs_proc_conn(&param, flags, state, s-> protocol, AF_INET,
>
Ooops, I'll remove that

>  	- lets drop the optional parameters from ip_vs_process_message()?

I guess that you mean ip_vs_sync_conn_options,
in that case I do agree.

>
>  	- ip_vs_process_message: do not use mask: m2->size & SVER_MASK
>  	because the message size has no version.

Ooops again :-)

>
>  	- What is the right thing to do in ip_vs_conn_fill_param_sync
>  	when ip_vs_pe_get() does not find PE? May be to drop
>  	connection? May be in ip_vs_process_message() we should
>  	use one pointer for end of message (it was 'p' before now),
>  	so that we can skip connections, for example, when some
>  	mandatory parameter as PE is not supported. We should not
>  	drop the whole sync message. When message is invalid it
>  	should be dropped but lack of support should not hurt
>  	other connections. In the case for PE may be
>  	ip_vs_conn_fill_param_sync() should return 1 if
>  	PE is unknown (ip_vs_pe_get). Then caller will continue
>  	with next connection if result > 0 or will drop message
>  	if result < 0 as in current patch. May be the pe_name
>  	presence should be the first check in
>  	ip_vs_conn_fill_param_sync.

Yes I'll fix that.

>       Also note that p->pe is
>  	pointer without reference while called in ip_vs_sched_persist.
>  	In our case with ip_vs_conn_fill_param_sync we should
>  	put this reference after calling ip_vs_proc_conn().
>  	May be ip_vs_find_dest should check that p->pe matches
>  	svc->pe. ip_vs_try_bind_dest should provide p->pe too
>  	for this check. But we must somehow ignore new conns
>  	with PE if they don't have cp->dest (service) because
>  	it is risky to attach PE that is not held by svc.
>  	It is bad that the check for p->pe is before
>  	ip_vs_find_dest.

Can we agree upon that Simons patch "IPVS: Add persistence engine to connection entry"
solves this issue ?

The basic principle for param decoding is;
 - Unknown param: skip this entry and continue with next
 - Invalid param length: drop the buffer.
 - Invalid param data: skip this entry and continue with next
   (If possible to check)

There is a violation to this that I will correct:
 Checking for a terminating Zero in pe_name string causes a drop of entire buffer, not just the conn. entry.


>  	Example for parsing:
>
>  	- rename msgEnd/p to 'char *endp;' and move it before loop.
>  	It will have the 'p' role as before: to point to end
>  	of connection.
>
>  	before loop:
>  	endp = buffer + sizeof(struct ip_vs_sync_mesg_v2);
>
>  	In loop:
>
> +		p = endp;
> +		s = (union ip_vs_sync_conn *) endp;
> +		size = ntohs(s->v4.ver_size) & SVER_MASK;
> +		endp = p + size; <--- we are ready for 'continue'
>
>  	By this way endp should point to next connection in case
>  	we want to ignore current one at any time. 'p' will walk
>  	parameters as you do now. After that all checks for p should be
>  	with endp, I mean use 'if (p > endp)' here:
>
> +		if (p > buffer+buflen) {
> +			IP_VS_ERR_RL("bogus conn in sync message\n");
> +			return;
> +		}
>
No problem, a minor adj.

>  	- Note that pe_data is leaked when ip_vs_proc_conn() fails
>  	to create connection. May be PE info for non-templates
>  	should be ignored? And we need a way to know if
>  	ip_vs_proc_conn called ip_vs_conn_new at all and that
>  	it succeeded so that we can safely free pe_data.
>
>  	Simon should tell what happens if some PE updates
>  	ct->pe_data, may be we should replace it too for the
>  	case when ip_vs_proc_conn works with existing template?
>

I will have a look at Simons answer.

> v2 PATCH 4/4
>  	May be we should add configuration option if sync is enabled
>  	to default to version 0 because how we solve the problem if
>  	backup can not be upgraded?

That means that we need to have a "version 0 sending functions" as well.
I think that version 1 should be default, if you ran into problems activate ver 0.

>  	For IPVS_OPT_PE_NAME: because we have length better not to
>  	add zero terminator in sync message. It complicates the
>  	checks in backup. Or backup prefers to check with zero
>  	terminated string directly from message? In this case we
>  	should check for existing terminator.

My hart says, don't use terminating Zeroes when there is a length but:
"Since there is no space to add a trailing Zero in the buffer
 some changes has to be done. (I'm not going to make temp copy!)
 Length param needs to be added to ip_vs_pe_get() and ip_vs_pe_getbyname()
 which affects ip_vs_add_service() and  ip_vs_edit_service()"

Leave it as is or remove the trailing Zero thats the question ?

>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>


--
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
