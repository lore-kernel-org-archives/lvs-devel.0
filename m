From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v1 4/5] treewide: use get_random_bytes when
 possible
Date: Wed, 5 Oct 2022 21:45:22 -0700
Message-ID: <202210052144.5DA3690D@keescook>
References: <20221005214844.2699-1-Jason@zx2c4.com>
 <20221005214844.2699-5-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=sourceforge.net; s=x; h=In-Reply-To:Content-Type:MIME-Version:References:
 Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:
 Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
 Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:
 List-Subscribe:List-Post:List-Owner:List-Archive;
 bh=BXKZz/gOYpFYEK/kvAD1ks5ZMqdWWvWPR9euDTlMinY=; b=YfMKQNNiRHqzUWZA0vmarUWN6y
 +BdhXfmE8ArjsMKknNaBeYZNn5VjN0hJATxAIkx/fUmRWtvGKnTjk/jwtmZmU/DGCRMWzNPLcGw4C
 7y2+0lcW5CztTXneGfbMNFfI6ZKOHjui6jrevoxTYySdwSg7IcRh8Tlxt8K8+ZocktEA=;
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=sf.net; s=x
 ;
 h=In-Reply-To:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To
 :From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
 Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
 :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
 List-Post:List-Owner:List-Archive;
 bh=BXKZz/gOYpFYEK/kvAD1ks5ZMqdWWvWPR9euDTlMinY=; b=he1NcgT/vp8EbpIObf+i8QgNq6
 AWjsmtfyrwWgIMyYeXtjwOhaCkcNzDJXHSb8IzZN/7psrJlZxTFJSG2+WIFg6dk4mpC+crT48mXox
 JzVeqF7HczzG/ZZ3rokDLyk48PGOJBA84yMhKNxsK+dYGH6Rd4ZpSo81vCTnM0Dk9h7Q=;
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=in-reply-to:content-disposition:mime-version:references:message-id
 :subject:cc:to:from:date:from:to:cc:subject:date;
 bh=BXKZz/gOYpFYEK/kvAD1ks5ZMqdWWvWPR9euDTlMinY=;
 b=Pa5J7iVIfOPPpc5FnD+VCPFKYUv3DdEsBgX8F3veGLnr0MqCAKKnFqdt9Zn7I1vA4a
 hp/m/n+zFRiftLounW3GI1Yh9t5CRw9Qy1PoS1A+KhEfND0rtCnNn/VAYMO7oSLOURb7
 x/xHspG9KrvXOaDvidgpTqZEY9MLlutH21Sdk=
Content-Disposition: inline
In-Reply-To: <20221005214844.2699-5-Jason@zx2c4.com>
List-Id: <lvs-devel.vger.kernel.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>, 
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Andrew Lunn <andrew@lunn.ch>, "Darrick J . Wong" <djwong@kernel.org>, Ulf Hansson <ulf.hansson@linaro.org>, dri-devel@lists.freedesktop.org, Andrii Nakryiko <andrii@kernel.org>, Hans Verkuil <hverkuil@xs4all.nl>, linux-sctp@vger.kernel.org, "Md . Haris Iqbal" <haris.iqbal@ionos.com>, Miquel Raynal <miquel.raynal@bootlin.com>, Christoph Hellwig <hch@lst.de>, Andy Gospodarek <andy@greyhouse.net>, Sergey Matyukevich <geomatsi@gmail.com>, Rohit Maheshwari <rohitm@chelsio.com>, Michael Ellerman <mpe@ellerman.id.au>, ceph-devel@vger.kernel.org, Christophe Leroy <christophe.leroy@csgroup.eu>, Jozsef Kadlecsik <kadlec@netfilter.org>, Nilesh Javali <njavali@marvell.com>, Jean-Paul Roubelat <jpr@f6fbb.org>, Dick Kennedy <dick.kennedy@broadcom.com>, Jay Vosburgh <j.vosburgh@gmail.com>, Potnuri Bharat Teja <bharat@chelsio.com>, Vinay Kumar Yadav <vinay.yadav@chelsio.com>, linux-nfs@vg

On Wed, Oct 05, 2022 at 11:48:43PM +0200, Jason A. Donenfeld wrote:
> The prandom_bytes() function has been a deprecated inline wrapper around
> get_random_bytes() for several releases now, and compiles down to the
> exact same code. Replace the deprecated wrapper with a direct call to
> the real function.

Global search/replace matches. :)

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
