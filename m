From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [RFC PATCH net-next] ipvs: enable the scheduling of icmp packets
Date: Mon, 10 Aug 2015 16:53:27 -0700
Message-ID: <CALCkm3egudGkXm9QHk9Bvy9CM4YxXUcLgh_W28C+qEbak+wWLg@mail.gmail.com>
References: <1439171610-226215-1-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1508102208260.1843@ja.home.ssi.bg>
Mime-Version: 1.0
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc:content-type;
        bh=kBQ9S+rBCWj/+eGJiUS9YliUgb6/dnFNLUERGSmv1NI=;
        b=yamHNRZHp1FcBa39CZuFKJI6knzcxUOB5PxMRDdzcssD7ZM1TIJ/+5yNu9SzbxkL9Z
         HiNDrITVySMBYMtyeYMqGHxOv6tz+MClwgb9F4Ly3OblAL3zvpz481X4ZyCCySxHAw+d
         IIuW8plZw1YLSCF1LB+fV4rWaIDsuzG3XuYdVuIYx8N4nXEVZk5rTtZ42dcYwjYSbOZ5
         /KefIfNbkHuKiHUCyB5t9cIm5emhVcx+iVixVjEhFKoIEN1MSStCfPN1dmpoFHsy1OQv
         fsrk7BlmCm4X7WhQ0Bir4PxOIlFYp4n9arEGlSU/trM1zWHhzqWoMBRFOZ0/kJ3fiuJK
         1vZA==
In-Reply-To: <alpine.LFD.2.11.1508102208260.1843@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julian Anastasov <ja@ssi.bg>
Cc: Alex Gartrell <agartrell@fb.com>, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org, kernel-team <kernel-team@fb.com>

Hey Julian,

Thank you for your comments!

On Mon, Aug 10, 2015 at 1:51 PM, Julian Anastasov <ja@ssi.bg> wrote:
>> If the schedule_icmp sysctl is set, ICMP messages for unseen flows will be
>> handed off to the appropriate schedulers.  This is very necessary for us at
>> Facebook, because we ECMP load balance down to the IPVS instances and rely
>> on a deterministic scheduler rather than sync'ing, so a TCP SYN and an
>> ICMPv6 PACKET_TOO_BIG packet are unlikely to end up on the same ipvs host.
>
>         You mean related ICMP comes to one of the directors
> because it was scheduled randomly by routers and the IPVS
> scheduler will schedule it to the right real server even
> if the original TCP connection is on another director?
>
>         If I understand it correctly, this patch tries to
> schedule related ICMP only, right? And it creates new
> connection, for example, from ICMP-TCP_data packet?

Yeah, I'll break it down into more patches than one (because this is a
lot to review), but

>
>         commit bba54de5bdd1 ("ipvs: provide iph to schedulers")
> added iph to the schedule() method, now we need to provide also
> "bool inverse" ? Needed only for the SH scheduler...
> Another option is to add the inverse flag to struct ip_vs_iphdr.
> It will benefit functions like ip_vs_leave(), ->packet_xmit,
> anything that uses iph addresses.

yeah, this was the original reason for my other patch which
consolidates the iph filling.  I was actually thinking that, rather
than adding bool inverse, we should specify the type so that we don't
end up in a situation where we also need sloppy to be true.  I was
waiting to see what you thought.

>> @@ -420,6 +420,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
>>       struct ip_vs_dest *dest;
>>       __be16 _ports[2], *pptr;
>>       unsigned int flags;
>> +     __be16 client_port, svc_port;
>
>         sport and dport looks better to me

I'll incorporate this.

>
>>       if (svc->flags & IP_VS_SVC_F_PERSISTENT)
>> -             return ip_vs_sched_persist(svc, skb, pptr[0], pptr[1], ignored,
>> -                                        iph);
>> +             return ip_vs_sched_persist(svc, skb, client_port, svc_port,
>> +                                        ignored, iph);
>
>         We will need inverse flag for ip_vs_sched_persist
> because the addresses are reversed too :(

Ah, of course.

>
>>               ip_vs_conn_fill_param(svc->net, svc->af, iph->protocol,
>> -                                   &iph->saddr, pptr[0], &iph->daddr,
>> -                                   pptr[1], &p);
>> +                                   &iph->saddr, client_port, &iph->daddr,
>> +                                   svc_port, &p);
>
>         Above addresses may be reversed too.

Duh, I've got some python tests and I'll update them so that the real
deal will be fully tested, and then we should find a way to include
the tests with upstream to save future modifiers the effort.

>> -     if ((sch->type == SCTP_CID_INIT || sysctl_sloppy_sctp(ipvs)) &&
>> -         (svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
>> -                                   &iph->daddr, sh->dest))) {
>
>         So, the inverse flag should simply imply sloppy mode?
> Because if sloppy mode is disabled below code will not
> schedule the ICMP for non-INIT packet... Even, we should
> skip the 'sch = skb_header_pointer' code if inverse=1.
> What we need is just the port to be present in skb when
> inverse=1.

Yeah I was thinking about this.  I think that, rather than adding a
bool field for inverse to iph, we should add some kind of type field.
This field will be one of IP_VS_IPHDR_NORMAL, IP_VS_IPHDR_INVERSE,
IP_VS_IPHDR_ICMP, IP_VS_IPHDR_ICMP_INVERSE.  That way was can take
just the ports whenever we're looking for icmp.  This is probably good
anyway, because even in ICMPv6 where we have all of the fields, if we
intend to schedule all ICMP messages, we don't care if the SYN flag is
set or not.

>> +
>> +     if (sysctl_sloppy_tcp(ipvs)) {
>
>         if (sysctl_sloppy_tcp(ipvs) || inverse) {
> because inverse=1 means embedded TCP packet can be
> with any flags.

Yeah I thought about this and my concern is when we have ICMP with
ipip=true.  It's probably the case that that never happens unless
there's something scheduled, but should we call it out explicitly in a
comment or something?
> To unsubscribe from this list: send the line "unsubscribe lvs-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Alex Gartrell <agartrell@fb.com>
