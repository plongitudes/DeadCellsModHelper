## Dead Cells ModTools Helper(s)

Just a simple batch file to help use `PAKTool.exe` and `CDBTool.exe` to take care of the unpacking and repacking steps when creating a mod.

### Quickstart:
1) Run the batch script
2) Do steps 1 and 2 in the script so that the script knows where your steamlibrary is and where you want to do your work. The script will create two `.ini` files to help it remember those things.
3) Have fun!

### What are these directories?
Four directories get created when you run the tool:
- 00_unpacked_res_pak
 - Where the unpacked `res.pak` data will do. The original `data.cdb` file lives here.
- 01_expanded_data_cdb
 - Where the expanded `data.cdb` file data (all the `.json` files etc) live.
- 02_collapsed_modded_data_cdb
 - When you are ready to re-collapse your `.json` files into a new `data.cdb` file, it will go here. Modified assets can go here as well, and will be ingested when you create your new `res.pak` file.
- 03_packed_modded_res_pak 
 - completed `res.pak` file will go here when it's done.

### Using Vim to edit lots of json files

#### These are just random notes for regex invocations that are relevant to modding values in various `.json` files in the CDB.

##### Replace mob `power` with a different value
`:%s/\(power": \[\n\s\+\)\d\+/\1PATTERN/g`

- `\(power": \[\n\s\+\)` catches the text leading up to a power value.
- `\d\+` catches the value
- `\1` puts the lead-up pattern back
- replace `PATTERN` with the value you want
- `g` makes search and replace global, so all skill powers will be adjusted.

##### To do some math on all numbers following PATTERN:
`:%s/PATTERN\(\d\+\)/\='PATTERN' . (submatch(1) + 50)/g`

For example:
`:%s/baseLootLevel": \(\d\+\)/\='baseLootLevel": ' . (submatch(1) * 2)/g`
- Math happens in the parenthesis that contain the submatch
Or in all files:
`:bufdo :%s/baseLootLevel": \(\d\+\)/\='baseLootLevel": ' . (submatch(1) * 2)/g`
- The magic here happens because of `:bufdo`

Using the above, you could scale all values in all levels or for all mobs. This won't do eveything perfectly, but it's a quick way to do large changes all at once.

