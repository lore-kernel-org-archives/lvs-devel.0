From: Vince Busam <vbusam@google.com>
Subject: IPv6 and userspace interface backwards compatibility
Date: Mon, 07 Apr 2008 11:38:36 -0700
Message-ID: <47FA6A2C.1020609@google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha1; c=relaxed/relaxed; d=google.com; s=beta;
	t=1207593495; bh=O2uFmcsWKJZAVV7yoHzMU/3dwmU=;
	h=DomainKey-Signature:Message-ID:Date:From:User-Agent:MIME-Version:
	 To:Subject:Content-Type:Content-Transfer-Encoding; b=tJpsnn2LxPDNp
	+exwR/1R7Khj8TQ/4F6akTTLwZMM0Ft/diMaxawrRAXZWcA4EnZwCehCfRUxmHVNKJ/
	WwjSzg==
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: lvs-devel@vger.kernel.org

Looking at adding IPv6 support, I notice the {get,set}sockopt interface 
with userspace uses 32 bit address fields.  Would it be better to change 
the current interface to use 128 bits for the address, breaking backwards 
compatibility, or is it important to keep that compatibility and we'd be 
better creating (and maintaining) a separate interface?

For example, would it be better to just add/modify a couple fields in 
structs like so
struct ip_vs_service_entry {
     /* which service: user fills in these */
     u_int16_t        af;
     u_int16_t               protocol;
     union addr {
         __be32                  addr_ipv4;
         struct in6_addr        addr_ipv6;
     }
     __be16                  port;
     u_int32_t               fwmark;         /* firwall mark of service */

     /* service options */
     char                    sched_name[IP_VS_SCHEDNAME_MAXLEN];
     unsigned                flags;          /* virtual service flags*/
     unsigned                timeout;        /* persistent timeout */
     __be32                  netmask;        /* persistent netmask */

     /* number of real servers */
     unsigned int            num_dests;

     /* statistics */
     struct ip_vs_stats_user stats;
};

Or rename it as a different struct (say ip6_vs_service_entry), and add a 
set of IP6_VS_SO_* option numbers?

Vince
