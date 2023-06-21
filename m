From: Jani Nikula <jani.nikula@linux.intel.com>
Subject: Re: [PATCH 09/11] sysctl: Remove the end element in sysctl table
 arrays
Date: Wed, 21 Jun 2023 16:15:46 +0300
Message-ID: <878rcd2by5.fsf@intel.com>
References: <20230621091000.424843-1-j.granados@samsung.com>
 <CGME20230621094824eucas1p2b6adfbd3f15ff3665674917f419b25d3@eucas1p2.samsung.com>
 <20230621094817.433842-1-j.granados@samsung.com>
 <87o7l92hg8.fsf@intel.com> <20230621130614.s36w4u7dzmb5d5p3@localhost>
Mime-Version: 1.0
Return-path: <bpf+bounces-3021-glkb-bpf=m.gmane-mx.org@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1687353450; x=1718889450;
  h=from:to:cc:subject:in-reply-to:references:date:
   message-id:mime-version;
  bh=9eMWiG7JI6/9oPvFtdl/3iOGYIkGUexXwjKhm4v9hgQ=;
  b=bCKCupaYl+EEOS5QZZqFy7/P+ML1IyBgPHBQi6X+UU8780XpNTpf4U6B
   gFrDdR8bKiHWep8CBCfe+n3QcNA4kM2mVaRIrbZBZZkzO5Pc41a93wxH/
   deR0l3dJH1ofc/Owpgw21aSPf9Oltci2/V99rUNO20vRvyv0ZsS5VB7Ts
   sKB8gqtYRiN3W+n++5YvMKBFRyWHoyBW5/rm47wwDkrLmFGQYaz2Uhi/e
   WBbKSEilvIyOf60jil0GTDrDM6Wa+s8i8SKVh3rSRX6UE6fHg3afFOtl+
   OPjnTHLAfOkzS0xosvF88juEap/GL0nYFRRaas3CCUFF95JN9fehY2Wu8
   Q==;
In-Reply-To: <20230621130614.s36w4u7dzmb5d5p3@localhost>
List-Id: <lvs-devel.vger.kernel.org>
List-Subscribe: <mailto:bpf+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:bpf+unsubscribe@vger.kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joel Granados <j.granados@samsung.com>
Cc: mcgrof@kernel.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <hca@linux.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Alexander Gordeev <agordeev@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@linux.ibm.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Russ Weight <russell.h.weight@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Phillip Potter <phil@philpotter.co.uk>, Clemens Ladisch <clemens@ladisch.de>, Arnd Bergmann <arnd@arndb.de>, Corey Minyard <minyard@acm.org>, Theodore Ts'o <tytso@mit.edu>, Jason

On Wed, 21 Jun 2023, Joel Granados <j.granados@samsung.com> wrote:
> On Wed, Jun 21, 2023 at 02:16:55PM +0300, Jani Nikula wrote:
>> On Wed, 21 Jun 2023, Joel Granados <j.granados@samsung.com> wrote:
>> > Remove the empty end element from all the arrays that are passed to the
>> > register sysctl calls. In some files this means reducing the explicit
>> > array size by one. Also make sure that we are using the size in
>> > ctl_table_header instead of evaluating the .procname element.
>> 
>> Where's the harm in removing the end elements driver by driver? This is
>> an unwieldy patch to handle.
>
> I totally agree. Its a big one!!! but I'm concerned of breaking bisectibility:
> * I could for example separate all the removes into separate commits and
>   then have a final commit that removes the check for the empty element.
>   But this will leave the tree in a state where the for loop will have
>   undefined behavior when it looks for the empty end element. It might
>   or might not work (probably not :) until the final commit where I fix
>   that.
>
> * I could also change the logic that looks for the final element,
>   commit that first and then remove the empty element one commit per
>   driver after that. But then for all the arrays that still have an
>   empty element, there would again be undefined behavior as it would
>   think that the last element is valid (when it is really the sentinel).
>
> Any ideas on how to get around these?

First add size to the register calls, and allow the last one to be
sentinel but do not require the sentinel.

Start removing sentinels, adjusting the size passed in.

Once enough sentinels have been removed, add warning if the final entry
is a sentinel.

Never really remove the check? (But surely you can rework the logic to
not count the number of elements up front, only while iterating.)


BR,
Jani.

>> 
>> > diff --git a/drivers/gpu/drm/i915/i915_perf.c b/drivers/gpu/drm/i915/i915_perf.c
>> > index f43950219ffc..e4d7372afb10 100644
>> > --- a/drivers/gpu/drm/i915/i915_perf.c
>> > +++ b/drivers/gpu/drm/i915/i915_perf.c
>> > @@ -4884,24 +4884,23 @@ int i915_perf_remove_config_ioctl(struct drm_device *dev, void *data,
>> >  
>> >  static struct ctl_table oa_table[] = {
>> >  	{
>> > -	 .procname = "perf_stream_paranoid",
>> > -	 .data = &i915_perf_stream_paranoid,
>> > -	 .maxlen = sizeof(i915_perf_stream_paranoid),
>> > -	 .mode = 0644,
>> > -	 .proc_handler = proc_dointvec_minmax,
>> > -	 .extra1 = SYSCTL_ZERO,
>> > -	 .extra2 = SYSCTL_ONE,
>> > -	 },
>> > +		.procname = "perf_stream_paranoid",
>> > +		.data = &i915_perf_stream_paranoid,
>> > +		.maxlen = sizeof(i915_perf_stream_paranoid),
>> > +		.mode = 0644,
>> > +		.proc_handler = proc_dointvec_minmax,
>> > +		.extra1 = SYSCTL_ZERO,
>> > +		.extra2 = SYSCTL_ONE,
>> > +	},
>> >  	{
>> > -	 .procname = "oa_max_sample_rate",
>> > -	 .data = &i915_oa_max_sample_rate,
>> > -	 .maxlen = sizeof(i915_oa_max_sample_rate),
>> > -	 .mode = 0644,
>> > -	 .proc_handler = proc_dointvec_minmax,
>> > -	 .extra1 = SYSCTL_ZERO,
>> > -	 .extra2 = &oa_sample_rate_hard_limit,
>> > -	 },
>> > -	{}
>> > +		.procname = "oa_max_sample_rate",
>> > +		.data = &i915_oa_max_sample_rate,
>> > +		.maxlen = sizeof(i915_oa_max_sample_rate),
>> > +		.mode = 0644,
>> > +		.proc_handler = proc_dointvec_minmax,
>> > +		.extra1 = SYSCTL_ZERO,
>> > +		.extra2 = &oa_sample_rate_hard_limit,
>> > +	}
>> >  };
>> 
>> The existing indentation is off, but fixing it doesn't really belong in
>> this patch.
>
> Agreed. But I actually was trying to fix something that checkpatch
> flagged. I'll change these back (which will cause this patch to be
> flagged).
>
> An alternative solution would be to fix the indentation as part of the
> preparation patches. Tell me what you think.
>
> Thx
>
>> 
>> BR,
>> Jani.
>> 
>> 
>> -- 
>> Jani Nikula, Intel Open Source Graphics Center

-- 
Jani Nikula, Intel Open Source Graphics Center

