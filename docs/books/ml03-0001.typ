#import "bookmaster/bookmaster.typ": *

#show: book.with(
  title: "BREXX/370 for MVS 3.8j",
  subtitle: "User's Guide",
  short-title: "BREXX/370 User's Guide",
  number: "ML03-0001-0",
  date: "October 2026",
  authors: ("Peter Jacob", "Mike Großmann"),
  edition: [
    #text(font: head-font, weight: "bold", size: 11pt)[First Edition (October 2026)]

    This edition applies to Version 3 Release 0 of BREXX/370
    (BREXX/370 3.0.0), as built with cc370 1.5.0 and libc370 2.6, and to
    all subsequent releases and modifications until otherwise indicated in
    new editions.

    *Draft.* The chapters are being converted from the BREXX/370 User's
    Guide and checked against BREXX/370 3.0; chapters still to be converted
    say so.

    BREXX was written by Vasilis Vlachoudis. Peter Jacob and Mike Großmann
    ported it to MVS 3.8j as BREXX/370, with the support of Jason Winter and
    Jürgen Winkelmann, and make its releases. BREXX is licensed under the
    GNU General Public License v2.0.

    Comments on this book may be addressed to the issue tracker of the
    mvslovers/brexx370 repository on GitHub.

    © Copyright Peter Jacob and Mike Großmann 2026. This book is part of
    BREXX/370. It may be copied, changed and distributed under the same
    terms as BREXX/370: the GNU General Public License, version 2.
  ],
)

#part("index.html", title: [BREXX/370 User's Guide])[
#titlepage()
#contents()
#figures()

#heading(numbering: none)[About This Book] <about>

This book explains how to install BREXX/370 on MVS 3.8j, how to run REXX programs in TSO and in batch, how they find each other, and how they work with TSO and MVS.

== How This Book Is Organized

#deflist(width: 1.35in,
  [Chapter 1], [“Introducing BREXX/370”.],
  [Chapter 2], [“Installing BREXX/370”.],
  [Chapter 3], [“Running REXX Programs”.],
  [Chapter 4], [“Finding and Calling Execs”.],
  [Chapter 5], [“Working with TSO and MVS”.],
  [Chapter 6], [“Debugging”.],
  [Chapter 7], [“Restrictions”.],
  [Appendix A], [“Migrating from V2R5M3”.],
)

== Related Publications

#deflist(width: 1.35in,
  [ML03-0002], [_BREXX/370 Reference_],
  [ML03-0003], [_BREXX/370 Library and Samples_],
)

#mainmatter()
]
#set page(numbering: "1")

#part("ug-intro.html", include "guide/ug-intro.typ")
#part("ug-install.html", include "guide/ug-install.typ")
#part("ug-run.html", include "guide/ug-run.typ")
#part("ug-calling.html", include "guide/ug-calling.typ")
#part("ug-tso.html", include "guide/ug-tso.typ")
#part("ug-debug.html", include "guide/ug-debug.typ")
#part("ug-restrict.html", include "guide/ug-restrict.typ")

#show: appendices
#part("ug-migrate.html", include "guide/ug-migrate.typ")

#part("index-terms.html", title: [Index])[
#heading(numbering: none)[Index]
#make-index()
]
