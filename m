From: "Ryan O'Hara" <rohara@redhat.com>
Subject: Re: [PATCH] ipvsadm: fix list_daemon to handle master/backup status
 in either position
Date: Thu, 09 Feb 2012 13:36:50 -0600
Message-ID: <4F342052.8040400@redhat.com>
References: <4F33EB48.8010708@redhat.com> <4F34056F.3010509@ahsoftware.de>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <4F34056F.3010509@ahsoftware.de>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"; format="flowed"
To: Alexander Holler <holler@ahsoftware.de>
Cc: lvs-devel@vger.kernel.org

On 02/09/2012 11:42 AM, Alexander Holler wrote:
> Am 09.02.2012 16:50, schrieb Ryan O'Hara:
>> Attached is a patch that fixes the list_daemon function such that it
>> does not assume that the master sync daemon status is always in the
>> first position and master sync daemon status is always in the second
>> position.
>>
>> If libipvs uses the netlink interface to retrieve sync daemon status,
>> the results are not guaranteed to follow this ordering. As explained in
>> a previous email, if libipvs uses the netlink interface to retrieve sync
>> daemon status while only a backup sync daemon is running, the backup
>> sync daemon status will but in the first position (index 0). This
>> differs from the getsockopt interface, which would always put master
>> sync daemon status in first position and backup sync daemon status in
>> the second position, even when only backup sync daemon exists. Solution
>> is to make ipvsadm check both elements of the array for master and
>> backup.
>>
>> Ryan
>
> I've fixed that through letting the netlink-api reporting the same as
> without netlink.
>
> Don't know what solutions should be prefered.
>
> Regards,
>
> Alexander

Thanks for the patch. After taking a close look at your patch, I believe 
it will fix the problem.

I'm also unsure about which is the preferred solution. I decided to fix 
it in ipvsadm directly because (it seemed) ipvsadm was making incorrect 
assumptions about the master/backup sync daemon status being in at a 
specific index. That said, I'm find with your patch. Keeping the strict 
ordering is just as reasonable.

Ryan
