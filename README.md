# WRF-models

This repository houses WRF simulation "input decks", with successfully
simulated cases organized by git tags.

Example usage:
```
git clone git@github.com:a2e-mmc/WRF-models.git
mv WRF-models NEWCASE
cd NEWCASE
git tag -n # to list available input decks
git checkout <existing-tag-name>
./setup.sh
```
At this point, the files in your current directory will correspond to the input
deck that you selected. Note that checking out a tag will put you into a
'detached HEAD' state (see `git status`), which is nothing to be afraid of. 

Running `setup.sh`, will download the initial/boundary conditions from the NCAR
Research Data Archive (RDA), and then run preprocessing utilities `geogrid`, 
`ungrib`, and `metgrid`.

See https://git-scm.com/book/en/v2/Git-Basics-Tagging for more information on
tagging.
