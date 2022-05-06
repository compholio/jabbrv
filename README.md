# Installation

## Basic Installation

No installation is necessary, simply work in the same folder as the LaTeX style file (jabbrv.sty), the language definition files (`*.ldf`) and the BibTeX style files (`*.bst`). Include the package by using `\usepackage{jabbrv}` in your LaTeX preamble and enable the package functionality by setting the BibTeX bibliography style to one of the following choices (depending on the desired bibliography format):
```
    jabbrv_abbrv
    jabbrv_acm
    jabbrv_alpha
    jabbrv_ieeetr
    jabbrv_plain
    jabbrv_siam
    jabbrv_unsrt

```

## Global Installation

To attempt an automated global installation first open a terminal and change the directory to the extracted jabbrv folder. Next, run the install script by executing:
```
sudo ./install.sh
```
If the script cannot detect your local LaTeX installation folder, then you may pass a custom install directory like so:
```
sudo ./install.sh /usr/local/share/texmf
```
Please note that the chosen folder must be part of the directory tree recognized by your LaTeX installation, otherwise the package will note be properly detected.

## Using Other Styles

If you wish to use a style outside of the base BibTeX package then you need to modify that style to call jabbrv. Start by copying the BibTeX style you wish to use to your working folder (and rename it appropriately). Next open the style file and search for:
```
"journal" output.check
```
This line is usually formatted like so (sometimes with an open bracket at the beginning of the line):
```
journal emphasis "journal" output.check
```
Replace this line (do not replace the open bracket if there is one) with:
```
format.journal "journal" output.check
```
Then add the following code somewhere outside of the listed functions (above the "article" function you're currently editing is fine):
```
FUNCTION {format.journal}
{
  "{\em\protect\JournalTitle{" journal * "}}" *
}
```
Please note that if the line you replaced used some other formatting (we started with an emphasized entry, corresponding to the `"\em"` command) then you will need to change the formatting in the above function. Once you have done this step you should be all set, just follow the basic installation instructions above.

## LyX Notes

The preamble may be modified by choosing "Settings" from the "Documents" menu and then selecting "LaTeX Preamble" from the menu on the left.

## Overleaf Notes

Simply copy all jabbrv files into the document folder and add `\usepackage{jabbrv}` to the preamble.  See the [Automatic Journal Abbreviations Template](https://www.overleaf.com/latex/templates/automatic-journal-abbreviations/mxfsdscmvxcr) for an example.

## BibLaTeX Notes

jabbrv is also compatible with BibLaTeX, just add `\usepackage{jabbrv}` to your preamble and use `\addbibresource{file.bib}` and `\printbibliography` like normal.  For an example, take a look at `biblatex-example.tex`.

# Upgrading

Should the current version of the package not suite your needs, it is easy to upgrade to a new version without changing your document. Simply download the new version of the package and extract the style file (jabbrv.sty) and the language definition files (`*.ldf`), replacing the files from your existing version.

# Frequently Asked Questions

* Can I include LaTeX commands in journal titles?

    Yes, "inner" LaTeX commands are expanded before `\JournalTitle{}` is called.

* Can I include already abbreviated journal titles?

    Yes; however, abbreviated words are currently still treated as title words — so if you are unlucky enough to get a match for that "already abbreviated" title then it will get abbreviated again.

* How do I use jabbrv with a custom BibTeX style?

    Please read the instructions for Using Other Styles.

* How can I find out the name of the journal corresponding to a particular abbreviation?

    Use the [Abbreviation Search Utility](http://www.compholio.com/latex/jabbrv/search.php).

* Where did you get this list of title abbreviations?

    From the online version of the ISSN's List of Title Word Abbreviations, which is the maintaining body for title abbreviations as set forth by the ISO 4 standard.

* Why did you make this package?

    Abbreviating journal titles by hand with a large bibliography is extremely time consuming, and evil.
