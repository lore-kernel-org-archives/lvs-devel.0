From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Advice on RCU for IPVS
Date: Fri, 26 Feb 2010 15:00:20 +0100
Message-ID: <1267192820.9082.11.camel@edumazet-laptop>
References: <20100226031812.GC6111@verge.net.au>
Mime-Version: 1.0
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=gamma;
        h=domainkey-signature:received:received:subject:from:to:cc
         :in-reply-to:references:content-type:date:message-id:mime-version
         :x-mailer:content-transfer-encoding;
        bh=avnOLV2ieypBPxDhgxlW5xxiF6htNd/Tlna5lll7j6M=;
        b=FCtpO0DTFtK7h/umTCnCFx4eriwi14Q2Q+o9G4ZtIUmGFUGuU6M77R+wv1JgcUNmeb
         LpgKTi0zr1F/rlDkXUP64f+kVF8FR+qn17vzwhmCEabxXrvNxB38s6ZL8a3FZ1XSSPIc
         HsMHOfJuulsIL+PM6a4tFPdSSN8ur7snvUZAE=
In-Reply-To: <20100226031812.GC6111@verge.net.au>
Sender: lvs-devel-owner@vger.kernel.org
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="utf-8"
To: Simon Horman <horms@verge.net.au>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org

Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 14:18 +1100, Simon Horman a =C3=
=A9crit :
> Hi,
>=20
> I have been looking at converting the rwlocks in IPVS over to use RCU=
=2E
> A problem that I am facing is that the lblcr scheduler uses
> a write lock on list A and then taking a write lock on list B.
> Where list B is basically part of one of the elements of list A.
>=20
> This problem is present in ip_vs_lblcr_schedule() and
> the key code looks like this.
>=20
>=20
> 	/* First look in our cache */
> 	read_lock(&svc->sched_lock);
> 	en =3D ip_vs_lblcr_get(svc->af, tbl, &iph.daddr);
> 	if (en) {
> 		...
>=20
> 		/* Get the least loaded destination */
> 		read_lock(&en->set.lock);
> 		dest =3D ip_vs_dest_set_min(&en->set);
> 		read_unlock(&en->set.lock);
>=20
> 		...
>=20
> 			write_lock(&en->set.lock);
> 			m =3D ip_vs_dest_set_max(&en->set);
> 			if (m)
> 				ip_vs_dest_set_erase(&en->set, m);
> 			write_unlock(&en->set.lock);
>=20
> 		...
>=20
> 		/* Update our cache entry */
> 		write_lock(&en->set.lock);
> 		ip_vs_dest_set_insert(&en->set, dest);
> 		write_unlock(&en->set.lock);
> 	}
> 	read_unlock(&svc->sched_lock);
>=20
> dest is referenced counted and doesn't seem to need to be guarded
> by svc->sched_lock.
>=20
> It seems to me that this is quite difficult to convert over to RCU
> as there are write-side critical sections inside a read-side critical
> section.
>=20
> I investigated reference counting the return value of
> ip_vs_lblcr_get() or the return value of ip_vs_dest_set_max() and
> ip_vs_dest_set_insert(). But this seems to be difficult,
> especially at rmmod time.
>=20
> I also considered just making the whole thing a write-side critical s=
ection.
> Which seems to be somewhat of a sledge-hammer and result in
> a critical section that is much larger than I would like. Though
> no bigger than the existing area covered by the read-lock on
> svc->sched_lock.
>=20
> Any suggestions would be appreciated.

The code you copy/pasted seems really complex, I would suggest to make
it as simple as possible (using spinlocks for example instead of
rwlocks) before considering RCU conversion.



