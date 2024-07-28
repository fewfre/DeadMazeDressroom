## V1.16b - 28 July 2024
- Redesign for "copy share code" text fields / copy button to make it feel more polished
- [Code] Some code tweaks, including polish for popup screens


## V1.16 - 7 July 2024
- Moved a bunch of changes from tfm dressroom to here
	- Added copy to clipboard option
	- Updated back button arrow to have a larger hit area
	- Replaced bottom left github button/version text with a new button to a new "About" screen (where aforementioned content has been moved)
		- Added a discord link button on new About screen
	- [Code] Rewrote grid button logic such that only 1 grid is needed for additional buttons in same cell (such as delete button)
	- [Code] Color Finder cropping code made a tiny bit clearer
	- [Code] `ShopInfobar` rewrite (and renamed to `Infobar`)
		- Moved grid management logic to it's own component
		- Grid management button groups can now be hidden individually, instead of all or nothing
		- Hovering over item preview on infobar now properly shows a pointer cursor (to make it more obvious it's clickable)
	- [Code] Small `RoundedRectangle` revamp
	- [Code] Rewrote `RoundedRectangle` to have width/height as normal params
	- [Code] Renamed `TextBase` to `TextTranslated`, and then a new `TextBase` made (which `TextTranslated` inherits from)
	- [Misc] Converted changelog into markdown
	- [Code] Cleaned up `Toolbox` and made it `Event` driven
	- [Code] `BitmapLoaderManager` updated to correctly use local images when not run in app
	- [Code] Rewrote the `TabPane` (now `SidePane`) and scrollbox logic
	- [Misc] Added some analytics (via tracking pixel) for user language + whether using app or browser
	- [Code] Moved shop item pane code from `World` into `ShopCategoryPane`
	- [Code] Various arrays converted to vectors
	- [Code] `ITEM` renamed to `ItemType` and given proper enum typing
	- [Code] `SEX` renamed to `Sex` and given proper enum typing
	- [Code] `ImgurApi` moved to `com.fewfre.utils`
	- [Code] `Grid` revamped and moved to `com.fewfre.display`
	- [Code] Some components in `ui` moved to new `ui.common` folder
	- [Code] Multiple `_drawLine` function replaced with new `GameAssets.createHorizontalRule()`


## V1.15b - 1 May 2023
- [Bug] Clicking scale slider will no longer prevent left/right arrow keys from traversing item grid.
- Scale slider code polished - track hitbox increased & clicking anywhere on track now starts drag.
- (6 Dec 2023) Fixed bug causing color history to stay in delete mode when it shouldn't.


## V1.15 - 6 October 2022
- Added randomize color button to item color picker page
- Undo button added on color picker - clicking it will show colors previously used on the specific color swatch for that specific item.
- Updated color buttons to look nicer
- Recent colors list design reworked and moved to it's own class
- Recent colors now also shown on color finder
- Color finder now supports scaling image & dragging it around
- Files can now be uploaded from the user's computer into the color finder (request by Milinili)
- Manually selecting a language will now cause the app to remember it the next time it is opened (request by Zelenpixel#9767)
- A button has been added to reverse the order of the item lists
- Back button added when in downloadable app
- Recent colors now remembered across dressrooms in the app


## V1.14c - 1 May 2021
- Randomize button icon changed to dice
- Lock icon on infobar now disables randomize button to make it's purpose clearer


## V1.14b - 3 February 2021
- Added missing emotes


## V1.14 - 6 January 2021
- Added support for being externally loaded by AIR app


## V1.13 - 1 January 2019
- Updating share links to use ";" instead of "," to better support atelier801 forum


## V1.12 - 25 October 2018
- Move waitperson pants to "extras" tab since no longer in the game apparently
- Head items that now have a shirt comment show the shirt part in the button icon
- Fixed layer ordering, where head item parts on the shirt layer need to be -under- the shirt


## V1.11c - 10 October 2018
- Added additional clothing dye color
- Fixed display bug when number of colors on last dye row was not 3


## V1.11b - 16 July 2018
- Translation ro updated by Sky


## V1.11 - 24 June 2018
- Missing hair colors added
- All config colors set to actual in-game values (was still using old colors based on a jpg image of an alpha preview image)
- Selecting a config color now updates the color picker button (to allow easily tweaking colors on the fly)


## V1.10 - 6 June 2018
- Async loading added, that preserves load order.
- [Bug] Items that used underwear coloring didn't show the dye feature.


## V1.9b - 8 April 2018
- Clothing coloring now lists default dye colors.
- Various code tweaks


## V1.9 - 5 April 2018
- Clothing can now be colored.


## V1.8 - 10 February 2018
- Added a "trash" button to reset look back to default
- Randomized look button now has a chance to not use an item for each category (fairly high: 35%; pose: 50%; shirt/pants/shoes/weapon: 0%)
- Make init swf parsing slightly async


## V1.7b - 31 January 2018
- Fixed bug preventing sex-specific masks showing up.
- Fixed it so scarves show up as masks. Due to these being a different type behind the scenes, their id is marked as "nk" for "neck".
- Fixed mask layering order so it appears over shirt.


## V1.7 - 23 January 2018
- Added new "Belts" type
- Added "invisible" option for face (for use in mannequin pose)
- New poses added
- A few new objects added


## V1.6b - 15 January 2018
- Adding male/female hair support
- Grouping survivor items tabs together below normal clothing.
- Added some cache breaking


## V1.6 - 10 January 2018
- Shirts and pants now have a "quality" toggle to show torn states.


## V1.5 - 6 January 2018
- Renamed "Costumes" to "GameAssets" and changed it from a singleton to a static class.
- Fixed bugs that made objects that are parts of poses not show up.
- Updated animations (many renamed)
- Female character will no longer show "beards" tab
- Various items are now hidden by default. This simplifies the layout, makes things faster, and focuses on actual in-game modifications. The new "Extras" button config will show everything as before.
	- Skin / Face tabs are removed by default since can't change normally.
	- Other tabs only have some items that need to be hidden; the items that are removed depend on the new "extras" field in the config.
- When sex is switched, items will now change to their male/female counterpart; if there is none, it will be removed.


## V1.4 - 3 September 2017
- Found clothes resource links and updated assets to use them (as well as created an update script)
- When hair / skin / secondary color is updated, these changes are now reflected on hair/beard/skin/pose tabs.
- [Bug] Once you selected a custom color on config, you couldn't select new custom color without clicking a default color first.
- Guitar no longer animates state options; now a play button appears on the pane button that lets you step through the states.
- Adding various languages
- [Bug] Fixed having duplicate outfits show when there was a female-specific version but no male version.
- Moved over TFM Dressroom rework:
	- V1.5
		- Added app info on bottom left
			- Moved github button from Toolbox
			- Now display app's version (using a new "version" i18n string)
			- Now display translator's name (if app not using "en" and not blank) (using a new "translated_by" i18n string)
		- Bug: ConstantsApp.VERSION is now stored as a string.
		- Download button on Toolbox is now bigger (to show importance)
		- ShopInfoBar buttons tweaked
			- Refresh button is now smaller and to the right of download button
			- Added a "lock" button to prevent randomizing a specific category (inspired by micetigri Nekodancer generator)
			- If a button doesn't exist, there is no longer a blank space on the right.
			- Download button is now smaller (so as to not be bigger than main download button).
		- AssetManager now stores the loaded ApplicationDomains instead of the returned content as a movieclip
		- AssetManager now loads data into currentDomain if "useCurrentDomain" is used for that swf
		- Moved UI assets into a separate swf
		- Fewf class now keeps track of Stage, and has a MovieClip called "dispatcher" for global events.
		- I18n & TextBase updated to allow for changing language during runtime.
		- You can now change language during run-time
	- V1.6
		- Color finder feature added for items.
		- [bug] If you selected an item + colored it, selected something else, and then selected it again, the infobar image showed the default image.
		- [bug] Downloading a colored image (vs whole mouse) didn't save it colored.
	- V1.7
		- Imgur upload option added.
		- Resources are no longer cached.


## V1.3 - 3 July 2017
- Added new items / poses
	- Including new item type, "Beards"
- Sex-specific objects now show/hide based on sex chosen
- If an item can be used by either sex, it will not be unequiped when changing sex on config.
- Forcing items to fit within their containers, and smaller items are now scaled up.
- Moved DisplayObject image saving code to FewfDisplayUtils (was in "Costumes").
- Moved most of the contents of "Main" into new class "World" to separate loading and app logic.
- Updated ColorSwatch to be a little more user friendly (as per feedback by RichàrdIDK on Disqus)
	- Clicking a textbox now counts as selecting the swatch.
	- Typing in a hex code will update the value without the need to press enter first.


## V1.2 - 3 July 2017
- Renaming "dressroom" folder to "app"
- Moving Main from ./src to ./src/app
- Made Costumes a singleton, made Main.costumes non-static and private, and replace all instances of it to Costumes.instance.
- Renamed some root level files to more common naming; changelog -> CHANGELOG and todo.txt -> TODO


## V1.1 - 24 February 2017
- Added alpha 4.6 asset changes
	- Had to update some code to work with some assets now having a mix of sex-specific and non sex-specific parts.
- Removing "facing" option (no longer seems to be in game)
- Added "face" option (since face is no longer part of the head asset)
- Re-added "head item" option (since V4.6 assets include them again)


## V1.0 - 14 January 2017
- Using version numbers
- Added localization support.
	- Uses json file.
	- AssetManager changed to handle loading json files
	- Added an I18n class for localization support
	- TextBase now requires use of localization.
- Added TextBase to everywhere that was using hardcoded text.
- Added Fewf class that holds instances of AssetManager and I18n for easy accessing across classes.
- Updated BrowserMouseWheelPrevention to fix bug in Chrome
