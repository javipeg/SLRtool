SLRtool
=======

A Systematic Literature Review (toy) tool, for downloading paper references from academic digital libraries

-------------------------------------------
This is a simple downloader to obtain references from online digital academic libraries. For now, it just downloads references from ACM Digital Library and IEEEXplore. The tool doesn't download any paper pdf. It only downloads the bibtex references obtained by a digital library search, including papers' abstracts if they are available.

This tool is intended for academic use only. It can help download a first list of references that can be used as a starting point when exploring a research field.

This code was put together in a very short amount of time, as an excuse to learn ruby basics. Therefore, it is ugly, crappy and might be full of bugs. Use it and fiddle with it at your own risk ;-)

Use it with common sense and do not abuse the digital libraries services!

Enjoy!


What's needed?
-----
A Ruby installation is needed. Some additional libraries are needed. Usually these are more easily installed through RubyGems. The additional libraries needed are: rubygems, mechanize and bibtex-ruby.


Usage
-----
Edit a term file and add the search terms for the papers you are looking for. Write one term per line. A file "terms" is provided as an example.

Run the tool through the main script by executing:

 $ruby SLR.rb <TERMFILE> <BIBTEXFILE> <LIBRARY>

Where
 TERMFILE:	The name of the term file
 BIBTEXFILE:	The name of the bibtex file to store the references (i.e. references.bib)
 LIBRARY: 	The library to search (IEEE or ACM)

For example:

 $ruby SLR.rb terms references.bib IEEE

Would search IEEE for references containing the terms in the file "terms" and will store the references in the bibtex file "references.bib".


In case the list of terms to search is too big. Several searches should be run instead of one. To avoid the limits imposed by online digital academic libraries, it could be more convenient to download references one term at a time. For that, use the shell scripts included to launch the search.

 $sh launch_all.sh

Will launch the search for both libraries (ACM and IEEE) with the terms in a file named "terms".
A separate bibtex file will be created for each search term.

The multiple bibtex files produced can be merged with the bib merge tool which is also included.

The command:

 $ruby merge.rb lib1.bib lib2.bib mergedLibs.bib

Will merge the bibtex libraries in the files "lib1.bib" and "lib2.bib" into the new file "mergedLibs.bib"


