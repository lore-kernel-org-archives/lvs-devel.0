From: Julian Anastasov <ja@ssi.bg>
Subject: Re: SIP persistence engine - incorrect search of callid header
Date: Fri, 5 Feb 2016 22:22:31 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1602052212290.1597@ja.home.ssi.bg>
References: <CANHHuCWbUAa1UqGCNTY1uODcXZAtxyCw6uPbSQeweA3oRWxPOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1214409205-1454703751=:1597"
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <CANHHuCWbUAa1UqGCNTY1uODcXZAtxyCw6uPbSQeweA3oRWxPOw@mail.gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
To: Marco Angaroni <marcoangaroni@gmail.com>
Cc: lvs-devel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1214409205-1454703751=:1597
Content-Type: TEXT/PLAIN; charset="utf-8"
Content-Transfer-Encoding: 8bit


	Hello,

On Fri, 5 Feb 2016, Marco Angaroni wrote:

> Hello,
> 
> the IPVS SIP persistence engine is not able to parse the SIP header
> “Call-ID” when such header is inserted in the first positions of the
> SIP message.
> 
> When IPVS is configured with '--pe sip' option (ex. ipvsadm -A -u
> 10.0.2.15:5060 -s rr --pe sip -p 120 -o), you can verify that messages
> like this one do not create entries in the connection template table
> (ipvsadm -Lcn --persistent-conn), .
> 
> SIP/2.0 200 OK
> Call-ID: a84b4c76e66710@pc33.atlanta.com
> Via: SIP/2.0/UDP pc33.atlanta.com;branch=z9hG4bK776asdhds
> Max-Forwards: 70
> To: Bob <sip:bob@biloxi.com>
> From: Alice <sip:alice@atlanta.com>;tag=1928301774
> CSeq: 314159 INVITE
> Contact: <sip:alice@pc33.atlanta.com>
> Content-Length: 0
> 
> Instead when the “Call-ID” is positioned down (after “From” header for
> example), the header is recognized.
> 
> This is due to the data offset used in get_callid function call inside
> ip_vs_pe_sip.c file: since dptr already points to the start of the SIP
> message, the value of dataoff should be initially 0. Otherwise the
> header is searched starting from some bytes after the first character
> of the SIP message.
> 
> This patch , in my tests, solved the problem. I'm using the sources of
> kernel 3.10.0-229.20.1.el7.x86_64 (RH7).
> 
>  --- a/ip_vs_pe_sip.c 2015-09-24 17:47:25.000000000 +0200
> +++ b/ip_vs_pe_sip.c 2016-01-28 15:08:34.309934600 +0100
> @@ -88,7 +88,7 @@
> dptr = skb->data + dataoff;
> datalen = skb->len - dataoff;
> 
> - if (get_callid(dptr, dataoff, datalen, &matchoff, &matchlen))
> + if (get_callid(dptr, 0, datalen, &matchoff, &matchlen))
> return -EINVAL;

	Your fix looks correct but you have to provide
well formed patch for recent kernel source according to 
Documentation/SubmittingPatches:

- correct Subject with "ipvs: " prefix
- Signed-off-by line
- diff created in linux/ dir (for net/netfilter/ipvs/ip_vs_pe_sip.c)

	You can browse the mailing list for good examples:

http://archive.linuxvirtualserver.org/html/lvs-devel/

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1214409205-1454703751=:1597--
