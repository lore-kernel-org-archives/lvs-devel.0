From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[3]: kernel oops - do_ip_vs_get_ctl
Date: Sat, 21 Apr 2012 12:11:49 +0200 (CEST)
Message-ID: <856i5i0.baad648bc0bbda1d9e290168a4213443@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8BIT
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>
Cc: Ryan O'Hara <rohara@redhat.com>, lvs-devel@vger.kernel.org

Hello 
>Subject: Re[2]: kernel oops - do_ip_vs_get_ctl
>
>Hello,
>
>On Fri, 20 Apr 2012, Hans Schillstrom wrote:
>
>> >On Fri, 20 Apr 2012, Ryan O'Hara wrote:
>> >
>> >> 
>> >> I frequently get a kernel oops in do_ip_vs_get_ctl when starting keepalived on
>> >> a 3.3.0 kernel. I'm attaching the trace from /var/log/messages. Has anyone
>> >> encountered this problem and if so is there a patch available? Much
>> >> appreciated.
>> >
[snip]

>> Do you prepare a patch or should I do it  ?
>
>	I'm stopping doing more patches until Simon takes
>the previous changes, so that we can use some fresh tree.
>You can try fixing this problem if you think you have
>recent changes.
>
OK I'll take care of this and double check with Simon that we have the same view of patches

Regards 
Hans Schillstrom <hans@schillstrom.com>


