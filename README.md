# InSpireJSON

Perl scripts that use the inpirehep.net API for creating publication and citation lists. The data analyzed is in JSON format.


Dependencies:
=============

Perl:    JSON JSON::Parse
         Install with:       cpan -i JSON JSON::Parse                 (use sudo for systemwide installation)


External programs: wget   
         If not available, you have to create the json data manually. Files must have specific names, see the TestData directory.


Usage:  
======

Preferences: You should edit the files and set your personal (or other person's) data appropriately.          Follow the instructions from the comments in the source files.
             The LaTeX output can be controlled from special variables in the beggining of the script files.  Follow the instructions from the comments in the source files.
        
Then, simply make the scripts InSpireMakePublist.pl, InSpireMakeCitationList.pl executables and run them in the command line, or run them as Perl scripts in any way you know.


Output:
=======

1. InSpireMakePublist.pl

   In the following filenames ${mylname} = <Your Last Name>

   a. publist-${mylname}.tex         A LaTex file which you can compile and create your publication list
   b. InSpire-${mylname}.json        The JSON data obtained from spires
   c. InSpire-${mylname}.bib         A BibTeX file with your publications, which you can use elsewhere
   d. InSpire-${mylname}.log         A logfile with human readable information. Useful for debugging.
   e. InSpire-${mylname}.pdat        A dump of the JSON data in human readable form up to a certain level (default: 8)
   f. InSpire-${mylname}.pdat.all    A full dump on the JSON data at all levels

Examples can be found in TestData/ for ${mylname} = Anagnostopoulos
Examples of the LaTeX source, and its compiled pdf can be found in Examples/publist-Anagnostopoulos.tex,  Examples/publist-Anagnostopoulos.pdf

2. InSpireMakeCitationList.pl

   a. citlist-${mylname}.tex         A LaTex file which you can compile and create your citation list
   b. files b, c, d, f, same as from  InSpireMakePublist.pl
   c. A JSON   file for the citation list of each of your pubications. The format is InSpireCiting-<arXiv no.>-<slac id>_<bitex entry>_.json   For example: InSpireCiting-9908054-506246_Ambjorn:1999mc_.json
   d. A BibTex file for the citation list of each of your pubications. The format is InSpireCiting-<arXiv no.>-<slac id>_<bitex entry>_.bib    For example: InSpireCiting-9908054-506246_Ambjorn:1999mc_.bib
   e. A log file in human readable form with the results: InSpireCiting-${mylname}.log

Files c+d are automatically fetched (once) using wget. If you don't have wget available, you should created them otherwise.

Examples of files a-e are in the TestData/ directory
Examples of citlist-${mylname}.tex, citlist-${mylname}.pdf are in the Examples/ directory.

