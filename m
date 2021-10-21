From: =?UTF-8?q?Thomas=20Wei=C3=9Fschuh?= <linux@weissschuh.net>
Subject: [PATCH] ipvs: autoload ipvs on genl access
Date: Thu, 21 Oct 2021 15:02:55 +0200
Message-ID: <20211021130255.4177-1-linux@weissschuh.net>
Mime-Version: 1.0
Content-Transfer-Encoding: base64
Return-path: <lvs-devel-owner@vger.kernel.org>
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=weissschuh.net;
        s=mail; t=1634821397;
        bh=4YdKHvN93yhq8+9juz+qrXE/FDAOs4WQpC3s82kIpYY=;
        h=From:To:Cc:Subject:Date:From;
        b=ANysfixJonxu2KHFisv92/hdJqmcHpqRwjYtE1I7s3BPC6PnveWTakAuG1qfPg6X+
         T5rxYNJYSX99ixp8eoRnB5i59zo4W1iT1+LuZMXJSze+uB8dzLHVuJDcRR8Frm+8TR
         3pZBn7AyWdjrgsa3c5UAJNVBnwfrPvzZDiX2KETc=
List-ID: <lvs-devel.vger.kernel.org>
Content-Type: text/plain; charset="macroman"
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@netfilter.org>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, netdev@vger.kernel.org, lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org
Cc: =?UTF-8?q?Thomas=20Wei=C3=9Fschuh?= <linux@weissschuh.net>, linux-kernel@vger.kernel.org

VGhlIGtlcm5lbCBwcm92aWRlcyB0aGUgZnVuY3Rpb25hbGl0eSB0byBhdXRvbWF0aWNhbGx5IGxv
YWQgbW9kdWxlcwpwcm92aWRpbmcgZ2VubCBmYW1pbGllcy4gVXNlIHRoaXMgdG8gcmVtb3ZlIHRo
ZSBuZWVkIGZvciB1c2VycyB0bwptYW51YWxseSBsb2FkIHRoZSBtb2R1bGUuCgpTaWduZWQtb2Zm
LWJ5OiBUaG9tYXMgV2Vpw59zY2h1aCA8bGludXhAd2Vpc3NzY2h1aC5uZXQ+Ci0tLQogbmV0L25l
dGZpbHRlci9pcHZzL2lwX3ZzX2N0bC5jIHwgMiArKwogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0
aW9ucygrKQoKZGlmZiAtLWdpdCBhL25ldC9uZXRmaWx0ZXIvaXB2cy9pcF92c19jdGwuYyBiL25l
dC9uZXRmaWx0ZXIvaXB2cy9pcF92c19jdGwuYwppbmRleCAyOWVjM2VmNjNlZGMuLjBmZjk0YzY2
NjQxZiAxMDA2NDQKLS0tIGEvbmV0L25ldGZpbHRlci9pcHZzL2lwX3ZzX2N0bC5jCisrKyBiL25l
dC9uZXRmaWx0ZXIvaXB2cy9pcF92c19jdGwuYwpAQCAtNDgsNiArNDgsOCBAQAogCiAjaW5jbHVk
ZSA8bmV0L2lwX3ZzLmg+CiAKK01PRFVMRV9BTElBU19HRU5MX0ZBTUlMWShJUFZTX0dFTkxfTkFN
RSk7CisKIC8qIHNlbWFwaG9yZSBmb3IgSVBWUyBzb2Nrb3B0cy4gQW5kLCBbZ3NdZXRzb2Nrb3B0
IG1heSBzbGVlcC4gKi8KIHN0YXRpYyBERUZJTkVfTVVURVgoX19pcF92c19tdXRleCk7CiAKCmJh
c2UtY29tbWl0OiBkOWFhYWYyMjMyOTdmNjE0NmQ5ZDdmMzZjYWNhOTI3YzkyYWI4NTVhCi0tIAoy
LjMzLjEKCg==
