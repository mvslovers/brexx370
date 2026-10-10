#import "bookmaster/bookmaster.typ": *

#show: book.with(
  title: "BREXX/370 for MVS 3.8j",
  subtitle: "Reference",
  short-title: "BREXX/370 Reference",
  product: "BREXX/370",
  number: "ML03-0002-0",
  date: "October 2026",
  authors: ("Peter Jacob", "Mike Großmann"),
  edition: [
    #text(font: head-font, weight: "bold", size: 11pt)[First Edition (October 2026)]

    This edition applies to Version 3 Release 0 of BREXX/370
    (BREXX/370 3.0.0), as built with CC/370 1.5.0 and LIBC/370 2.6, and to
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

#part("index.html", title: [BREXX/370 Reference])[
#titlepage()
#contents()
#figures()

#heading(numbering: none)[About This Book] <about>

This book describes the REXX language as BREXX/370 implements it, and the functions and host command environments that BREXX/370 adds for MVS.

== How This Book Is Organized

#deflist(width: 1.35in,
  [Chapter 1], [“Tokens, Terms and Expressions”.],
  [Chapter 2], [“Instructions”.],
  [Chapter 3], [“Templates for PARSE, ARG and PULL”.],
  [Chapter 4], [“Compound and Special Variables”.],
  [Chapter 5], [“Built-in Functions”.],
  [Chapter 6], [“Host Command Environments”.],
  [Chapter 7], [“Additional Kernel Functions”.],
  [Chapter 8], [“Global Variables”.],
  [Chapter 9], [“Data Set Functions”.],
  [Chapter 10], [“TSO Functions”.],
  [Chapter 11], [“Arrays, Matrices and Linked Lists”.],
  [Chapter 12], [“VSAM”.],
  [Chapter 13], [“TCP/IP”.],
  [Chapter 14], [“The FSS Host Command Environment”.],
  [Chapter 15], [“Calling External Programs”.],
)

== Related Publications

#deflist(width: 1.35in,
  [ML03-0001], [_BREXX/370 User's Guide_],
  [ML03-0003], [_BREXX/370 Library and Samples_],
)

#mainmatter()
]
#set page(numbering: "1")

#part("lang-terms.html", include "ref/lang-terms.typ")
#part("lang-instr.html", include "ref/lang-instr.typ")
#part("lang-templates.html", include "ref/lang-templates.typ")
#part("lang-vars.html", include "ref/lang-vars.typ")
#part("lang-builtin.html", include "ref/lang-builtin.typ")
#part("ext-address.html", include "ref/ext-address.typ")
#part("ext-kernel.html", include "ref/ext-kernel.typ")
#part("ext-global.html", include "ref/ext-global.typ")
#part("ext-dataset.html", include "ref/ext-dataset.typ")
#part("ext-tso.html", include "ref/ext-tso.typ")
#part("ext-array.html", include "ref/ext-array.typ")
#part("ext-vsam.html", include "ref/ext-vsam.typ")
#part("ext-tcpip.html", include "ref/ext-tcpip.typ")
#part("ext-fss.html", include "ref/ext-fss.typ")
#part("ext-external.html", include "ref/ext-external.typ")

#part("index-terms.html", title: [Index])[
#heading(numbering: none)[Index]
#make-index()
]
