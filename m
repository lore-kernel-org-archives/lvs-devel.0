From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Tue, 06 Jan 2015 13:56:56 +0100
Message-ID: <54ABDB98.9060504@suse.cz>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com> <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg> <5481173A.9060308@smart-weblications.de> <alpine.LFD.2.11.1412051126090.2522@ja.home.ssi.bg> <5481B944.2000002@smart-weblications.de> <alpine.LFD.2.11.1412072019410.1885@ja.home.ssi.bg> <54858948.2060007@smart-weblications.de> <alpine.LFD.2.11.1412082234350.2401@ja.home.ssi.bg> <5486CD9D.4060107@smart-weblications.de> <alpine.LFD.2.11.1412102331230.4043@ja.home.ssi.bg> <5489A465.6090305@smart-weblications.de> <alpine.LFD.2.11.1412132211260.3229@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <stable-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20120113;
        h=sender:message-id:date:from:user-agent:mime-version:to:cc:subject
         :references:in-reply-to:content-type:content-transfer-encoding;
        bh=q5aNwpTa3lRJWXukctcn4SGfjXR0p/p3gQ94xWVyzGk=;
        b=QrJxiwQk5N1IOsy0yXeYfvXQ8L6FePSVOd7ZSxFhx8f6DHwyDcpPhDTt5gfEWbGeiE
         l8RzCS/UO6ba3kinErLGz4YNWiIWk+e8AV88QJkPbkgZGezci0BEpeg8KGnqoyQYbVZ0
         LgJZNvv/Y5+tWJO43pJPn6ffb4XJVID4k/kW0OraWlvq7YHjLCyaNzNmW1WFqE7kaPqT
         VotI0GO5+lKzb+rfC38rZcnymtxQQrW1Ge3peD9SjtXL0AuRXLFIx+42auYUMKDL7kdl
         qIeq6KvS7vktobBczHNo9O6pH73GwrtyxmBvU8kumh8+rvJrU5KxSsF7Lq2d6C3dsQe8
         +FRQ==
In-Reply-To: <alpine.LFD.2.11.1412132211260.3229@ja.home.ssi.bg>
Sender: stable-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: Julian Anastasov <ja@ssi.bg>, Smart Weblications GmbH - Florian Wiessner <f.wiessner@smart-weblications.de>
Cc: Steffen Klassert <steffen.klassert@secunet.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org

On 12/13/2014, 09:19 PM, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 11 Dec 2014, Smart Weblications GmbH - Florian Wiessner wrote:
> 
>>>> [  512.485323] CPU: 4 PID: 28142 Comm: vsftpd Not tainted 3.12.33 #5
>>>
>>> 	Above "#5" is same as previous oops. It means kernel
>>> is not updated. Or you updated only the IPVS modules after
>>> applying the both patches?
>>
>> I did it with make-kpkg --initrd linux_image which only rebuilt the modules,
>> correct. I can retry with make clean before building the package
> 
> 	I just tested PASV and PORT with 3.12.33 including
> both patches (seq adj fix + ip_route_me_harder fix) and do not
> see any crashes in nf_ct_seqadj_set. If you still have problem
> with FTP send me more info offlist.
> 
>>> 	You can also try without FTP tests to see if there
>>> are oopses in xfrm, so that we can close this topic and then
>>> to continue for the FTP problem on IPVS lists without
>>> bothering non-IPVS people.
>>>
>>
>> yeah, it seems that the xfrm issue is away.
> 
> 	Thanks for the confirmation!

Great! Thanks for tracking it down.

So what should be done to fix the issue in stable 3.12? Are those
patches needed in the upstream kernel too? In that case I suppose it
will propagate to me through upstream. Otherwise, could you send "3.12
only" patches to stable@ so that I can apply them?

thanks,
-- 
js
suse labs
