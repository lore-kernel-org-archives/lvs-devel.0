From: Graeme Fowler <graeme@graemef.net>
Subject: Re: Unable to handle kernel paging request at virtual address
	f8c7a7e8
Date: Fri, 21 Nov 2008 09:38:59 +0000
Message-ID: <1227260339.30263.2.camel@squonk.lboro.ac.uk>
References: <S1756639AbYKTOrH/20081120144708Z+1723@vger.kernel.org>
	 <49257CE2.4050608@gmail.com> <49257EA0.4000905@gmail.com>
	 <49260B77.7040203@gmail.com>  <49260FE6.7080800@gmail.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <49260FE6.7080800@gmail.com>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
To: lvs-devel@vger.kernel.org

On Fri, 2008-11-21 at 09:33 +0800, James Zheng wrote:
> I got the error in "/var/log/message" after I installed the ipvsadmin 
> under the Centos 4.7,  and the server is down.

More than likely not related to IPVS, but to iptables.

> Do you know  how to fix the bug?

See this thread:

https://bugzilla.redhat.com/show_bug.cgi?id=456664

The error you posted shows that it happened when modprobe was trying to
unload a module. It may be a related issue to that bugzilla entry. My
advice would be to drop back to a previous kernel until the fix is
released.

Graeme

