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

Scaling power of all mobs up by a factor of 4:
Using capture groups because there's at least one mob who has a power called `power2`, and we want to make sure to change that one as well. `power` is represented in the json files as:

```
"power" :[
    10
]
```

which is tricky to match. We need to look for power and make sure we grab the newline as well.

`:bufdo :%s/\(power\)\(\d*\)\(": \[\n\s\+\)\(\d\+\)/\=(submatch(1)).(submatch(2)).(submatch(3)).(submatch(4)*4)/g`

Scaling power of all mobs down by a factor of 4:
We use `@` instead of `/` as the separator, since we need to use `/` to do math inside the expression, and the character used for the seperator can't appear inside the expression. When we divide, regex will give results as integers, so any remainders will be truncated. If a power is 13 and we scale down by 4, the result is 3.25, and will be truncated to 3.

`:bufdo :%s@\(power\)\(\d*\)\(": \[\n\s\+\)\(\d\+\)@\=(submatch(1)).(submatch(2)).(submatch(3)).(submatch(4)/4)@g`

Using the above, you could scale all values in all levels or for all mobs. This won't do eveything perfectly, but it's a quick way to do large changes all at once.

