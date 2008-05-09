From: "pierrick grasland" <pierrick.grasland@nexcom.fr>
Subject: Ipvsadm -e freeze
Date: Fri, 9 May 2008 10:22:55 +0200
Message-ID: <c2f80c020805090122i1deb833dpbe32cd4b0f21baf@mail.gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:message-id:date:from:sender:to:subject:mime-version:content-type:content-transfer-encoding:content-disposition:x-google-sender-auth;
        bh=HGlpvFO7465tHXfO/TysSzeBTI8h3PvFLGNj//NKriY=;
        b=H1GdysUMTXR9yC75O+M5csI3d7+8bkQxMAgcEkYmkNhzgpowu1nZa3qs9KPF0iWi85fkf4qZ+fTllpY8zME6qnCTN0VnEnspyrNj9kFtvHZjfnH6lxuQAJ75ZxufYs3AohJ4dahjg8Pu679zVEsLa0hpRAd75pb0ArPUMvxHDXQ=
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

Hello,

I'm actually trying to modify IPVS, but I encounter a weird problem.

When I activate debug_level (12) in /proc/sys/net/ipv4/vs/ and use
ipvsadm -e or ipvsadm -d after some test on my network, my director
freeze.

Actually, I test with the following :

ipvsadm -A -u 192.168.1.210:5060 -s rr [a new option] => no problem, works fine
ipvsadm -a -u 192.168.1.210:5060 -r 192.168.2.2:5060 -m => works fine.

IPVS start without problem, and LVS NAT is correctly working.

So, I'm starting my test, with only basic UDP packets. Until now, IPVS
has a normal behavior.

But, if I try (after my test, without packets sends to the director on
5060) to modify my configuration with ipvsadm -e or ipvsadm -d, my
director freeze completly. Not a single error message, nothing in the
log.

Did someone has a clue ?

Thanks,
--
Pierrick Grasland
