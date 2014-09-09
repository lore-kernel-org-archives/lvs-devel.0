From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH ipvs,v4 19/20] ipvs: use the new dest addr family field
Date: Tue, 9 Sep 2014 16:22:38 -0700
Message-ID: <540F8BBE.9040808@fb.com>
References: <1409301549-5284-1-git-send-email-agartrell@fb.com> <1409301549-5284-20-git-send-email-agartrell@fb.com> <alpine.LFD.2.11.1408291259510.4876@ja.home.ssi.bg> <5400EE48.5060007@fb.com> <alpine.LFD.2.11.1409092229380.4943@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=fb.com; h=message-id : date : from :
 mime-version : to : cc : subject : references : in-reply-to : content-type
 : content-transfer-encoding; s=facebook;
 bh=kSeyW6lijxtIuiWGzubU3I+VHWGFTEpzHGeh3NkVTLw=;
 b=HfnHW813KpFev+g6D1xdgJ594ej21ESr3K2446L3acLF8t/k0hJyirM3+Ro9+Jg/6JE3
 1tkoqCvv08ssTe6GOmERhK0fqXQst6c8q4y0/zMkgIM2/KCzW4ZJh8R/5qkjQyLKC6o6
 FAcp+ZABeCWWsV2T6A+/zcO6wOcoHRDS8rA= 
In-Reply-To: <alpine.LFD.2.11.1409092229380.4943@ja.home.ssi.bg>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Julian Anastasov <ja@ssi.bg>
Cc: horms@verge.net.au, lvs-devel@vger.kernel.org, kernel-team@fb.com

Hey Julian,

On 9/9/14 12:41 PM, Julian Anastasov wrote:
>
> 	Hello Alex,
>
> On Fri, 29 Aug 2014, Alex Gartrell wrote:
>
>> So, if I understand correctly, we'll wait until it lands in net-next and then
>> I'll submit these patches to netdev?
>
> 	I think, you can now submit the patchset, net was
> merged to net-next, so you need a fresh net-next copy.

I've picked these patches onto net-next and am going to test it now. 
Will submit the patchset shortly.

> 	Also, can you try my ipvsadm patches to check for
> possible problems in the connection listing, so that we
> can safely apply them to the ipvsadm tree.
>


All of the ipvsadm changes work as expected, but it needs an additional 
tweak:

diff --git a/ipvsadm.c b/ipvsadm.c
index d12070e..ef19091 100644
--- a/ipvsadm.c
+++ b/ipvsadm.c
@@ -1629,7 +1629,7 @@ print_service_entry(ipvs_service_entry_t *se, 
unsigned int format)
                         fprintf(stderr, "addrport_to_anyname fails\n");
                         exit(1);
                 }
-               if (!(format & FMT_RULE) && (se->af != AF_INET6))
+               if (!(format & FMT_RULE) && (e->af != AF_INET6))
                         dname[28] = '\0';

                 if (format & FMT_RULE) {

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
